import { eq } from 'drizzle-orm';
import {
  backgroundChecks,
  backgroundCheckBatches,
  type BackgroundCheckStatus,
} from '@workflow/database';
import { getDb } from './db';

export async function updateBackgroundCheck(input: {
  id: string;
  status?: BackgroundCheckStatus;
  errorMessage?: string;
  errorStage?: 'external_services' | 'mapping' | 'upsert';
  externalServiceResults?: Record<string, unknown>;
  mappedData?: Record<string, unknown>;
  recordsUpsertResult?: Record<string, unknown>;
  submittedAt?: Date;
  processingCompletedAt?: Date;
  mappingCompletedAt?: Date;
  completedAt?: Date;
}) {
  const database = getDb();

  const updates: Partial<typeof backgroundChecks.$inferInsert> = {
    updatedAt: new Date(),
  };

  if (input.status) updates.status = input.status;
  if (input.errorMessage) updates.errorMessage = input.errorMessage;
  if (input.errorStage) updates.errorStage = input.errorStage;
  if (input.externalServiceResults)
    updates.externalServiceResults = input.externalServiceResults;
  if (input.mappedData) updates.mappedData = input.mappedData;
  if (input.recordsUpsertResult)
    updates.recordsUpsertResult = input.recordsUpsertResult;
  if (input.submittedAt) updates.submittedAt = input.submittedAt;
  if (input.processingCompletedAt)
    updates.processingCompletedAt = input.processingCompletedAt;
  if (input.mappingCompletedAt)
    updates.mappingCompletedAt = input.mappingCompletedAt;
  if (input.completedAt) updates.completedAt = input.completedAt;

  await database
    .update(backgroundChecks)
    .set(updates)
    .where(eq(backgroundChecks.id, input.id));
}

export async function syncBatchCounts(input: { batchId: string }) {
  const database = getDb();

  const checks = await database
    .select({ status: backgroundChecks.status })
    .from(backgroundChecks)
    .where(eq(backgroundChecks.batchId, input.batchId));

  const counts: Record<string, number> = {
    pending: 0,
    submitted: 0,
    processing: 0,
    mapping: 0,
    completed: 0,
    failed: 0,
  };

  for (const check of checks) {
    if (check.status in counts) {
      counts[check.status]++;
    }
  }

  const totalItems = checks.length;

  let batchStatus: string = 'processing';
  if (totalItems === 0) {
    batchStatus = 'pending';
  } else if (counts.completed === totalItems) {
    batchStatus = 'completed';
  } else if (counts.failed === totalItems) {
    batchStatus = 'failed';
  } else if (counts.completed + counts.failed === totalItems) {
    batchStatus = 'partial';
  }

  const batchUpdates: Partial<typeof backgroundCheckBatches.$inferInsert> = {
    totalItems,
    pendingCount: counts.pending,
    submittedCount: counts.submitted,
    processingCount: counts.processing + counts.mapping,
    completedCount: counts.completed,
    failedCount: counts.failed,
    status: batchStatus as typeof backgroundCheckBatches.$inferInsert.status,
    updatedAt: new Date(),
  };

  if (
    batchStatus === 'completed' ||
    batchStatus === 'failed' ||
    batchStatus === 'partial'
  ) {
    batchUpdates.completedAt = new Date();
  }

  await database
    .update(backgroundCheckBatches)
    .set(batchUpdates)
    .where(eq(backgroundCheckBatches.id, input.batchId));
}
