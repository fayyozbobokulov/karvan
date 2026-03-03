import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { WorkflowNotFoundError } from '@temporalio/client';
import { TemporalService } from '../temporal/temporal.service';
import { TASK_QUEUES } from '@workflow/database';

export interface DocumentWorkflowStatus {
  currentStage: string;
  documentId: string;
  history: Array<{ stage: string; action: string; timestamp: string }>;
}

@Injectable()
export class DocumentWorkflowService {
  private readonly logger = new Logger(DocumentWorkflowService.name);

  constructor(private readonly temporalService: TemporalService) {}

  private getWorkflowId(documentId: string): string {
    return `gov-doc-${documentId}`;
  }

  async startGovernmentDocumentWorkflow(input: {
    documentId: string;
    blueprint: Record<string, unknown>;
    authorId: string;
  }): Promise<{ workflowId: string; runId: string }> {
    const workflowId = this.getWorkflowId(input.documentId);

    const handle = await this.temporalService
      .getClient()
      .workflow.start('governmentDocumentWorkflow', {
        taskQueue: TASK_QUEUES.DOCUMENT_PROCESSING,
        workflowId,
        args: [input],
      });

    this.logger.log(
      `Started government document workflow ${workflowId} (runId: ${handle.firstExecutionRunId})`,
    );

    return { workflowId, runId: handle.firstExecutionRunId };
  }

  async getStatus(documentId: string): Promise<DocumentWorkflowStatus> {
    const workflowId = this.getWorkflowId(documentId);
    try {
      const handle = this.temporalService
        .getClient()
        .workflow.getHandle(workflowId);
      return await handle.query<DocumentWorkflowStatus>('getStatus');
    } catch (error) {
      if (error instanceof WorkflowNotFoundError) {
        throw new BadRequestException(
          `Workflow for document ${documentId} not found or already completed`,
        );
      }
      throw error;
    }
  }

  async performAction(
    documentId: string,
    action: string,
    comment?: string,
  ): Promise<void> {
    const workflowId = this.getWorkflowId(documentId);
    const handle = this.temporalService
      .getClient()
      .workflow.getHandle(workflowId);

    const status = await handle.query<{ currentStage: string }>('getStatus');

    switch (status.currentStage) {
      case 'in_review':
        await handle.signal('reviewDecision', { action, comment });
        break;
      case 'in_approval':
        await handle.signal('approvalDecision', { action, comment });
        break;
      case 'awaiting_signature':
        await handle.signal('signDecision', { action });
        break;
      default:
        throw new BadRequestException(
          `Cannot perform action in stage: ${status.currentStage}`,
        );
    }

    this.logger.log(
      `Sent action "${action}" for document ${documentId} in stage ${status.currentStage}`,
    );
  }
}
