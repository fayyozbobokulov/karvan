import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { NativeConnection, Worker } from '@temporalio/worker';
import { TASK_QUEUES } from '@workflow/database';
import * as activities from '../activities';

@Injectable()
export class WorkerService implements OnModuleInit {
  private readonly logger = new Logger(WorkerService.name);

  async onModuleInit() {
    const address = process.env.TEMPORAL_ADDRESS ?? 'localhost:7233';

    const connection = await NativeConnection.connect({ address });

    // Existing worker for document processing (backward compatibility)
    const docWorker = await Worker.create({
      connection,
      namespace: 'default',
      taskQueue: TASK_QUEUES.DOCUMENT_PROCESSING,
      workflowsPath: require.resolve('../workflows'),
      activities,
    });

    this.logger.log(
      `Worker started on task queue "${TASK_QUEUES.DOCUMENT_PROCESSING}"`,
    );

    void docWorker.run();

    // New worker for flow execution (unit-based workflow engine)
    const flowWorker = await Worker.create({
      connection,
      namespace: 'default',
      taskQueue: TASK_QUEUES.FLOW_EXECUTION,
      workflowsPath: require.resolve('../workflows'),
      activities,
    });

    this.logger.log(
      `Worker started on task queue "${TASK_QUEUES.FLOW_EXECUTION}"`,
    );

    void flowWorker.run();
  }
}
