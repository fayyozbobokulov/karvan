import { proxyActivities, sleep } from '@temporalio/workflow';

import type * as integrationActivities from '../../activities/integration/index';
import type { EventHandlerAction } from '@workflow/database';
import type {
  IntegrationExecutionInput,
  IntegrationExecutionResult,
  IntegrationResult,
  SettingParam,
} from './types';

// ── Activities ───────────────────────────────────────────────────────────────

const {
  getOrRefreshEgovToken,
  createIntegrationRecord,
  loadMatchingEventHandlers,
  processEventHandlerPipeline,
  updateIntegrationRecordIds,
} = proxyActivities<typeof integrationActivities>({
  startToCloseTimeout: '2 minutes',
  retry: { maximumAttempts: 3 },
});

const { executeIntegrationCall } = proxyActivities<
  typeof integrationActivities
>({
  startToCloseTimeout: '5 minutes',
  retry: { maximumAttempts: 2 },
});

// ═══════════════════════════════════════════════════════════════════════════════
// CHILD WORKFLOW — Execute one integration group (root + children)
// ═══════════════════════════════════════════════════════════════════════════════

export async function integrationExecution(
  input: IntegrationExecutionInput,
): Promise<IntegrationExecutionResult> {
  const {
    backgroundCheckId,
    pinpp,
    searchCriteria,
    rootSetting,
    childSettings,
    serviceName,
  } = input;

  const childResults: IntegrationResult[] = [];
  const eventHandlerRecordIds: Record<string, string[]> = {};

  // ── Execute root integration ───────────────────────────────────────────

  // Fresh token per child workflow (solves token expiry for long-running batches)
  const token = await getOrRefreshEgovToken({ serviceName });

  if (rootSetting.delayMs > 0) {
    await sleep(rootSetting.delayMs);
  }

  const integrationId = await createIntegrationRecord({
    requestId: backgroundCheckId,
    integrationSettingId: rootSetting.id,
    methodName: rootSetting.methodName,
    pinpp,
    searchCriteria,
  });

  const callResult = await executeIntegrationCall({
    integrationId,
    setting: toSettingParam(rootSetting),
    searchCriteria,
    token,
  });

  const rootResult: IntegrationResult = {
    methodName: rootSetting.methodName,
    status: callResult.status as IntegrationResult['status'],
    data: callResult.rawData,
    error: callResult.errorMessage,
    integrationId,
    settingId: rootSetting.id,
  };

  // ── Execute child integrations sequentially ────────────────────────────

  if (callResult.status === 'success') {
    for (const childSetting of childSettings) {
      // Re-fetch token before each child call (may have expired)
      const childToken = await getOrRefreshEgovToken({ serviceName });

      if (childSetting.delayMs > 0) {
        await sleep(childSetting.delayMs);
      }

      try {
        const childIntegrationId = await createIntegrationRecord({
          requestId: backgroundCheckId,
          integrationSettingId: childSetting.id,
          methodName: childSetting.methodName,
          pinpp,
          searchCriteria,
        });

        const childCallResult = await executeIntegrationCall({
          integrationId: childIntegrationId,
          setting: toSettingParam(childSetting),
          searchCriteria,
          parentResponse: callResult.rawData,
          token: childToken,
        });

        childResults.push({
          methodName: childSetting.methodName,
          status: childCallResult.status as IntegrationResult['status'],
          data: childCallResult.rawData,
          error: childCallResult.errorMessage,
          integrationId: childIntegrationId,
          settingId: childSetting.id,
        });
      } catch (childError) {
        childResults.push({
          methodName: childSetting.methodName,
          status: 'failed',
          error:
            childError instanceof Error
              ? childError.message
              : String(childError),
          settingId: childSetting.id,
        });
      }
    }
  }

  // ── Process event handlers for all successful results ──────────────────

  const allResults = [rootResult, ...childResults];

  for (const result of allResults) {
    if (result.status !== 'success' || !result.data) continue;

    try {
      const handlers = await loadMatchingEventHandlers({
        sourceSystem: 'orchestrator',
        event: result.methodName,
      });

      const recordIds: string[] = [];

      for (const handler of handlers) {
        const handlerActions = (handler as { actions: EventHandlerAction[] })
          .actions;

        const pipelineResult = await processEventHandlerPipeline({
          handler: { actions: handlerActions },
          integrationResult: result.data ?? {},
          pinpp: pinpp || '',
        });

        if (pipelineResult?.processedRecordIds) {
          recordIds.push(...pipelineResult.processedRecordIds);
        }
      }

      if (recordIds.length > 0 && result.integrationId) {
        await updateIntegrationRecordIds({
          integrationId: result.integrationId,
          recordIds,
        });
        result.recordIds = recordIds;
        eventHandlerRecordIds[result.settingId!] = recordIds;
      }
    } catch {
      // Individual handler failures should not fail the child workflow
    }
  }

  return { rootResult, childResults, eventHandlerRecordIds };
}

// ── Helper ───────────────────────────────────────────────────────────────────

function toSettingParam(
  row: IntegrationExecutionInput['rootSetting'],
): SettingParam {
  return {
    methodName: row.methodName,
    httpMethod: row.httpMethod,
    endpoint: row.endpoint,
    baseUrl: row.baseUrl,
    defaultBody: row.defaultBody,
    defaultHeaders: row.defaultHeaders,
    timeout: row.timeout,
    requiresAuth: row.requiresAuth,
    pollingConfig: row.pollingConfig,
    responseMapping: row.responseMapping,
  };
}
