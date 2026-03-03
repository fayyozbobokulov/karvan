import { Module } from '@nestjs/common';
import { DatabaseModule } from '@workflow/database';
import { DocumentsController } from './documents.controller';
import { DocumentsService } from './documents.service';
import { DocumentWorkflowService } from './document-workflow.service';

@Module({
  imports: [DatabaseModule],
  controllers: [DocumentsController],
  providers: [DocumentsService, DocumentWorkflowService],
  exports: [DocumentsService, DocumentWorkflowService],
})
export class DocumentsModule {}
