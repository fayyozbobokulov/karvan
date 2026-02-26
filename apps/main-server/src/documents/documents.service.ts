import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { eq, desc } from 'drizzle-orm';
import {
  DRIZZLE,
  documents,
  tasks,
  auditLogs,
  type InsertDocument,
  type SelectDocument,
  type SelectTask,
} from '@workflow/database';
import type { NodePgDatabase } from 'drizzle-orm/node-postgres';
import type * as schema from '@workflow/database';
import { TemporalService } from '../temporal/temporal.service';

@Injectable()
export class DocumentsService {
  constructor(
    @Inject(DRIZZLE) private readonly db: NodePgDatabase<typeof schema>,
    private readonly temporalService: TemporalService,
  ) {}

  async create(data: {
    title: string;
    authorId: string;
    fileUrl: string;
    metadata: any;
  }): Promise<SelectDocument> {
    const [document] = await this.db
      .insert(documents)
      .values({
        title: data.title,
        authorId: data.authorId,
        fileUrl: data.fileUrl,
        metadata: data.metadata,
        mimeType: 'application/pdf',
        status: 'pending',
      })
      .returning();

    return document as SelectDocument;
  }

  buildGovernmentBlueprint(approvalLevels?: string[]): any {
    return {
      workflowId: 'gov-doc-exchange',
      version: '1.0',
      steps: [{ type: 'automatic', id: 'validate' }],
    };
  }

  async getAuditLogs(documentId: string) {
    return await this.db
      .select()
      .from(auditLogs)
      .where(eq(auditLogs.documentId, documentId))
      .orderBy(desc(auditLogs.createdAt));
  }
}
