import { eq, and } from 'drizzle-orm';
import {
  recordTypes,
  records,
  recordHistory,
  integrations,
} from '@workflow/database';
import { getDb } from './db';

export async function upsertRecord(input: {
  recordTypeId: string;
  pinpp: string;
  data: Record<string, unknown>;
  userId?: string;
  createdBy?: string;
}): Promise<string> {
  const database = getDb();

  const [recType] = await database
    .select()
    .from(recordTypes)
    .where(eq(recordTypes.id, input.recordTypeId));

  if (!recType) {
    throw new Error(`Record type not found: ${input.recordTypeId}`);
  }

  if (!recType.isEnabled) {
    throw new Error(`Record type is disabled: ${input.recordTypeId}`);
  }

  let recordId: string;
  let action: 'created' | 'updated';

  if (!recType.allowMultiple) {
    const [existing] = await database
      .select()
      .from(records)
      .where(
        and(
          eq(records.pinpp, input.pinpp),
          eq(records.recordTypeId, input.recordTypeId),
        ),
      )
      .limit(1);

    if (existing) {
      const mergedData = {
        ...(existing.data as Record<string, unknown>),
        ...input.data,
      };
      await database
        .update(records)
        .set({ data: mergedData, updatedAt: new Date() })
        .where(eq(records.id, existing.id));

      recordId = existing.id;
      action = 'updated';
    } else {
      const [newRecord] = await database
        .insert(records)
        .values({
          recordTypeId: input.recordTypeId,
          pinpp: input.pinpp,
          data: input.data,
          userId: input.userId || null,
          createdBy: input.createdBy || null,
        })
        .returning();

      recordId = newRecord.id;
      action = 'created';
    }
  } else {
    const [newRecord] = await database
      .insert(records)
      .values({
        recordTypeId: input.recordTypeId,
        pinpp: input.pinpp,
        data: input.data,
        userId: input.userId || null,
        createdBy: input.createdBy || null,
      })
      .returning();

    recordId = newRecord.id;
    action = 'created';
  }

  await database.insert(recordHistory).values({
    recordId,
    recordTypeId: input.recordTypeId,
    action,
    data: input.data,
    createdBy: input.createdBy || null,
  });

  return recordId;
}

export async function listRecords(input: {
  pinpp: string;
  recordTypeId?: string;
}) {
  const database = getDb();

  const conditions = [eq(records.pinpp, input.pinpp)];
  if (input.recordTypeId) {
    conditions.push(eq(records.recordTypeId, input.recordTypeId));
  }

  return database
    .select()
    .from(records)
    .where(and(...conditions));
}

export async function updateIntegrationRecordIds(input: {
  integrationId: string;
  recordIds: string[];
}) {
  const database = getDb();

  await database
    .update(integrations)
    .set({
      recordIds: input.recordIds,
      status: 'completed',
      updatedAt: new Date(),
    })
    .where(eq(integrations.id, input.integrationId));
}
