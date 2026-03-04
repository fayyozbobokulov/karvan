import {
  Injectable,
  Logger,
  OnModuleInit,
  BadRequestException,
} from '@nestjs/common';
import { Client, Connection, WorkflowNotFoundError } from '@temporalio/client';
import {
  TASK_QUEUES,
  WORKFLOW_TYPES,
  type FlowNode,
  type FlowContext,
} from '@workflow/database';

export interface FlowStatusResult {
  flowInstanceId: string;
  status: string;
  activeNodes: string[];
  completedNodes: string[];
  history: Array<{
    nodeId: string;
    label: string;
    unitType: string;
    status: string;
    timestamp: string;
  }>;
}

@Injectable()
export class TemporalService implements OnModuleInit {
  private client!: Client;
  private readonly logger = new Logger(TemporalService.name);

  async onModuleInit() {
    const address = process.env.TEMPORAL_ADDRESS ?? 'localhost:7233';

    const connection = await Connection.connect({ address });
    this.client = new Client({ connection });

    this.logger.log(`Connected to Temporal at ${address}`);
  }

  getClient(): Client {
    return this.client;
  }

  // ── Flow Graph Workflow Methods ─────────────────────────────────────

  async startFlowGraphWorkflow(input: {
    flowInstanceId: string;
    flowDefinitionId: string;
    graph: FlowNode[];
    context: FlowContext;
    temporalWorkflowId: string;
  }): Promise<string> {
    const handle = await this.client.workflow.start(
      WORKFLOW_TYPES.EXECUTE_FLOW_GRAPH,
      {
        taskQueue: TASK_QUEUES.FLOW_EXECUTION,
        workflowId: input.temporalWorkflowId,
        args: [
          {
            flowInstanceId: input.flowInstanceId,
            flowDefinitionId: input.flowDefinitionId,
            graph: input.graph,
            context: input.context,
          },
        ],
      },
    );

    this.logger.log(
      `Started flow graph workflow ${input.temporalWorkflowId} (runId: ${handle.firstExecutionRunId})`,
    );

    return handle.firstExecutionRunId;
  }

  async sendHumanDecisionSignal(
    temporalWorkflowId: string,
    signal: {
      nodeId: string;
      action: string;
      comment?: string;
      data?: Record<string, any>;
    },
  ): Promise<void> {
    try {
      const handle = this.client.workflow.getHandle(temporalWorkflowId);
      await handle.signal('humanDecision', signal);
      this.logger.log(
        `Sent humanDecision signal to ${temporalWorkflowId}: node=${signal.nodeId}, action=${signal.action}`,
      );
    } catch (error) {
      if (error instanceof WorkflowNotFoundError) {
        throw new BadRequestException(
          `Workflow ${temporalWorkflowId} is already completed or terminated`,
        );
      }
      throw error;
    }
  }

  async cancelFlow(temporalWorkflowId: string, reason?: string): Promise<void> {
    try {
      const handle = this.client.workflow.getHandle(temporalWorkflowId);
      await handle.signal('cancelFlow', { reason });
      this.logger.log(
        `Sent cancelFlow signal to ${temporalWorkflowId}: reason=${reason ?? 'none'}`,
      );
    } catch (error) {
      if (error instanceof WorkflowNotFoundError) {
        throw new BadRequestException(
          `Workflow ${temporalWorkflowId} is already completed or terminated`,
        );
      }
      throw error;
    }
  }

  async pauseFlow(temporalWorkflowId: string): Promise<void> {
    try {
      const handle = this.client.workflow.getHandle(temporalWorkflowId);
      await handle.signal('pauseFlow');
      this.logger.log(`Sent pauseFlow signal to ${temporalWorkflowId}`);
    } catch (error) {
      if (error instanceof WorkflowNotFoundError) {
        throw new BadRequestException(
          `Workflow ${temporalWorkflowId} is already completed or terminated`,
        );
      }
      throw error;
    }
  }

  async resumeFlow(temporalWorkflowId: string): Promise<void> {
    try {
      const handle = this.client.workflow.getHandle(temporalWorkflowId);
      await handle.signal('resumeFlow');
      this.logger.log(`Sent resumeFlow signal to ${temporalWorkflowId}`);
    } catch (error) {
      if (error instanceof WorkflowNotFoundError) {
        throw new BadRequestException(
          `Workflow ${temporalWorkflowId} is already completed or terminated`,
        );
      }
      throw error;
    }
  }

  async queryFlowStatus(
    temporalWorkflowId: string,
  ): Promise<FlowStatusResult | null> {
    try {
      const handle = this.client.workflow.getHandle(temporalWorkflowId);
      return await handle.query<FlowStatusResult>('getFlowStatus');
    } catch (error) {
      if (error instanceof WorkflowNotFoundError) {
        return null;
      }
      throw error;
    }
  }
}
