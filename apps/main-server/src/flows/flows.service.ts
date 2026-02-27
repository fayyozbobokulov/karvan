import {
  Inject,
  Injectable,
  Logger,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { eq, desc, and } from 'drizzle-orm';
import {
  DRIZZLE,
  TASK_QUEUES,
  WORKFLOW_TYPES,
  unitDefinitions,
  flowDefinitions,
  flowInstances,
  unitInstances,
  flowAuditLog,
  users,
  type FlowNode,
} from '@workflow/database';
import type { NodePgDatabase } from 'drizzle-orm/node-postgres';
import type * as schema from '@workflow/database';
import { TemporalService } from '../temporal/temporal.service';

@Injectable()
export class FlowsService {
  private readonly logger = new Logger(FlowsService.name);

  constructor(
    @Inject(DRIZZLE) private readonly db: NodePgDatabase<typeof schema>,
    private readonly temporalService: TemporalService,
  ) {}

  // ── Start a new flow instance ─────────────────────────────────────────

  async startFlow(input: {
    flowDefinitionId: string;
    roleAssignments: Record<string, string>;
    variables: Record<string, any>;
    startedBy?: string;
  }) {
    // 1. Validate flow definition exists
    const [flowDef] = await this.db
      .select()
      .from(flowDefinitions)
      .where(eq(flowDefinitions.id, input.flowDefinitionId));

    if (!flowDef) {
      throw new NotFoundException(
        `Flow definition not found: ${input.flowDefinitionId}`,
      );
    }

    // 2. Create flow instance
    const temporalWorkflowId = `flow-${input.flowDefinitionId}-${Date.now()}`;

    const [flowInstance] = await this.db
      .insert(flowInstances)
      .values({
        flowDefinitionId: input.flowDefinitionId,
        temporalWorkflowId,
        status: 'running',
        currentNodeIds: [],
        context: {
          roleAssignments: input.roleAssignments,
          variables: input.variables,
          completedNodes: [],
          nodeOutputs: {},
          activeNodes: [],
        },
        startedBy: input.startedBy || null,
      })
      .returning();

    // 3. Start Temporal workflow
    const graph = flowDef.graph as FlowNode[];

    await this.temporalService.startFlowGraphWorkflow({
      flowInstanceId: flowInstance.id,
      flowDefinitionId: input.flowDefinitionId,
      graph,
      context: {
        roleAssignments: input.roleAssignments,
        variables: input.variables,
        completedNodes: [],
        nodeOutputs: {},
        activeNodes: [],
      },
      temporalWorkflowId,
    });

    return {
      flowInstanceId: flowInstance.id,
      temporalWorkflowId,
      status: 'running',
    };
  }

  // ── Signal a running flow with human decision ─────────────────────────

  async signalFlow(
    flowInstanceId: string,
    signal: {
      nodeId: string;
      action: string;
      comment?: string;
      data?: Record<string, any>;
    },
  ) {
    const [instance] = await this.db
      .select()
      .from(flowInstances)
      .where(eq(flowInstances.id, flowInstanceId));

    if (!instance) {
      throw new NotFoundException(`Flow instance not found: ${flowInstanceId}`);
    }

    // Validate flow is in a signalable state
    const signalableStatuses = ['running', 'waiting'];
    if (!signalableStatuses.includes(instance.status)) {
      throw new ConflictException(
        `Flow instance ${flowInstanceId} is in status "${instance.status}" and cannot accept signals`,
      );
    }

    // Send signal to Temporal (point of no return)
    await this.temporalService.sendHumanDecisionSignal(
      instance.temporalWorkflowId,
      signal,
    );

    // Record audit (best-effort after successful signal)
    try {
      await this.db.insert(flowAuditLog).values({
        flowInstanceId,
        actorId: signal.data?.actorId || null,
        action: signal.action,
        comment: signal.comment,
        metadata: { nodeId: signal.nodeId, ...signal.data },
      });
    } catch (auditError) {
      this.logger.error(
        `Audit log write failed after successful signal for flow ${flowInstanceId}: ${auditError}`,
      );
    }

    return { status: 'ok' };
  }

  // ── Query flow status from Temporal ───────────────────────────────────

  async getFlowStatus(flowInstanceId: string) {
    const [instance] = await this.db
      .select()
      .from(flowInstances)
      .where(eq(flowInstances.id, flowInstanceId));

    if (!instance) {
      throw new NotFoundException(`Flow instance not found: ${flowInstanceId}`);
    }

    try {
      const temporalStatus = await this.temporalService.queryFlowStatus(
        instance.temporalWorkflowId,
      );
      return {
        ...temporalStatus,
        flowInstanceId,
        flowDefinitionId: instance.flowDefinitionId,
        dbStatus: instance.status,
      };
    } catch {
      // If Temporal query fails (workflow finished), return DB state
      return {
        flowInstanceId,
        flowDefinitionId: instance.flowDefinitionId,
        status: instance.status,
        activeNodes: instance.currentNodeIds,
        completedNodes: [],
        history: [],
        dbStatus: instance.status,
      };
    }
  }

  // ── Get audit trail for a flow ────────────────────────────────────────

  async getFlowAudit(flowInstanceId: string) {
    return await this.db
      .select()
      .from(flowAuditLog)
      .where(eq(flowAuditLog.flowInstanceId, flowInstanceId))
      .orderBy(desc(flowAuditLog.createdAt));
  }

  // ── List all unit definitions ─────────────────────────────────────────

  async getUnitDefinitions(type?: string) {
    if (type) {
      return await this.db
        .select()
        .from(unitDefinitions)
        .where(
          and(
            eq(unitDefinitions.isActive, true),
            eq(unitDefinitions.type, type as any),
          ),
        );
    }
    return await this.db
      .select()
      .from(unitDefinitions)
      .where(eq(unitDefinitions.isActive, true));
  }

  // ── List all flow definitions ─────────────────────────────────────────

  async getFlowDefinitions(category?: string) {
    if (category) {
      return await this.db
        .select()
        .from(flowDefinitions)
        .where(
          and(
            eq(flowDefinitions.isActive, true),
            eq(flowDefinitions.category, category),
          ),
        );
    }
    return await this.db
      .select()
      .from(flowDefinitions)
      .where(eq(flowDefinitions.isActive, true));
  }

  // ── Get pending tasks for a user ──────────────────────────────────────

  async getMyTasks(userId: string) {
    const tasks = await this.db
      .select({
        unitInstance: unitInstances,
        unitDefinition: unitDefinitions,
        flowInstance: flowInstances,
        flowDefinition: flowDefinitions,
      })
      .from(unitInstances)
      .innerJoin(
        unitDefinitions,
        eq(unitInstances.unitDefinitionId, unitDefinitions.id),
      )
      .innerJoin(
        flowInstances,
        eq(unitInstances.flowInstanceId, flowInstances.id),
      )
      .innerJoin(
        flowDefinitions,
        eq(flowInstances.flowDefinitionId, flowDefinitions.id),
      )
      .where(
        and(
          eq(unitInstances.assigneeId, userId),
          eq(unitInstances.status, 'active'),
        ),
      )
      .orderBy(desc(unitInstances.createdAt));

    return tasks.map((t) => ({
      id: t.unitInstance.id,
      nodeId: t.unitInstance.nodeId,
      status: t.unitInstance.status,
      unitType: t.unitDefinition.type,
      unitName: t.unitDefinition.name,
      unitConfig: t.unitDefinition.config,
      flowInstanceId: t.flowInstance.id,
      flowName: t.flowDefinition.name,
      flowDefinitionId: t.flowDefinition.id,
      assigneeId: t.unitInstance.assigneeId,
      input: t.unitInstance.input,
      createdAt: t.unitInstance.createdAt,
    }));
  }

  // ── List all flow instances ───────────────────────────────────────────

  async listFlowInstances(status?: string) {
    const query = this.db
      .select({
        flowInstance: flowInstances,
        flowDefinition: flowDefinitions,
        startedByUser: users,
      })
      .from(flowInstances)
      .innerJoin(
        flowDefinitions,
        eq(flowInstances.flowDefinitionId, flowDefinitions.id),
      )
      .leftJoin(users, eq(flowInstances.startedBy, users.id));

    const results = status
      ? await query.where(eq(flowInstances.status, status as any))
      : await query;

    return results
      .map((r) => ({
        id: r.flowInstance.id,
        flowDefinitionId: r.flowInstance.flowDefinitionId,
        flowName: r.flowDefinition.name,
        flowIcon: r.flowDefinition.icon,
        flowColor: r.flowDefinition.color,
        status: r.flowInstance.status,
        temporalWorkflowId: r.flowInstance.temporalWorkflowId,
        startedBy: r.startedByUser?.name || 'Unknown',
        startedAt: r.flowInstance.startedAt,
        completedAt: r.flowInstance.completedAt,
        currentNodeIds: r.flowInstance.currentNodeIds,
      }))
      .sort(
        (a, b) =>
          new Date(b.startedAt).getTime() - new Date(a.startedAt).getTime(),
      );
  }

  // ── Get a single flow instance with graph ─────────────────────────────

  async getFlowInstance(flowInstanceId: string) {
    const [result] = await this.db
      .select({
        flowInstance: flowInstances,
        flowDefinition: flowDefinitions,
      })
      .from(flowInstances)
      .innerJoin(
        flowDefinitions,
        eq(flowInstances.flowDefinitionId, flowDefinitions.id),
      )
      .where(eq(flowInstances.id, flowInstanceId));

    if (!result) {
      throw new NotFoundException(`Flow instance not found: ${flowInstanceId}`);
    }

    // Get all unit instances for this flow (with assignee name)
    const units = await this.db
      .select({
        unitInstance: unitInstances,
        unitDefinition: unitDefinitions,
        assignee: users,
      })
      .from(unitInstances)
      .innerJoin(
        unitDefinitions,
        eq(unitInstances.unitDefinitionId, unitDefinitions.id),
      )
      .leftJoin(users, eq(unitInstances.assigneeId, users.id))
      .where(eq(unitInstances.flowInstanceId, flowInstanceId))
      .orderBy(unitInstances.createdAt);

    return {
      ...result.flowInstance,
      flowName: result.flowDefinition.name,
      flowIcon: result.flowDefinition.icon,
      flowColor: result.flowDefinition.color,
      graph: result.flowDefinition.graph,
      unitInstances: units.map((u) => ({
        id: u.unitInstance.id,
        nodeId: u.unitInstance.nodeId,
        status: u.unitInstance.status,
        unitType: u.unitDefinition.type,
        unitName: u.unitDefinition.name,
        assigneeId: u.unitInstance.assigneeId,
        assigneeName: u.assignee?.name || null,
        output: u.unitInstance.output,
        startedAt: u.unitInstance.startedAt,
        completedAt: u.unitInstance.completedAt,
      })),
    };
  }
}
