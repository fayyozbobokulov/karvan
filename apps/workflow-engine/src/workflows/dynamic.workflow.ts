import {
  proxyActivities,
  defineSignal,
  setHandler,
  condition,
  log,
} from '@temporalio/workflow';
import { z } from 'zod';
import type { SelectDocument, SelectTask } from '@workflow/database';
import type * as govActivities from '../activities/government.activities';

const {
  createTask,
  notifyUser,
  signDocument,
  rejectDocument,
  archiveDocument,
} = proxyActivities<typeof govActivities>({
  startToCloseTimeout: '1m',
  retry: {
    maximumAttempts: 5,
  },
});

// Zod Schemas
export const SignSignalDataSchema = z.object({
  taskId: z.string(),
});
export type SignSignalData = z.infer<typeof SignSignalDataSchema>;

export const RejectSignalDataSchema = z.object({
  taskId: z.string(),
  comment: z.string(),
});
export type RejectSignalData = z.infer<typeof RejectSignalDataSchema>;

export const StepSchema = z.object({
  id: z.string(),
  type: z.string(),
  config: z.record(z.any()).optional(),
  next: z.string().optional(),
});
export type Step = z.infer<typeof StepSchema>;

export const BlueprintSchema = z.object({
  steps: z.array(StepSchema),
});
export type Blueprint = z.infer<typeof BlueprintSchema>;

export const AssignmentConfigSchema = z.object({
  assigneeId: z.string(),
  taskType: z.string().optional().default('review'),
});

// Signals
export const signSignal = defineSignal<[SignSignalData]>('sign');
export const rejectSignal = defineSignal<[RejectSignalData]>('reject');

export async function dynamicWorkflow(
  document: SelectDocument,
  blueprint: Blueprint,
): Promise<void> {
  let currentStepId: string | undefined = blueprint.steps[0]?.id;
  let userAction: 'sign' | 'reject' | null = null;
  let actionData: SignSignalData | RejectSignalData | null = null;

  // Signal Handlers
  setHandler(signSignal, (data) => {
    userAction = 'sign';
    actionData = data;
  });

  setHandler(rejectSignal, (data) => {
    userAction = 'reject';
    actionData = data;
  });

  // Initial notification to author
  if (document.authorId) {
    await notifyUser({
      userId: document.authorId,
      message: `Your document "${document.title}" has been created and workflow started.`,
    });
  }

  while (currentStepId) {
    const step = blueprint.steps.find((s) => s.id === currentStepId);
    if (!step) break;

    log.info(`Executing step: ${step.id} (${step.type})`);

    switch (step.type) {
      case 'assignment': {
        const configResult = AssignmentConfigSchema.safeParse(step.config);

        if (!configResult.success) {
          log.error(
            `Invalid configuration for assignment step ${step.id}: ${configResult.error.message}`,
          );
          currentStepId = undefined;
          break;
        }

        const { assigneeId, taskType } = configResult.data;

        const task = await createTask({
          documentId: document.id,
          assigneeId,
          type: taskType,
        });

        // Wait for Signal (Sign or Reject)
        log.info(`Waiting for action on task: ${task.id}`);
        await condition(() => userAction !== null);

        if (userAction === 'sign' && actionData && 'taskId' in actionData) {
          await signDocument({ documentId: document.id, taskId: task.id });
          currentStepId = step.next;
        } else if (
          userAction === 'reject' &&
          actionData &&
          'comment' in actionData
        ) {
          const rejectData = actionData as RejectSignalData;
          await rejectDocument({
            documentId: document.id,
            taskId: task.id,
            comment: rejectData.comment || 'No comment',
          });
          // On rejection, we might terminate or go to a specific "rejected" step
          log.info('Document rejected, terminating workflow.');
          return;
        }

        // Reset for next step
        userAction = null;
        actionData = null;
        break;
      }

      case 'archive': {
        await archiveDocument(document.id);
        currentStepId = step.next;
        break;
      }

      default:
        log.error(`Unknown step type: ${step.type}`);
        currentStepId = undefined;
        break;
    }
  }

  log.info(`Workflow completed for document: ${document.id}`);
}
