import {
  Injectable,
  Logger,
  OnModuleInit,
  BadRequestException,
} from '@nestjs/common';
import { Client, Connection, WorkflowNotFoundError } from '@temporalio/client';
import { TASK_QUEUES, WORKFLOW_TYPES } from '@workflow/database';

export interface BackgroundCheckProgressResult {
  backgroundCheckId: string;
  status: string;
  totalIntegrations: number;
  completedIntegrations: number;
  failedIntegrations: number;
  pendingIntegrations: number;
  integrationDetails: Array<{
    integrationSettingId: string;
    methodName: string;
    status: string;
    errorMessage?: string;
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

  // ── Background Check Workflow Methods ───────────────────────────────

  async startBackgroundCheckWorkflow(input: {
    backgroundCheckId: string;
    pinpp?: string;
    tin?: string;
    searchCriteria: Record<string, any>;
    integrationSettingIds: string[];
    temporalWorkflowId: string;
  }): Promise<string> {
    const handle = await this.client.workflow.start(
      WORKFLOW_TYPES.BACKGROUND_CHECK_ORCHESTRATOR,
      {
        taskQueue: TASK_QUEUES.INTEGRATION_PROCESSING,
        workflowId: input.temporalWorkflowId,
        args: [
          {
            backgroundCheckId: input.backgroundCheckId,
            pinpp: input.pinpp,
            tin: input.tin,
            searchCriteria: input.searchCriteria,
            integrationSettingIds: input.integrationSettingIds,
          },
        ],
      },
    );

    this.logger.log(
      `Started background check workflow ${input.temporalWorkflowId} (runId: ${handle.firstExecutionRunId})`,
    );

    return handle.firstExecutionRunId;
  }

  async cancelBackgroundCheck(temporalWorkflowId: string): Promise<void> {
    try {
      const handle = this.client.workflow.getHandle(temporalWorkflowId);
      await handle.signal('cancelBackgroundCheck');
      this.logger.log(
        `Sent cancelBackgroundCheck signal to ${temporalWorkflowId}`,
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

  async retryFailedIntegrations(temporalWorkflowId: string): Promise<void> {
    try {
      const handle = this.client.workflow.getHandle(temporalWorkflowId);
      await handle.signal('retryFailedIntegrations');
      this.logger.log(
        `Sent retryFailedIntegrations signal to ${temporalWorkflowId}`,
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

  async queryBackgroundCheckProgress(
    temporalWorkflowId: string,
  ): Promise<BackgroundCheckProgressResult | null> {
    try {
      const handle = this.client.workflow.getHandle(temporalWorkflowId);
      return await handle.query<BackgroundCheckProgressResult>(
        'getBackgroundCheckProgress',
      );
    } catch (error) {
      if (error instanceof WorkflowNotFoundError) {
        return null;
      }
      throw error;
    }
  }
}
