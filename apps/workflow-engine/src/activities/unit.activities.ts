import { eq, and } from 'drizzle-orm';
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import {
  unitDefinitions,
  unitInstances,
  flowDefinitions,
  flowInstances,
  flowAuditLog,
  documents,
  users,
  type FlowNode,
  type FlowContext,
} from '@workflow/database';

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
  config?: Record<string, any>;
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
  output?: Record<string, any>;
  assigneeId?: string;
}) {
  const database = getDb();
  const updates: any = { status: input.status };

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
  status?: 'running' | 'waiting' | 'completed' | 'failed' | 'cancelled';
  currentNodeIds?: string[];
  context?: Partial<FlowContext>;
}) {
  const database = getDb();
  const updates: any = {};

  if (input.status) updates.status = input.status;
  if (input.currentNodeIds) updates.currentNodeIds = input.currentNodeIds;
  if (input.context) updates.context = input.context;
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
  config: Record<string, any>;
  context: FlowContext;
}): Promise<{ documentId?: string; status: string }> {
  const database = getDb();

  try {
    // If autoGenerate, create document automatically
    if (input.config.autoGenerate) {
      const [doc] = await database
        .insert(documents)
        .values({
          title: input.config.template || 'Generated Document',
          fileUrl: '/generated/' + input.config.template + '.pdf',
          mimeType: 'application/pdf',
          status: 'completed',
          authorId: input.context.roleAssignments['initiator'] || null,
          metadata: { source: 'workflow', category: input.config.template },
        })
        .returning();

      await updateUnitInstance({
        unitInstanceId: input.unitInstanceId,
        status: 'completed',
        output: { documentId: doc.id, autoGenerated: true },
      });

      return { documentId: doc.id, status: 'completed' };
    }

    // For manual documents, mark as active (creator will fill it in)
    await updateUnitInstance({
      unitInstanceId: input.unitInstanceId,
      status: 'completed',
      output: {
        template: input.config.template,
        fields: input.config.fields || [],
        creator: input.config.creator,
      },
    });

    return { status: 'completed' };
  } catch (error: any) {
    await updateUnitInstance({
      unitInstanceId: input.unitInstanceId,
      status: 'failed',
      output: { error: error.message },
    });
    throw error;
  }
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
  result: Record<string, any>;
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
        const nodeOutput = ctx.nodeOutputs[completedNodes[i]];
        if (nodeOutput?.action) return nodeOutput.action;
      }
      return 'default';
    },

    // Check if amount exceeds threshold
    amount_threshold: (ctx) => {
      const amount =
        ctx.variables['estimatedCost'] || ctx.variables['totalAmount'] || 0;
      return Number(amount) > 100000 ? 'true' : 'false';
    },

    // Check urgency
    urgency_check: (ctx) => {
      const urgency = ctx.variables['urgency'];
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
}) {
  // For now, log notifications. In production, integrate with email/SMS/portal.
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
// executeAutomation — Dispatch to named handler functions
// ---------------------------------------------------------------------------

export async function executeAutomation(input: {
  unitInstanceId: string;
  flowInstanceId: string;
  handler: string;
  config: Record<string, any>;
  context: FlowContext;
}): Promise<Record<string, any>> {
  const database = getDb();

  const handlers: Record<string, (cfg: any, ctx: FlowContext) => Promise<any>> =
    {
      generateDocumentFromTemplate: async (cfg, ctx) => {
        const template = cfg.template || 'default_template';
        console.log(
          `[AUTOMATION] Generating document from template: ${template}`,
        );
        return { generated: true, template };
      },

      archiveDocuments: async (cfg, ctx) => {
        console.log(`[AUTOMATION] Archiving all documents for flow`);
        return { archived: true, timestamp: new Date().toISOString() };
      },

      generateRegistryNumber: async (cfg, ctx) => {
        const year = new Date().getFullYear();
        const seq = String(Date.now() % 100000).padStart(5, '0');
        const registryNumber = `REG-${year}-${seq}`;
        console.log(
          `[AUTOMATION] Generated registry number: ${registryNumber}`,
        );
        return { registryNumber };
      },

      validateDocumentFields: async (cfg, ctx) => {
        const requiredFields = cfg.requiredFields || [];
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

  const result = await handlerFn(input.config, input.context);

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
    details: { handler: input.handler, result },
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
  details?: Record<string, any>;
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
    metadata: input.details || {},
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
