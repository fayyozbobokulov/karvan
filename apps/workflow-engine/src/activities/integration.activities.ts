import { eq, and, inArray } from 'drizzle-orm';
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import axios from 'axios';
import {
  integrationSettings,
  backgroundChecks,
  backgroundCheckBatches,
  integrations,
  egovTokens,
  recordTypes,
  records,
  recordHistory,
  eventHandlers,
  type EventHandlerTrigger,
  type PollingConfig,
} from '@workflow/database';

// ---------------------------------------------------------------------------
// Singleton DB connection (same pattern as unit.activities.ts)
// ---------------------------------------------------------------------------

let db: ReturnType<typeof drizzle> | null = null;

function getDb() {
  if (!db) {
    const pool = new Pool({
      connectionString: process.env.DATABASE_URL,
    });
    db = drizzle(pool);
  }
  return db;
}

// ---------------------------------------------------------------------------
// Helper — Resolve a dot-notation path from an object
// ---------------------------------------------------------------------------

function getByPath(obj: Record<string, any>, path: string): any {
  return path.split('.').reduce((acc, key) => {
    if (acc == null) return undefined;
    return acc[key];
  }, obj as any);
}

// ---------------------------------------------------------------------------
// Helper — Walk a JSON tree and replace $placeholder tokens
// ---------------------------------------------------------------------------

function replacePlaceholders(
  template: any,
  searchCriteria: Record<string, any>,
): any {
  if (typeof template === 'string' && template.startsWith('$')) {
    const path = template.slice(1); // remove leading $
    return getByPath(searchCriteria, path) ?? template;
  }
  if (Array.isArray(template)) {
    return template.map((item) => replacePlaceholders(item, searchCriteria));
  }
  if (template !== null && typeof template === 'object') {
    const result: Record<string, any> = {};
    for (const [key, value] of Object.entries(template)) {
      result[key] = replacePlaceholders(value, searchCriteria);
    }
    return result;
  }
  return template;
}

// ---------------------------------------------------------------------------
// 1. getOrRefreshEgovToken — Check/refresh OAuth2 token
// ---------------------------------------------------------------------------

