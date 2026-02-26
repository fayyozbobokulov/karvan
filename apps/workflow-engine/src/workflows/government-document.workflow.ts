import {
  proxyActivities,
  defineSignal,
  defineQuery,
  setHandler,
  condition,
} from '@temporalio/workflow';
import type * as activities from '../activities/government.activities';

export const reviewDecisionSignal =
  defineSignal<[{ action: string; comment?: string }]>('reviewDecision');
export const approvalDecisionSignal =
  defineSignal<[{ action: string; comment?: string }]>('approvalDecision');
export const signDecisionSignal =
  defineSignal<[{ action: string }]>('signDecision');

export const getStatusQuery = defineQuery<WorkflowStatus>('getStatus');

const {
  validateDocument,
  createTask,
  completeTask,
  updateDocumentStatus,
  signDocument,
  registerDocument,
  distributeDocument,
  recordAuditLog,
  sendNotification,
  escalateTask,
} = proxyActivities<typeof activities>({
  startToCloseTimeout: '5 minutes',
  retry: { maximumAttempts: 3 },
});

interface WorkflowStatus {
  currentStage: string;
  documentId: string;
  history: Array<{ stage: string; action: string; timestamp: string }>;
}

export async function governmentDocumentWorkflow(input: {
  documentId: string;
  blueprint: any;
  authorId: string;
}) {
  const { documentId, authorId } = input;
  let currentStage = 'submitted';
  const history: WorkflowStatus['history'] = [];

  setHandler(getStatusQuery, () => ({
    currentStage,
    documentId,
    history,
  }));

  const transition = async (stage: string, action: string) => {
    const prev = currentStage;
    currentStage = stage;
    history.push({ stage, action, timestamp: new Date().toISOString() });
    await recordAuditLog({
      documentId,
      fromStatus: prev,
      toStatus: stage,
      action,
    });
  };

  await transition('validating', 'auto_validate');
  await updateDocumentStatus({ documentId, status: 'validating' });

  const validation = await validateDocument({ documentId });
  if (!validation.isValid) {
    await transition('rejected', 'validation_failed');
    await updateDocumentStatus({ documentId, status: 'rejected' });
    await sendNotification({
      userId: authorId,
      message: `Document rejected: ${validation.errors.join(', ')}`,
    });
    return {
      status: 'REJECTED',
      reason: 'validation_failed',
      errors: validation.errors,
    };
  }

  await transition('in_review', 'assigned_to_reviewer');
  await updateDocumentStatus({ documentId, status: 'in_review' });

  const reviewTask = await createTask({
    documentId,
    assigneeRole: 'reviewer',
    actionType: 'review',
  });
  await sendNotification({
    userId: reviewTask.assigneeId,
    message: `New document awaiting your review: ${documentId}`,
  });

  let reviewDecision: { action: string; comment?: string } | null = null;
  setHandler(reviewDecisionSignal, (decision) => {
    reviewDecision = decision;
  });

  const reviewTimedOut = !(await condition(
    () => reviewDecision !== null,
    '72h',
  ));

  if (reviewTimedOut) {
    await escalateTask({ taskId: reviewTask.id, reason: 'timeout' });
    await sendNotification({
      userId: authorId,
      message: 'Review escalated due to timeout',
    });
  }

  const rDecision = reviewDecision as any;
  if (rDecision?.action === 'reject') {
    await completeTask({ taskId: reviewTask.id, action: 'rejected' });
    await transition('rejected', 'reviewer_rejected');
    await updateDocumentStatus({ documentId, status: 'rejected' });
    return {
      status: 'REJECTED',
      reason: 'reviewer_rejected',
      comment: rDecision?.comment,
    };
  }

  if (rDecision?.action === 'request_changes') {
    await completeTask({ taskId: reviewTask.id, action: 'returned' });
    await transition('returned', 'changes_requested');
    await updateDocumentStatus({ documentId, status: 'returned' });
    await sendNotification({
      userId: authorId,
      message: `Changes requested: ${rDecision?.comment}`,
    });
    return {
      status: 'RETURNED',
      reason: 'changes_requested',
      comment: rDecision?.comment,
    };
  }

  await completeTask({ taskId: reviewTask.id, action: 'approved' });

  const approvalLevels = ['department_head', 'director'];

  for (const role of approvalLevels) {
    await transition('in_approval', `assigned_to_${role}`);
    await updateDocumentStatus({ documentId, status: 'in_approval' });

    const approvalTask = await createTask({
      documentId,
      assigneeRole: role,
      actionType: 'approve',
    });
    await sendNotification({
      userId: approvalTask.assigneeId,
      message: `Document requires your approval`,
    });

    let approvalDecision: { action: string; comment?: string } | null = null;
    setHandler(approvalDecisionSignal, (decision) => {
      approvalDecision = decision;
    });

    const approvalTimedOut = !(await condition(
      () => approvalDecision !== null,
      '48h',
    ));

    if (approvalTimedOut) {
      await escalateTask({ taskId: approvalTask.id, reason: 'timeout' });
    }

    const aDecision = approvalDecision as any;
    if (aDecision?.action === 'reject') {
      await completeTask({ taskId: approvalTask.id, action: 'rejected' });
      await transition('rejected', `${role}_rejected`);
      await updateDocumentStatus({ documentId, status: 'rejected' });
      return {
        status: 'REJECTED',
        reason: `${role}_rejected`,
        comment: aDecision?.comment,
      };
    }

    await completeTask({ taskId: approvalTask.id, action: 'approved' });
    approvalDecision = null; // Reset for next iteration
  }

  await transition('awaiting_signature', 'assigned_to_signatory');
  await updateDocumentStatus({ documentId, status: 'awaiting_signature' });

  const signTask = await createTask({
    documentId,
    assigneeRole: 'signatory',
    actionType: 'sign',
  });

  let signDecision: { action: string } | null = null;
  setHandler(signDecisionSignal, (decision) => {
    signDecision = decision;
  });

  await condition(() => signDecision !== null, '120h');

  const sDecision = signDecision as any;
  if (sDecision?.action === 'reject') {
    await completeTask({ taskId: signTask.id, action: 'rejected' });
    await transition('rejected', 'signatory_rejected');
    await updateDocumentStatus({ documentId, status: 'rejected' });
    return { status: 'REJECTED', reason: 'signatory_rejected' };
  }

  await signDocument({ documentId });
  await completeTask({ taskId: signTask.id, action: 'signed' });

  await transition('registering', 'auto_register');
  await updateDocumentStatus({ documentId, status: 'registering' });
  const registry = await registerDocument({ documentId });

  await transition('distributing', 'auto_distribute');
  await updateDocumentStatus({ documentId, status: 'distributing' });
  await distributeDocument({
    documentId,
    registryNumber: registry.registryNumber,
  });

  await transition('completed', 'workflow_complete');
  await updateDocumentStatus({ documentId, status: 'completed' });
  await sendNotification({
    userId: authorId,
    message: `Document ${registry.registryNumber} is now official and distributed.`,
  });

  return {
    status: 'COMPLETED',
    registryNumber: registry.registryNumber,
    history,
  };
}
