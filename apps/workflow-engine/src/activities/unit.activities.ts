import { eq, inArray, and } from 'drizzle-orm';
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import {
  unitDefinitions,
  unitInstances,
  flowDefinitions,
  flowInstances,
  flowAuditLog,
  documents,
  notifications,
  type FlowContext,
} from '@workflow/database';

type NotificationType = typeof notifications.$inferInsert.type;

// ---------------------------------------------------------------------------
// Singleton DB connection (same pattern as government.activities.ts)
// ---------------------------------------------------------------------------

let db: ReturnType<typeof drizzle> | null = null;

function getDb() {
  if (!db) {
    const pool = new Pool({
      connectionString: process.env.DATABASE_URL,
    });
    db = drizzle(pool);
  }
  return db;
}

// ---------------------------------------------------------------------------
// loadUnitDefinition — Fetch a unit definition from catalog
// ---------------------------------------------------------------------------

export async function loadUnitDefinition(input: { unitId: string }) {
  const database = getDb();
  const [unit] = await database
    .select()
    .from(unitDefinitions)
    .where(eq(unitDefinitions.id, input.unitId));

  if (!unit) throw new Error(`Unit definition not found: ${input.unitId}`);
  return unit;
}

// ---------------------------------------------------------------------------
// loadFlowDefinition — Fetch flow definition and its graph
// ---------------------------------------------------------------------------

export async function loadFlowDefinition(input: { flowDefinitionId: string }) {
  const database = getDb();
  const [flow] = await database
    .select()
    .from(flowDefinitions)
    .where(eq(flowDefinitions.id, input.flowDefinitionId));

  if (!flow)
    throw new Error(`Flow definition not found: ${input.flowDefinitionId}`);
  return flow;
}

// ---------------------------------------------------------------------------
// createUnitInstance — Create a new unit instance record
// ---------------------------------------------------------------------------

export async function createUnitInstance(input: {
  flowInstanceId: string;
  unitDefinitionId: string;
  nodeId: string;
  config?: Record<string, unknown>;
}): Promise<string> {
  const database = getDb();
  const [instance] = await database
    .insert(unitInstances)
    .values({
      flowInstanceId: input.flowInstanceId,
      unitDefinitionId: input.unitDefinitionId,
      nodeId: input.nodeId,
      status: 'pending',
      input: input.config || {},
      startedAt: new Date(),
    })
    .returning();

  return instance.id;
}

// ---------------------------------------------------------------------------
// updateUnitInstance — Update unit instance status and output
// ---------------------------------------------------------------------------

export async function updateUnitInstance(input: {
  unitInstanceId: string;
  status:
    | 'pending'
    | 'active'
    | 'completed'
    | 'failed'
    | 'skipped'
    | 'cancelled';
  output?: Record<string, unknown>;
  assigneeId?: string;
}) {
  const database = getDb();
  const updates: Partial<typeof unitInstances.$inferInsert> = {
    status: input.status,
  };

  if (input.output) updates.output = input.output;
  if (input.assigneeId) updates.assigneeId = input.assigneeId;
  if (input.status === 'completed' || input.status === 'failed') {
    updates.completedAt = new Date();
  }

  await database
    .update(unitInstances)
    .set(updates)
    .where(eq(unitInstances.id, input.unitInstanceId));
}

// ---------------------------------------------------------------------------
// updateFlowInstance — Update flow instance state
// ---------------------------------------------------------------------------

export async function updateFlowInstance(input: {
  flowInstanceId: string;
  status?:
    | 'running'
    | 'waiting'
    | 'completed'
    | 'failed'
    | 'cancelled'
    | 'paused';
  currentNodeIds?: string[];
  context?: Partial<FlowContext>;
}) {
  const database = getDb();
  const updates: Partial<typeof flowInstances.$inferInsert> = {};

  if (input.status) updates.status = input.status;
  if (input.currentNodeIds) updates.currentNodeIds = input.currentNodeIds;
  if (input.context) updates.context = input.context as FlowContext;
  if (
    input.status === 'completed' ||
    input.status === 'failed' ||
    input.status === 'cancelled'
  ) {
    updates.completedAt = new Date();
  }

  await database
    .update(flowInstances)
    .set(updates)
    .where(eq(flowInstances.id, input.flowInstanceId));
}

// ---------------------------------------------------------------------------
// executeDocumentUnit — Handle DOCUMENT unit type
// ---------------------------------------------------------------------------

