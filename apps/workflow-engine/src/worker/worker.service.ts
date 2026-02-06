import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { NativeConnection, Worker } from '@temporalio/worker';
import { TASK_QUEUES } from '@workflow/database';
import * as activities from '../activities/document.activities';

@Injectable()
export class WorkerService implements OnModuleInit {
  private readonly logger = new Logger(WorkerService.name);

  async onModuleInit() {
    const address = process.env.TEMPORAL_ADDRESS ?? 'localhost:7233';

    const connection = await NativeConnection.connect({ address });

    const worker = await Worker.create({
      connection,
      namespace: 'default',
      taskQueue: TASK_QUEUES.DOCUMENT_PROCESSING,
      workflowsPath: require.resolve('../workflows/document.workflow'),
      activities,
    });

    this.logger.log(
      `Worker started on task queue "${TASK_QUEUES.DOCUMENT_PROCESSING}"`,
    );

    // Run worker in background — don't block NestJS bootstrap
    void worker.run();
  }
}
