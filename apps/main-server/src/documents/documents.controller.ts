import { Body, Controller, Post, Get, Param } from '@nestjs/common';
import { DocumentsService } from './documents.service';
import { DocumentWorkflowService } from './document-workflow.service';
import type { InsertDocument } from '@workflow/database';

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
    private readonly documentWorkflowService: DocumentWorkflowService,
  ) {}

  @Post('submit')
  async submitDocument(@Body() dto: SubmitDocumentDto) {
    const doc = await this.documentsService.create(dto);
    const blueprint = this.documentsService.buildGovernmentBlueprint();

    const { workflowId } =
      await this.documentWorkflowService.startGovernmentDocumentWorkflow({
        documentId: doc.id,
        blueprint,
        authorId: dto.authorId,
      });

    return {
      documentId: doc.id,
      workflowId,
      status: 'SUBMITTED',
    };
  }

  @Post(':id/action')
  async performAction(@Param('id') documentId: string, @Body() dto: ActionDto) {
    await this.documentWorkflowService.performAction(
      documentId,
      dto.action,
      dto.comment,
    );
    return { status: 'ACTION_RECORDED', action: dto.action };
  }

  @Get(':id/status')
  async getStatus(@Param('id') documentId: string) {
    return this.documentWorkflowService.getStatus(documentId);
  }

  @Get(':id/audit')
  async getAuditTrail(@Param('id') documentId: string) {
    return this.documentsService.getAuditLogs(documentId);
  }
}
