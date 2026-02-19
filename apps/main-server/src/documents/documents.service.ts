import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { eq, desc } from 'drizzle-orm';
import {
  DRIZZLE,
  documents,
  tasks,
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

  async create(data: InsertDocument): Promise<SelectDocument> {
    const [document] = await this.db.insert(documents).values(data).returning();

    await this.temporalService.startDocumentWorkflow(
      document as SelectDocument,
    );

    return document as SelectDocument;
  }

  async createGovernmentScenario(data: {
    title: string;
    authorId: string;
    assigneeId: string;
  }): Promise<SelectDocument> {
    const [document] = await this.db
      .insert(documents)
      .values({
        title: data.title,
        authorId: data.authorId,
        fileUrl: 'http://example.com/doc.pdf',
        mimeType: 'application/pdf',
        status: 'pending',
      })
      .returning();

    const blueprint = {
      version: '1.0',
      steps: [
        {
          id: 'step1',
          type: 'assignment',
          config: { assigneeId: data.assigneeId, taskType: 'signing' },
          next: 'step2',
        },
        {
          id: 'step2',
          type: 'archive',
        },
      ],
    };

    await this.temporalService.startDynamicWorkflow(
      document as SelectDocument,
      blueprint,
    );

    return document as SelectDocument;
  }

  async handleAction(data: {
    documentId: string;
    taskId: string;
    action: 'sign' | 'reject';
    comment?: string;
  }): Promise<void> {
    const workflowId = `gov-document-${data.documentId}`;
    await this.temporalService.sendActionSignal(workflowId, data.action, {
      taskId: data.taskId,
      comment: data.comment,
    });
  }

  async findAll(): Promise<SelectDocument[]> {
    const results = await this.db.select().from(documents);
    return results as SelectDocument[];
  }

  async findById(id: string): Promise<SelectDocument> {
    const [document] = await this.db
      .select()
      .from(documents)
      .where(eq(documents.id, id));

    if (!document) {
      throw new NotFoundException(`Document with id "${id}" not found`);
    }

    return document as SelectDocument;
  }

  async findAllTasks(): Promise<SelectTask[]> {
    return (await this.db
      .select()
      .from(tasks)
      .orderBy(desc(tasks.createdAt))) as SelectTask[];
  }
}