export async function getOrRefreshEgovToken(input: {
  serviceName: string;
}): Promise<{ accessToken: string; tokenType: string }> {
  const database = getDb();

  // Check for an active, non-expired token (with 5-minute buffer)
  const bufferMs = 5 * 60 * 1000;
  const now = new Date();
  const bufferDate = new Date(now.getTime() + bufferMs);

  const [existing] = await database
    .select()
    .from(egovTokens)
    .where(
      and(
        eq(egovTokens.serviceName, input.serviceName),
        eq(egovTokens.isActive, true),
      ),
    )
    .limit(1);

  if (existing && existing.accessTokenExpiresAt > bufferDate) {
    return {
      accessToken: existing.accessToken,
      tokenType: existing.tokenType,
    };
  }

  // Token expired or missing — request a new one
  const tokenUrl = process.env.EGOV_TOKEN_URL!;
  const consumerKey = process.env.EGOV_CONSUMER_KEY!;
  const consumerSecret = process.env.EGOV_CONSUMER_SECRET!;
  const username = process.env.EGOV_USERNAME!;
  const password = process.env.EGOV_PASSWORD!;

  const basicAuth = Buffer.from(`${consumerKey}:${consumerSecret}`).toString(
    'base64',
  );

  const response = await axios.post(
    tokenUrl,
    new URLSearchParams({
      grant_type: 'password',
      username,
      password,
    }).toString(),
    {
      headers: {
        Authorization: `Basic ${basicAuth}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    },
  );

  const { access_token, expires_in, token_type } = response.data;

  // Deactivate old tokens for this service
  if (existing) {
    await database
      .update(egovTokens)
      .set({ isActive: false, updatedAt: new Date() })
      .where(
        and(
          eq(egovTokens.serviceName, input.serviceName),
          eq(egovTokens.isActive, true),
        ),
      );
  }

  // Insert the new token
  const expiresAt = new Date(now.getTime() + expires_in * 1000);

  await database.insert(egovTokens).values({
    serviceName: input.serviceName,
    accessToken: access_token,
    accessTokenExpiresAt: expiresAt,
    expiresIn: expires_in,
    tokenType: token_type || 'Bearer',
    isActive: true,
    metadata: { refreshedAt: now.toISOString() },
  });

  return {
    accessToken: access_token,
    tokenType: token_type || 'Bearer',
  };
}

// ---------------------------------------------------------------------------
// 2. loadActiveIntegrationSettings — Load settings (sorted parent-first)
// ---------------------------------------------------------------------------

export async function loadActiveIntegrationSettings(input: {
  settingIds?: string[];
}) {
  const database = getDb();

  let rows: (typeof integrationSettings.$inferSelect)[];

  if (input.settingIds && input.settingIds.length > 0) {
    rows = await database
      .select()
      .from(integrationSettings)
      .where(inArray(integrationSettings.id, input.settingIds));
  } else {
    rows = await database
      .select()
      .from(integrationSettings)
      .where(
        and(
          eq(integrationSettings.isActive, true),
          eq(integrationSettings.isAvailable, true),
        ),
      );
  }

  // Topological sort: parents before children
  const idSet = new Set(rows.map((r) => r.id));
  const sorted: typeof rows = [];
  const visited = new Set<string>();

  function visit(id: string) {
    if (visited.has(id)) return;
    visited.add(id);
    const row = rows.find((r) => r.id === id);
    if (!row) return;
    // Visit parent first if it's in our set
    if (row.parentId && idSet.has(row.parentId)) {
      visit(row.parentId);
    }
    sorted.push(row);
  }

  for (const row of rows) {
    visit(row.id);
  }

  return sorted;
}

// ---------------------------------------------------------------------------
// 3. createIntegrationRecord — Insert pending integration row
// ---------------------------------------------------------------------------

export async function createIntegrationRecord(input: {
  requestId: string;
  integrationSettingId: string;
  methodName: string;
  pinpp?: string;
  searchCriteria?: Record<string, any>;
  requestBody?: Record<string, any>;
}): Promise<string> {
  const database = getDb();

  const [row] = await database
    .insert(integrations)
    .values({
      requestId: input.requestId,
      integrationSettingId: input.integrationSettingId,
      methodName: input.methodName,
      status: 'pending',
      pinpp: input.pinpp || null,
      searchCriteria: input.searchCriteria || null,
      requestBody: input.requestBody || null,
    })
    .returning();

  return row.id;
}

// ---------------------------------------------------------------------------
// 4. executeIntegrationCall — Core HTTP call with placeholder replacement
// ---------------------------------------------------------------------------

export async function executeIntegrationCall(input: {
  integrationId: string;
  setting: {
    methodName: string;
    httpMethod: string;
    endpoint: string;
    baseUrl?: string | null;
    defaultBody?: Record<string, any> | null;
    defaultHeaders?: Record<string, any> | null;
    timeout: number;
    requiresAuth: boolean;
    pollingConfig?: PollingConfig | null;
    responseMapping?: Record<string, string> | null;
  };
  searchCriteria: Record<string, any>;
  parentResponse?: Record<string, any>;
  token?: { accessToken: string; tokenType: string };
}): Promise<{
  integrationId: string;
  status: string;
  rawData?: Record<string, any>;
  errorMessage?: string;
}> {
  const database = getDb();
  const { setting, searchCriteria, parentResponse, token } = input;

  try {
    // Build request body from template
    let requestBody: any = setting.defaultBody
      ? replacePlaceholders(setting.defaultBody, searchCriteria)
      : {};

    // If parentResponse and responseMapping exist, map parent fields to request
    if (parentResponse && setting.responseMapping) {
      for (const [targetField, sourcePath] of Object.entries(
        setting.responseMapping,
      )) {
        const value = getByPath(parentResponse, sourcePath);
        if (value !== undefined) {
          requestBody[targetField] = value;
        }
      }
    }

    // Build URL
    const baseUrl = setting.baseUrl || process.env.EGOV_API_BASE_URL || '';
    const url = `${baseUrl}${setting.endpoint}`;

    // Build headers
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...(setting.defaultHeaders || {}),
    };

    if (setting.requiresAuth && token) {
      headers['Authorization'] = `${token.tokenType} ${token.accessToken}`;
    }

    // Update status to running
    await database
      .update(integrations)
      .set({ status: 'running', updatedAt: new Date() })
      .where(eq(integrations.id, input.integrationId));

    // Make the HTTP call
    const axiosConfig = {
      method: setting.httpMethod.toLowerCase() as any,
      url,
      headers,
      timeout: setting.timeout,
      ...(setting.httpMethod.toUpperCase() !== 'GET'
        ? { data: requestBody }
        : { params: requestBody }),
    };

    let response = await axios(axiosConfig);

    // Handle polling if configured
    if (setting.pollingConfig) {
      const { intervalMs, maxAttempts, successCondition } =
        setting.pollingConfig;

      for (let attempt = 0; attempt < maxAttempts; attempt++) {
        // Check success condition
        if (successCondition) {
          const conditionMet = getByPath(response.data, successCondition);
          if (conditionMet) break;
        } else {
          // If no condition specified, any 2xx is success
          break;
        }

        // Wait before next poll
        await new Promise((resolve) => setTimeout(resolve, intervalMs));

        // Re-issue the same request
        response = await axios(axiosConfig);
      }
    }

    // Success — update integration record
    await database
      .update(integrations)
      .set({
        status: 'success',
        rawData: response.data,
        requestBody,
        updatedAt: new Date(),
      })
      .where(eq(integrations.id, input.integrationId));

    return {
      integrationId: input.integrationId,
      status: 'success',
      rawData: response.data,
    };
  } catch (error: any) {
    // Determine failure status
    let status: string = 'api_failure';
    let errorMessage = error.message || 'Unknown error';
    let errorCode: string | null = null;

    if (axios.isAxiosError(error)) {
      if (error.response) {
        const statusCode = error.response.status;
        if (statusCode === 401 || statusCode === 403) {
          status = 'unauthorized';
        } else if (statusCode === 404) {
          status = 'not_found';
        } else {
          status = 'api_failure';
        }
        errorCode = String(statusCode);
        errorMessage =
          error.response.data?.message ||
          error.response.statusText ||
          errorMessage;
      } else if (error.code === 'ECONNABORTED') {
        status = 'timeout';
      }
    }

    await database
      .update(integrations)
      .set({
        status: status as any,
        errorMessage,
        errorCode,
        updatedAt: new Date(),
      })
      .where(eq(integrations.id, input.integrationId));

    return {
      integrationId: input.integrationId,
      status,
      errorMessage,
    };
  }
}

// ---------------------------------------------------------------------------
// 5. updateBackgroundCheck — Update background check row
// ---------------------------------------------------------------------------

export async function updateBackgroundCheck(input: {
  id: string;
  status?: string;
  errorMessage?: string;
  errorStage?: string;
  externalServiceResults?: Record<string, any>;
  mappedData?: Record<string, any>;
  recordsUpsertResult?: Record<string, any>;
  submittedAt?: Date;
  processingCompletedAt?: Date;
  mappingCompletedAt?: Date;
  completedAt?: Date;
}) {
  const database = getDb();

  const updates: Partial<typeof backgroundChecks.$inferInsert> = {
    updatedAt: new Date(),
  };

  if (input.status) updates.status = input.status as any;
  if (input.errorMessage) updates.errorMessage = input.errorMessage;
  if (input.errorStage) updates.errorStage = input.errorStage as any;
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

// ---------------------------------------------------------------------------
// 6. syncBatchCounts — Count checks per status, update batch row
// ---------------------------------------------------------------------------

export async function syncBatchCounts(input: { batchId: string }) {
  const database = getDb();

  // Load all checks for this batch
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

  // Determine batch status
  let batchStatus: string = 'processing';
  if (totalItems === 0) {
    batchStatus = 'pending';
  } else if (counts.completed === totalItems) {
    batchStatus = 'completed';
  } else if (counts.failed === totalItems) {
    batchStatus = 'failed';
  } else if (counts.completed + counts.failed === totalItems) {
    // All finished, but some failed
    batchStatus = 'partial';
  }

  const batchUpdates: Partial<typeof backgroundCheckBatches.$inferInsert> = {
    totalItems,
    pendingCount: counts.pending,
    submittedCount: counts.submitted,
    processingCount: counts.processing + counts.mapping,
    completedCount: counts.completed,
    failedCount: counts.failed,
    status: batchStatus as any,
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

// ---------------------------------------------------------------------------
// 7. loadMatchingEventHandlers — Find handlers by sourceSystem + event
// ---------------------------------------------------------------------------

export async function loadMatchingEventHandlers(input: {
  sourceSystem: string;
  event: string;
}) {
  const database = getDb();

  // Load all active event handlers
  const handlers = await database
    .select()
    .from(eventHandlers)
    .where(eq(eventHandlers.isActive, true));

  // Filter by matching triggers (triggers is a JSONB array)
  return handlers.filter((handler) => {
    const triggers = handler.triggers as EventHandlerTrigger[];
    if (!Array.isArray(triggers)) return false;
    return triggers.some(
      (trigger) =>
        trigger.sourceSystem === input.sourceSystem &&
        trigger.event === input.event,
    );
  });
}

// ---------------------------------------------------------------------------
// 8. processEventHandlerPipeline — Execute handler actions sequentially
// ---------------------------------------------------------------------------

export async function processEventHandlerPipeline(input: {
  handler: {
    actions: Array<{ name: string; settings: Record<string, any> }>;
  };
  integrationResult: Record<string, any>;
  pinpp: string;
}): Promise<{ processedRecordIds: string[] }> {
  const processedRecordIds: string[] = [];
  let currentData: Record<string, any> = { ...input.integrationResult };

  for (const action of input.handler.actions) {
    const { name, settings } = action;

    switch (name) {
      case 'basic.transformJson': {
        // Apply field mapping: settings.mapping is Record<targetField, sourcePath>
        const mapping = (settings.mapping || settings.pipeline) as Record<
          string,
          string
        >;
        if (mapping) {
          const transformed: Record<string, any> = {};
          for (const [targetField, sourcePath] of Object.entries(mapping)) {
            transformed[targetField] = getByPath(currentData, sourcePath);
          }
          currentData = transformed;
        }
        break;
      }

      case 'basic.validateJson': {
        // Simple schema validation — check required fields exist
        const schema = settings.schema as Record<string, any> | undefined;
        if (schema) {
          const requiredFields = (schema.required || []) as string[];
          const missing = requiredFields.filter(
            (field) =>
              currentData[field] === undefined || currentData[field] === null,
          );
          if (missing.length > 0 && settings.ifInvalid === 'skip') {
            return { processedRecordIds };
          }
        }
        break;
      }

      case 'records.upsert': {
        const recordTypeId = settings.recordTypeId as string;
        if (!recordTypeId) break;

        const items = Array.isArray(currentData) ? currentData : [currentData];
        for (const item of items) {
          const recordId = await upsertRecord({
            recordTypeId,
            pinpp: input.pinpp,
            data: item,
            createdBy: settings.createdBy as string | undefined,
          });
          processedRecordIds.push(recordId);
        }
        break;
      }

      case 'records.list': {
        const listedRecords = await listRecords({
          pinpp: input.pinpp,
          recordTypeId: settings.recordTypeId as string | undefined,
        });
        // Store the listed records as current data for subsequent transforms
        currentData = { records: listedRecords } as any;
        break;
      }

      default:
        console.warn(`[EVENT_HANDLER] Unknown action: ${name}, skipping`);
    }
  }

  return { processedRecordIds };
}

// ---------------------------------------------------------------------------
// 9. upsertRecord — Insert or update a record
// ---------------------------------------------------------------------------

export async function upsertRecord(input: {
  recordTypeId: string;
  pinpp: string;
  data: Record<string, any>;
  userId?: string;
  createdBy?: string;
}): Promise<string> {
  const database = getDb();

  // Load record type
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
    // Check for existing record by (pinpp, recordTypeId)
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
      // Merge data and update
      const mergedData = { ...existing.data, ...input.data };
      await database
        .update(records)
        .set({
          data: mergedData,
          updatedAt: new Date(),
        })
        .where(eq(records.id, existing.id));

      recordId = existing.id;
      action = 'updated';
    } else {
      // Insert new
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
    // allowMultiple — always insert
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

  // Insert history entry
  await database.insert(recordHistory).values({
    recordId,
    recordTypeId: input.recordTypeId,
    action,
    data: input.data,
    createdBy: input.createdBy || null,
  });

  return recordId;
}

// ---------------------------------------------------------------------------
// 10. listRecords — Query records by pinpp with optional recordTypeId filter
// ---------------------------------------------------------------------------

export async function listRecords(input: {
  pinpp: string;
  recordTypeId?: string;
}) {
  const database = getDb();

  const conditions = [eq(records.pinpp, input.pinpp)];
  if (input.recordTypeId) {
    conditions.push(eq(records.recordTypeId, input.recordTypeId));
  }

  const rows = await database
    .select()
    .from(records)
    .where(and(...conditions));

  return rows;
}

// ---------------------------------------------------------------------------
// 11. updateIntegrationRecordIds — Set recordIds and mark completed
// ---------------------------------------------------------------------------

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