export async function executeDocumentUnit(input: {
  unitInstanceId: string;
  flowInstanceId: string;
  config: Record<string, unknown>;
  context: FlowContext;
}): Promise<{ documentId: string; status: string; autoGenerated?: boolean }> {
  const database = getDb();

  try {
    const template =
      typeof input.config.template === 'string'
        ? input.config.template
        : 'default_template';

    const creatorRole =
      typeof input.config.creator === 'string'
        ? input.config.creator
        : 'initiator';
    const creatorId =
      input.context.roleAssignments[creatorRole] ||
      input.context.roleAssignments['initiator'] ||
      null;

    // If autoGenerate, create document automatically as completed
    if (input.config.autoGenerate) {
      const [doc] = await database
        .insert(documents)
        .values({
          title: template || 'Generated Document',
          fileUrl: '/generated/' + template + '.pdf',
          mimeType: 'application/pdf',
          status: 'completed',
          authorId: creatorId,
          metadata: { source: 'workflow', category: template },
        })
        .returning();

      await updateUnitInstance({
        unitInstanceId: input.unitInstanceId,
        status: 'completed',
        output: { documentId: doc.id, autoGenerated: true },
      });

      return { documentId: doc.id, status: 'completed', autoGenerated: true };
    }

    // For manual documents: create a draft document and set unit to active
    const fields = Array.isArray(input.config.fields)
      ? (input.config.fields as string[])
      : [];

    const [doc] = await database
      .insert(documents)
      .values({
        title: template,
        fileUrl: '',
        mimeType: 'application/pdf',
        status: 'draft',
        authorId: creatorId,
        metadata: { source: 'workflow', category: template },
      })
      .returning();

    await updateUnitInstance({
      unitInstanceId: input.unitInstanceId,
      status: 'active',
      output: {
        documentId: doc.id,
        template,
        fields,
        creator: creatorRole,
      },
      assigneeId: creatorId || undefined,
    });

    return { documentId: doc.id, status: 'active' };
  } catch (error) {
    await updateUnitInstance({
      unitInstanceId: input.unitInstanceId,
      status: 'failed',
      output: {
        error: error instanceof Error ? error.message : String(error),
      },
    });
    throw error;
  }
}

// ---------------------------------------------------------------------------
// completeDocumentUnit — Mark a manual document unit as completed
// ---------------------------------------------------------------------------

export async function completeDocumentUnit(input: {
  unitInstanceId: string;
  documentId: string;
  action: string;
  comment?: string;
}) {
  const database = getDb();

  // Update the document status from draft to pending
  await database
    .update(documents)
    .set({ status: 'pending', updatedAt: new Date() })
    .where(eq(documents.id, input.documentId));

  await updateUnitInstance({
    unitInstanceId: input.unitInstanceId,
    status: 'completed',
    output: {
      documentId: input.documentId,
      action: input.action,
      comment: input.comment,
    },
  });
}

// ---------------------------------------------------------------------------
// activateActionUnit — Set up ACTION for human decision
// ---------------------------------------------------------------------------

export async function activateActionUnit(input: {
  unitInstanceId: string;
  assigneeId: string;
  flowInstanceId: string;
  allowedActions: string[];
}) {
  const database = getDb();

  await database
    .update(unitInstances)
    .set({
      status: 'active',
      assigneeId: input.assigneeId || null,
    })
    .where(eq(unitInstances.id, input.unitInstanceId));

  await recordAuditEntry({
    flowInstanceId: input.flowInstanceId,
    unitInstanceId: input.unitInstanceId,
    actorId: null,
    action: 'ACTION_ACTIVATED',
    details: {
      assigneeId: input.assigneeId,
      allowedActions: input.allowedActions,
    },
  });
}

// ---------------------------------------------------------------------------
// completeActionUnit — Record ACTION decision
// ---------------------------------------------------------------------------

export async function completeActionUnit(input: {
  unitInstanceId: string;
  action: string;
  comment?: string;
}) {
  await updateUnitInstance({
    unitInstanceId: input.unitInstanceId,
    status: 'completed',
    output: { action: input.action, comment: input.comment },
  });
}

// ---------------------------------------------------------------------------
// activateTaskUnit — Set up TASK for human completion
// ---------------------------------------------------------------------------

export async function activateTaskUnit(input: {
  unitInstanceId: string;
  assigneeId: string;
  flowInstanceId: string;
  instructions: string;
}) {
  const database = getDb();

  await database
    .update(unitInstances)
    .set({
      status: 'active',
      assigneeId: input.assigneeId || null,
    })
    .where(eq(unitInstances.id, input.unitInstanceId));

  await recordAuditEntry({
    flowInstanceId: input.flowInstanceId,
    unitInstanceId: input.unitInstanceId,
    actorId: null,
    action: 'TASK_ACTIVATED',
    details: {
      assigneeId: input.assigneeId,
      instructions: input.instructions,
    },
  });
}

