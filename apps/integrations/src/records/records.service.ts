import { Inject, Injectable, Logger, NotFoundException } from '@nestjs/common';
import { eq, desc, and, sql, type SQL } from 'drizzle-orm';
import {
  DRIZZLE,
  records,
  recordTypes,
  recordHistory,
  type InsertRecordType,
} from '@workflow/database';
import type { NodePgDatabase } from 'drizzle-orm/node-postgres';
import type * as schema from '@workflow/database';

@Injectable()
export class RecordsService {
  private readonly logger = new Logger(RecordsService.name);

  constructor(
    @Inject(DRIZZLE) private readonly db: NodePgDatabase<typeof schema>,
  ) {}

  // ── List records with filters ──────────────────────────────────────────

  async findAll(filters: {
    pinpp?: string;
    recordTypeId?: string;
    limit?: number;
    offset?: number;
  }) {
    const conditions: SQL[] = [];

    if (filters.pinpp) {
      conditions.push(eq(records.pinpp, filters.pinpp));
    }
    if (filters.recordTypeId) {
      conditions.push(eq(records.recordTypeId, filters.recordTypeId));
    }

    const results = await this.db
      .select({
        record: records,
        recordType: recordTypes,
      })
      .from(records)
      .innerJoin(recordTypes, eq(records.recordTypeId, recordTypes.id))
      .where(conditions.length > 0 ? and(...conditions) : undefined)
      .orderBy(desc(records.createdAt))
      .limit(filters.limit ?? 50)
      .offset(filters.offset ?? 0);

    const [countResult] = await this.db
      .select({ count: sql<number>`count(*)` })
      .from(records)
      .where(conditions.length > 0 ? and(...conditions) : undefined);

    return {
      data: results.map((r) => ({
        ...r.record,
        recordTypeName: r.recordType.name,
        recordTypeIcon: r.recordType.icon,
      })),
      total: Number(countResult.count),
      limit: filters.limit ?? 50,
      offset: filters.offset ?? 0,
    };
  }

  // ── Get a single record with history ───────────────────────────────────

  async findOne(id: string) {
    const [result] = await this.db
      .select({
        record: records,
        recordType: recordTypes,
      })
      .from(records)
      .innerJoin(recordTypes, eq(records.recordTypeId, recordTypes.id))
      .where(eq(records.id, id));

    if (!result) {
      throw new NotFoundException(`Record not found: ${id}`);
    }

    const history = await this.getRecordHistory(id);

    return {
      ...result.record,
      recordTypeName: result.recordType.name,
      recordTypeIcon: result.recordType.icon,
      history,
    };
  }

  // ── Get all records for a person by pinpp ──────────────────────────────

  async findByPinpp(pinpp: string) {
    const results = await this.db
      .select({
        record: records,
        recordType: recordTypes,
      })
      .from(records)
      .innerJoin(recordTypes, eq(records.recordTypeId, recordTypes.id))
      .where(eq(records.pinpp, pinpp))
      .orderBy(desc(records.createdAt));

    return results.map((r) => ({
      ...r.record,
      recordTypeName: r.recordType.name,
      recordTypeIcon: r.recordType.icon,
    }));
  }

  // ── Get record history ─────────────────────────────────────────────────

  async getRecordHistory(recordId: string) {
    return await this.db
      .select()
      .from(recordHistory)
      .where(eq(recordHistory.recordId, recordId))
      .orderBy(desc(recordHistory.createdAt));
  }

  // ── List all record types ──────────────────────────────────────────────

  async findAllRecordTypes() {
    return await this.db.select().from(recordTypes).orderBy(recordTypes.name);
  }

  // ── Get a single record type ───────────────────────────────────────────

  async findOneRecordType(id: string) {
    const [recordType] = await this.db
      .select()
      .from(recordTypes)
      .where(eq(recordTypes.id, id));

    if (!recordType) {
      throw new NotFoundException(`Record type not found: ${id}`);
    }

    return recordType;
  }

  // ── Create a new record type ───────────────────────────────────────────

  async createRecordType(input: InsertRecordType) {
    const [recordType] = await this.db
      .insert(recordTypes)
      .values(input)
      .returning();

    this.logger.log(`Created record type ${recordType.id}: ${recordType.name}`);

    return recordType;
  }

  // ── Update a record type ───────────────────────────────────────────────

  async updateRecordType(id: string, input: Partial<InsertRecordType>) {
    const [existing] = await this.db
      .select()
      .from(recordTypes)
      .where(eq(recordTypes.id, id));

    if (!existing) {
      throw new NotFoundException(`Record type not found: ${id}`);
    }

    const [updated] = await this.db
      .update(recordTypes)
      .set({ ...input, updatedAt: new Date() })
      .where(eq(recordTypes.id, id))
      .returning();

    this.logger.log(`Updated record type ${id}`);

    return updated;
  }
}
