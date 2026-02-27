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
  type SelectDocument,
  type FlowNode,
  type FlowContext,
} from '@workflow/database';

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

  async startDocumentWorkflow(document: SelectDocument): Promise<string> {
    const workflowId = `document-${document.id}`;

    const handle = await this.client.workflow.start(
      WORKFLOW_TYPES.DOCUMENT_PROCESSING,
      {
        taskQueue: TASK_QUEUES.DOCUMENT_PROCESSING,
        workflowId,
        args: [document],
      },
    );

    this.logger.log(
      `Started workflow ${workflowId} (runId: ${handle.firstExecutionRunId})`,
    );

    return handle.firstExecutionRunId;
  }

  async startDynamicWorkflow(
    document: SelectDocument,
    blueprint: any,
  ): Promise<string> {
    const workflowId = `gov-document-${document.id}`;

    const handle = await this.client.workflow.start('dynamicWorkflow', {
      taskQueue: TASK_QUEUES.DOCUMENT_PROCESSING,
      workflowId,
      args: [document, blueprint],
    });

    this.logger.log(
      `Started dynamic workflow ${workflowId} (runId: ${handle.firstExecutionRunId})`,
    );

    return handle.firstExecutionRunId;
  }

  async sendActionSignal(
    workflowId: string,
    signalName: 'sign' | 'reject',
    data: any,
  ): Promise<void> {
    const handle = this.client.workflow.getHandle(workflowId);
    await handle.signal(signalName, data);
    this.logger.log(`Sent signal "${signalName}" to workflow ${workflowId}`);
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

  async queryFlowStatus(temporalWorkflowId: string): Promise<any> {
    try {
      const handle = this.client.workflow.getHandle(temporalWorkflowId);
      return await handle.query('getFlowStatus');
    } catch (error) {
      if (error instanceof WorkflowNotFoundError) {
        return null;
      }
      throw error;
    }
  }
}
