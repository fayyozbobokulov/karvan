import {
  Body,
  Controller,
  Post,
  Get,
  Param,
  BadRequestException,
} from '@nestjs/common';
import { DocumentsService } from './documents.service';
import { TemporalService } from '../temporal/temporal.service';
import { TASK_QUEUES, type InsertDocument } from '@workflow/database';

class SubmitDocumentDto {
  title!: string;
  authorId!: string;
  fileUrl!: string;
  metadata?: InsertDocument['metadata'];
  approvalLevels?: string[];
}

class ActionDto {
  action!: string;
  comment?: string;
}

@Controller('documents')
export class DocumentsController {
  constructor(
    private readonly documentsService: DocumentsService,
    private readonly temporalClient: TemporalService,
  ) {}

  @Post('submit')
  async submitDocument(@Body() dto: SubmitDocumentDto) {
    const doc = await this.documentsService.create(dto);
    const blueprint = this.documentsService.buildGovernmentBlueprint();

    const handle = await this.temporalClient
      .getClient()
      .workflow.start('governmentDocumentWorkflow', {
        taskQueue: TASK_QUEUES.DOCUMENT_PROCESSING,
        workflowId: `gov-doc-${doc.id}`,
        args: [
          {
            documentId: doc.id,
            blueprint,
            authorId: dto.authorId,
          },
        ],
      });

    return {
      documentId: doc.id,
      workflowId: handle.workflowId,
      status: 'SUBMITTED',
    };
  }

  @Post(':id/action')
  async performAction(@Param('id') documentId: string, @Body() dto: ActionDto) {
    const handle = this.temporalClient
      .getClient()
      .workflow.getHandle(`gov-doc-${documentId}`);

    const status = await handle.query<{ currentStage: string }>('getStatus');

    switch (status.currentStage) {
      case 'in_review':
        await handle.signal('reviewDecision', {
          action: dto.action,
          comment: dto.comment,
        });
        break;
      case 'in_approval':
        await handle.signal('approvalDecision', {
          action: dto.action,
          comment: dto.comment,
        });
        break;
      case 'awaiting_signature':
        await handle.signal('signDecision', { action: dto.action });
        break;
      default:
        throw new BadRequestException(
          `Cannot perform action in stage: ${status.currentStage}`,
        );
    }

    return { status: 'ACTION_RECORDED', action: dto.action };
  }

  @Get(':id/status')
  async getStatus(@Param('id') documentId: string) {
    const handle = this.temporalClient
      .getClient()
      .workflow.getHandle(`gov-doc-${documentId}`);

    return await handle.query('getStatus');
  }

  @Get(':id/audit')
  async getAuditTrail(@Param('id') documentId: string) {
    return this.documentsService.getAuditLogs(documentId);
  }
}
