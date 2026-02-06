import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { eq } from 'drizzle-orm';
import {
  DRIZZLE,
  documents,
  type InsertDocument,
  type SelectDocument,
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
}