// ---------------------------------------------------------------------------
// completeTaskUnit — Record TASK completion
// ---------------------------------------------------------------------------

export async function completeTaskUnit(input: {
  unitInstanceId: string;
  result: Record<string, unknown>;
}) {
  await updateUnitInstance({
    unitInstanceId: input.unitInstanceId,
    status: 'completed',
    output: input.result,
  });
}

// ---------------------------------------------------------------------------
// evaluateCondition — Safe condition evaluation (NO eval)
// ---------------------------------------------------------------------------

export async function evaluateCondition(input: {
  unitInstanceId: string;
  flowInstanceId: string;
  expression: string;
  context: FlowContext;
}): Promise<{ branch: string }> {
  const { expression, context } = input;

  // Safe whitelist-based condition evaluator
  const evaluators: Record<string, (ctx: FlowContext) => string> = {
    // Check if agreement_party role is assigned
    has_agreement_parties: (ctx) =>
      ctx.roleAssignments['agreement_party'] ? 'true' : 'false',

    // Return the action from the previous node's output
    action_result: (ctx) => {
      const completedNodes = ctx.completedNodes;
      // Find the most recent completed node that has an action output
      for (let i = completedNodes.length - 1; i >= 0; i--) {
        const nodeOutput = ctx.nodeOutputs[completedNodes[i]] as
          | Record<string, unknown>
          | undefined;
        const action = nodeOutput?.action;
        if (typeof action === 'string') return action;
      }
      return 'default';
    },

    // Check if amount exceeds threshold
    amount_threshold: (ctx) => {
      const amount = (ctx.variables['estimatedCost'] ??
        ctx.variables['totalAmount'] ??
        0) as number;
      return Number(amount) > 100000 ? 'true' : 'false';
    },

    // Check urgency
    urgency_check: (ctx) => {
      const urgency = ctx.variables['urgency'] as string | undefined;
      return urgency === 'high' || urgency === 'urgent' ? 'true' : 'false';
    },
  };

  const evaluator = evaluators[expression];
  if (!evaluator) {
    console.warn(
      `Unknown condition expression: ${expression}, defaulting to "false"`,
    );
    return { branch: 'false' };
  }

  const branch = evaluator(context);

  await updateUnitInstance({
    unitInstanceId: input.unitInstanceId,
    status: 'completed',
    output: { expression, branch },
  });

  return { branch };
}

// ---------------------------------------------------------------------------
// sendNotification — Send notification through configured channels
// ---------------------------------------------------------------------------

export async function sendNotification(input: {
  unitInstanceId: string;
  recipientId: string;
  flowInstanceId: string;
  channel: string[];
  message: string;
  title?: string;
  type?: NotificationType;
  flowDefinitionId?: string;
}) {
  const database = getDb();

  // Insert in-app notification record
  if (input.recipientId) {
    await database.insert(notifications).values({
      recipientId: input.recipientId,
      type: input.type || 'info',
      title: input.title || 'Workflow Notification',
      message: input.message,
      flowInstanceId: input.flowInstanceId,
      flowDefinitionId: input.flowDefinitionId || null,
      unitInstanceId: input.unitInstanceId,
    });
  }

  // Log for external channel integration (email/SMS)
  for (const ch of input.channel || ['portal']) {
    console.log(
      `[NOTIFICATION] Channel: ${ch} | To: ${input.recipientId} | Message: ${input.message}`,
    );
  }

  await updateUnitInstance({
    unitInstanceId: input.unitInstanceId,
    status: 'completed',
    output: {
      sent: true,
      channels: input.channel,
      recipientId: input.recipientId,
      message: input.message,
    },
  });

  await recordAuditEntry({
    flowInstanceId: input.flowInstanceId,
    unitInstanceId: input.unitInstanceId,
    actorId: null,
    action: 'NOTIFICATION_SENT',
    details: { channels: input.channel, recipientId: input.recipientId },
  });
}

// ---------------------------------------------------------------------------
// createNotification — Insert a notification record (for use by any workflow step)
// ---------------------------------------------------------------------------

