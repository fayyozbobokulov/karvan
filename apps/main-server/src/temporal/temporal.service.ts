import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { Client, Connection } from '@temporalio/client';
import {
  TASK_QUEUES,
  WORKFLOW_TYPES,
  type SelectDocument,
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
}
