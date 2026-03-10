import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { NativeConnection, Worker } from '@temporalio/worker';
import { TASK_QUEUES } from '@workflow/database';
import * as docActivities from '../activities/document.activities';
import * as govActivities from '../activities/government.activities';
import * as unitActivities from '../activities/unit.activities';
import * as integrationActivities from '../activities/integration.activities';

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
      activities: { ...docActivities, ...govActivities },
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
      activities: { ...unitActivities, ...govActivities },
    });

    this.logger.log(
      `Worker started on task queue "${TASK_QUEUES.FLOW_EXECUTION}"`,
    );

    void flowWorker.run();

    // New worker for integration processing (background checks)
    const integrationWorker = await Worker.create({
      connection,
      namespace: 'default',
      taskQueue: TASK_QUEUES.INTEGRATION_PROCESSING,
      workflowsPath: require.resolve('../workflows'),
      activities: { ...integrationActivities },
    });

    this.logger.log(
      `Worker started on task queue "${TASK_QUEUES.INTEGRATION_PROCESSING}"`,
    );

    void integrationWorker.run();
  }
}