export async function createNotification(input: {
  recipientId: string;
  type: NotificationType;
  title: string;
  message: string;
  flowInstanceId: string;
  flowDefinitionId?: string;
  unitInstanceId?: string;
  actorId?: string;
}) {
  if (!input.recipientId) return;

  const database = getDb();
  await database.insert(notifications).values({
    recipientId: input.recipientId,
    type: input.type,
    title: input.title,
    message: input.message,
    flowInstanceId: input.flowInstanceId,
    flowDefinitionId: input.flowDefinitionId || null,
    unitInstanceId: input.unitInstanceId || null,
    actorId: input.actorId || null,
  });
}

// ---------------------------------------------------------------------------
// executeAutomation — Dispatch to named handler functions
// ---------------------------------------------------------------------------

type AutomationConfig = Record<string, unknown>;
type AutomationResult = Record<string, unknown>;

export async function executeAutomation(input: {
  unitInstanceId: string;
  flowInstanceId: string;
  handler: string;
  config: AutomationConfig;
  context: FlowContext;
}): Promise<AutomationResult> {
  const handlers: Record<
    string,
    (cfg: AutomationConfig, ctx: FlowContext) => AutomationResult
  > = {
    generateDocumentFromTemplate: (cfg) => {
      const template =
        typeof cfg.template === 'string' ? cfg.template : 'default_template';
      console.log(
        `[AUTOMATION] Generating document from template: ${template}`,
      );
      return { generated: true, template };
    },

    archiveDocuments: () => {
      console.log(`[AUTOMATION] Archiving all documents for flow`);
      return { archived: true, timestamp: new Date().toISOString() };
    },

    generateRegistryNumber: () => {
      const year = new Date().getFullYear();
      const seq = String(Date.now() % 100000).padStart(5, '0');
      const registryNumber = `REG-${year}-${seq}`;
      console.log(`[AUTOMATION] Generated registry number: ${registryNumber}`);
      return { registryNumber };
    },

    validateDocumentFields: (cfg, ctx) => {
      const requiredFields = (cfg.requiredFields as string[]) || [];
      const missingFields = requiredFields.filter(
        (f: string) => !ctx.variables[f],
      );
      const isValid = missingFields.length === 0;
      return { isValid, missingFields };
    },
  };

  const handlerFn = handlers[input.handler];
  if (!handlerFn) {
    throw new Error(`Unknown automation handler: ${input.handler}`);
  }

  const result = handlerFn(input.config, input.context);

  await updateUnitInstance({
    unitInstanceId: input.unitInstanceId,
    status: 'completed',
    output: result,
  });

  await recordAuditEntry({
    flowInstanceId: input.flowInstanceId,
    unitInstanceId: input.unitInstanceId,
    actorId: null,
    action: 'AUTOMATION_EXECUTED',
    details: { handler: input.handler, ...result },
  });

  return result;
}

// ---------------------------------------------------------------------------
// recordAuditEntry — Append to flow audit log (immutable)
// ---------------------------------------------------------------------------

export async function recordAuditEntry(input: {
  flowInstanceId: string;
  unitInstanceId?: string | null;
  actorId?: string | null;
  action: string;
  fromStatus?: string;
  toStatus?: string;
  comment?: string;
  details?: Record<string, unknown>;
}) {
  const database = getDb();
  await database.insert(flowAuditLog).values({
    flowInstanceId: input.flowInstanceId,
    unitInstanceId: input.unitInstanceId || null,
    actorId: input.actorId || null,
    action: input.action,
    fromStatus: input.fromStatus,
    toStatus: input.toStatus,
    comment: input.comment,
    metadata: (input.details || {}) as Record<string, string>,
  });
}

// ---------------------------------------------------------------------------
// handleTimeout — Handle unit timeout
// ---------------------------------------------------------------------------

export async function handleTimeout(input: {
  unitInstanceId: string;
  flowInstanceId: string;
  nodeId: string;
}) {
  await updateUnitInstance({
    unitInstanceId: input.unitInstanceId,
    status: 'failed',
    output: { reason: 'TIMEOUT', nodeId: input.nodeId },
  });

  await recordAuditEntry({
    flowInstanceId: input.flowInstanceId,
    unitInstanceId: input.unitInstanceId,
    actorId: null,
    action: 'TIMEOUT',
    details: { nodeId: input.nodeId },
  });
}

// ---------------------------------------------------------------------------
// cancelActiveUnits — Bulk-cancel all active/pending unit instances for a flow
// ---------------------------------------------------------------------------

export async function cancelActiveUnits(input: { flowInstanceId: string }) {
  const database = getDb();
  await database
    .update(unitInstances)
    .set({ status: 'cancelled', completedAt: new Date() })
    .where(
      and(
        eq(unitInstances.flowInstanceId, input.flowInstanceId),
        inArray(unitInstances.status, ['active', 'pending']),
      ),
    );
}
