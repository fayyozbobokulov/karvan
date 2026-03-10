import { eq } from 'drizzle-orm';
import {
  eventHandlers,
  type EventHandlerTrigger,
  type EventHandlerAction,
  type SelectEventHandler,
} from '@workflow/database';
import { getDb } from './db';
import { getByPath } from './helpers';
import { upsertRecord, listRecords } from './records.activities';

export async function loadMatchingEventHandlers(input: {
  sourceSystem: string;
  event: string;
}): Promise<SelectEventHandler[]> {
  const database = getDb();

  const handlers = await database
    .select()
    .from(eventHandlers)
    .where(eq(eventHandlers.isActive, true));

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

export async function processEventHandlerPipeline(input: {
  handler: { actions: EventHandlerAction[] };
  integrationResult: Record<string, unknown>;
  pinpp: string;
}): Promise<{ processedRecordIds: string[] }> {
  const processedRecordIds: string[] = [];
  let currentData: Record<string, unknown> = { ...input.integrationResult };

  for (const action of input.handler.actions) {
    const { name, settings } = action;

    switch (name) {
      case 'basic.transformJson': {
        const mapping = (settings.mapping || settings.pipeline) as
          | Record<string, string>
          | undefined;
        if (mapping) {
          const transformed: Record<string, unknown> = {};
          for (const [targetField, sourcePath] of Object.entries(mapping)) {
            transformed[targetField] = getByPath(currentData, sourcePath);
          }
          currentData = transformed;
        }
        break;
      }

      case 'basic.validateJson': {
        const schema = settings.schema as Record<string, unknown> | undefined;
        if (schema) {
          const requiredFields = (schema.required as string[]) || [];
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
            data: item as Record<string, unknown>,
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
        currentData = { records: listedRecords };
        break;
      }

      default:
        console.warn(`[EVENT_HANDLER] Unknown action: ${name}, skipping`);
    }
  }

  return { processedRecordIds };
}
