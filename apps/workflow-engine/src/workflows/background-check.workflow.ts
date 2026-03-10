import {
  proxyActivities,
  defineSignal,
  defineQuery,
  setHandler,
  condition,
} from '@temporalio/workflow';

import type * as integrationActivities from '../activities/integration.activities';
import type { PollingConfig, EventHandlerAction } from '@workflow/database';

// ── Types ────────────────────────────────────────────────────────────────────

interface BackgroundCheckInput {
  backgroundCheckId: string;
  pinpp?: string;
  tin?: string;
  searchCriteria: Record<string, unknown>;
  integrationSettingIds: string[];
}

interface IntegrationResult {
  methodName: string;
  status: 'success' | 'failed' | 'api_failure' | 'pending';
  data?: Record<string, unknown>;
  error?: string;
  integrationId?: string;
  settingId?: string;
  recordIds?: string[];
}

interface BackgroundCheckProgress {
  backgroundCheckId: string;
  status: string;
  totalIntegrations: number;
  completedCount: number;
  failedCount: number;
  pendingCount: number;
  integrationResults: Array<{
    methodName: string;
    status: string;
    error?: string;
  }>;
}

/** Subset of DB row fields used by the workflow */
interface IntegrationSettingRow {
  id: string;
  methodName: string;
  httpMethod: string;
  endpoint: string;
  baseUrl: string | null;
  defaultBody: Record<string, unknown> | null;
  defaultHeaders: Record<string, unknown> | null;
  timeout: number;
  requiresAuth: boolean;
  pollingConfig: PollingConfig | null;
  responseMapping: Record<string, string> | null;
  parentId: string | null;
}

// ── Signals ──────────────────────────────────────────────────────────────────

export const cancelBackgroundCheckSignal = defineSignal(
  'cancelBackgroundCheck',
);
export const retryFailedIntegrationsSignal = defineSignal(
  'retryFailedIntegrations',
);

// ── Queries ──────────────────────────────────────────────────────────────────

export const getBackgroundCheckProgressQuery =
  defineQuery<BackgroundCheckProgress>('getBackgroundCheckProgress');

// ── Activities ───────────────────────────────────────────────────────────────

const {
  updateBackgroundCheck,
  loadActiveIntegrationSettings,
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
// MAIN WORKFLOW — Background Check Orchestrator
// ═══════════════════════════════════════════════════════════════════════════════

export async function backgroundCheckOrchestrator(input: BackgroundCheckInput) {
  const { backgroundCheckId, pinpp, searchCriteria, integrationSettingIds } =
    input;

  // ── Local state ──────────────────────────────────────────────────────────

  let cancellationRequested = false;
  let retryRequested = false;
  let overallStatus = 'submitted';

  const integrationResults: Map<string, IntegrationResult> = new Map();

  // ── Signal handlers ──────────────────────────────────────────────────────

  setHandler(cancelBackgroundCheckSignal, () => {
    cancellationRequested = true;
  });

  setHandler(retryFailedIntegrationsSignal, () => {
    retryRequested = true;
  });

  // ── Query handler ────────────────────────────────────────────────────────

  setHandler(getBackgroundCheckProgressQuery, (): BackgroundCheckProgress => {
    const results = Array.from(integrationResults.values());
    const completedCount = results.filter((r) => r.status === 'success').length;
    const failedCount = results.filter(
      (r) => r.status === 'failed' || r.status === 'api_failure',
    ).length;
    const pendingCount = results.filter((r) => r.status === 'pending').length;

    return {
      backgroundCheckId,
      status: overallStatus,
      totalIntegrations: results.length,
      completedCount,
      failedCount,
      pendingCount,
      integrationResults: results.map((r) => ({
        methodName: r.methodName,
        status: r.status,
        error: r.error,
      })),
    };
  });

  // ── Step 1: Mark as submitted ────────────────────────────────────────────

  await updateBackgroundCheck({
    id: backgroundCheckId,
    status: 'submitted',
    submittedAt: new Date(),
  });

  // ── Step 2: Load integration settings ────────────────────────────────────

  if (cancellationRequested) {
    await handleCancellation(backgroundCheckId);
    return buildResult();
  }

  const settings = (await loadActiveIntegrationSettings({
    settingIds: integrationSettingIds,
  })) as IntegrationSettingRow[];

  // ── Step 3: Get auth token ───────────────────────────────────────────────

  if (cancellationRequested) {
    await handleCancellation(backgroundCheckId);
    return buildResult();
  }

  const authToken = await getOrRefreshEgovToken({
    serviceName: 'egov_main',
  });

  // ── Step 4: Group settings into root and child ───────────────────────────

  const rootSettings = settings.filter((s) => !s.parentId);
  const childSettingsByParent = new Map<string, IntegrationSettingRow[]>();

  for (const setting of settings) {
    if (setting.parentId) {
      const children = childSettingsByParent.get(setting.parentId) || [];
      children.push(setting);
      childSettingsByParent.set(setting.parentId, children);
    }
  }

  // Initialize all integrations as pending
  for (const setting of settings) {
    integrationResults.set(setting.id, {
      methodName: setting.methodName,
      status: 'pending',
      settingId: setting.id,
    });
  }

  // ── Step 5: Execute root integrations in parallel ────────────────────────

  if (cancellationRequested) {
    await handleCancellation(backgroundCheckId);
    return buildResult();
  }

  await executeIntegrations(rootSettings, childSettingsByParent);

  // ── Step 6: Check for retry signal (loop) ────────────────────────────────

  while (retryRequested) {
    retryRequested = false;

    if (cancellationRequested) {
      await handleCancellation(backgroundCheckId);
      return buildResult();
    }

    const failedSettings = settings.filter((s) => {
      const result = integrationResults.get(s.id);
      return (
        result &&
        (result.status === 'failed' || result.status === 'api_failure')
      );
    });

    if (failedSettings.length > 0) {
      const failedRootSettings = failedSettings.filter((s) => !s.parentId);
      const failedChildByParent = new Map<string, IntegrationSettingRow[]>();
      for (const s of failedSettings) {
        if (s.parentId) {
          const children = failedChildByParent.get(s.parentId) || [];
          children.push(s);
          failedChildByParent.set(s.parentId, children);
        }
      }

      await executeIntegrations(failedRootSettings, failedChildByParent);
    }
  }

  // ── Step 7: Update to processing, store external results ─────────────────

  if (cancellationRequested) {
    await handleCancellation(backgroundCheckId);
    return buildResult();
  }

  overallStatus = 'processing';

  const allResults = Array.from(integrationResults.values());
  const externalServiceResults: Record<string, unknown> = {
    integrations: allResults.map((r) => ({
      methodName: r.methodName,
      status: r.status,
      data: r.data,
      error: r.error,
    })),
  };

  await updateBackgroundCheck({
    id: backgroundCheckId,
    status: 'processing',
    externalServiceResults,
    processingCompletedAt: new Date(),
  });

  // ── Step 8: Process event handlers for successful results ────────────────

  if (cancellationRequested) {
    await handleCancellation(backgroundCheckId);
    return buildResult();
  }

  const successfulResults = allResults.filter(
    (r) => r.status === 'success' && r.data,
  );

  for (const integrationResult of successfulResults) {
    try {
      const handlers = await loadMatchingEventHandlers({
        sourceSystem: 'orchestrator',
        event: integrationResult.methodName,
      });

      const collectedRecordIds: string[] = [];

      for (const handler of handlers) {
        const handlerActions = (handler as { actions: EventHandlerAction[] })
          .actions;

        const pipelineResult = await processEventHandlerPipeline({
          handler: { actions: handlerActions },
          integrationResult: integrationResult.data ?? {},
          pinpp: pinpp || '',
        });

        if (pipelineResult?.processedRecordIds) {
          collectedRecordIds.push(...pipelineResult.processedRecordIds);
        }
      }

      if (collectedRecordIds.length > 0 && integrationResult.integrationId) {
        await updateIntegrationRecordIds({
          integrationId: integrationResult.integrationId,
          recordIds: collectedRecordIds,
        });

        // Update local state
        const existing = integrationResults.get(integrationResult.settingId!);
        if (existing) {
          existing.recordIds = collectedRecordIds;
        }
      }
    } catch {
      // Individual event handler failures should not fail the workflow
    }
  }

  // ── Step 9: Update to mapping ────────────────────────────────────────────

  if (cancellationRequested) {
    await handleCancellation(backgroundCheckId);
    return buildResult();
  }

  overallStatus = 'mapping';

  const mappedData: Record<string, unknown> = {
    results: allResults
      .filter((r) => r.status === 'success')
      .map((r) => ({
        methodName: r.methodName,
        data: r.data,
        recordIds: r.recordIds,
      })),
  };

  await updateBackgroundCheck({
    id: backgroundCheckId,
    status: 'mapping',
    mappedData,
    mappingCompletedAt: new Date(),
  });

  // ── Step 10: Final status ────────────────────────────────────────────────

  const retrySignalReceived = await condition(() => retryRequested, 1000);

  if (retrySignalReceived && retryRequested) {
    retryRequested = false;

    const failedSettings = settings.filter((s) => {
      const result = integrationResults.get(s.id);
      return (
        result &&
        (result.status === 'failed' || result.status === 'api_failure')
      );
    });

    if (failedSettings.length > 0) {
      const failedRootSettings = failedSettings.filter((s) => !s.parentId);
      const failedChildByParent = new Map<string, IntegrationSettingRow[]>();
      for (const s of failedSettings) {
        if (s.parentId) {
          const children = failedChildByParent.get(s.parentId) || [];
          children.push(s);
          failedChildByParent.set(s.parentId, children);
        }
      }

      await executeIntegrations(failedRootSettings, failedChildByParent);
    }
  }

  if (cancellationRequested) {
    await handleCancellation(backgroundCheckId);
    return buildResult();
  }

  const finalResults = Array.from(integrationResults.values());
  const allFailed = finalResults.every(
    (r) => r.status === 'failed' || r.status === 'api_failure',
  );

  overallStatus = allFailed ? 'failed' : 'completed';

  await updateBackgroundCheck({
    id: backgroundCheckId,
    status: overallStatus,
    completedAt: new Date(),
  });

  return buildResult();

  // ═══════════════════════════════════════════════════════════════════════════
  // Inner helper: Execute a batch of integrations
  // ═══════════════════════════════════════════════════════════════════════════

  async function executeIntegrations(
    roots: IntegrationSettingRow[],
    childrenByParent: Map<string, IntegrationSettingRow[]>,
  ): Promise<void> {
    const rootPromises = roots.map(async (rootSetting) => {
      try {
        if (cancellationRequested) return;

        // Create integration record in DB — returns the ID string
        const integrationId = await createIntegrationRecord({
          requestId: backgroundCheckId,
          integrationSettingId: rootSetting.id,
          methodName: rootSetting.methodName,
          pinpp: pinpp,
          searchCriteria: searchCriteria,
        });

        // Execute the HTTP call
        const callResult = await executeIntegrationCall({
          integrationId,
          setting: {
            methodName: rootSetting.methodName,
            httpMethod: rootSetting.httpMethod,
            endpoint: rootSetting.endpoint,
            baseUrl: rootSetting.baseUrl,
            defaultBody: rootSetting.defaultBody,
            defaultHeaders: rootSetting.defaultHeaders,
            timeout: rootSetting.timeout,
            requiresAuth: rootSetting.requiresAuth,
            pollingConfig: rootSetting.pollingConfig,
            responseMapping: rootSetting.responseMapping,
          },
          searchCriteria: searchCriteria,
          token: authToken,
        });

        // Track result in local state
        integrationResults.set(rootSetting.id, {
          methodName: rootSetting.methodName,
          status: callResult.status as IntegrationResult['status'],
          data: callResult.rawData,
          error: callResult.errorMessage,
          integrationId,
          settingId: rootSetting.id,
        });

        // Execute children sequentially after parent succeeds
        if (callResult.status === 'success') {
          const children = childrenByParent.get(rootSetting.id) || [];
          for (const childSetting of children) {
            if (cancellationRequested) break;

            try {
              const childIntegrationId = await createIntegrationRecord({
                requestId: backgroundCheckId,
                integrationSettingId: childSetting.id,
                methodName: childSetting.methodName,
                pinpp: pinpp,
                searchCriteria: searchCriteria,
              });

              const childCallResult = await executeIntegrationCall({
                integrationId: childIntegrationId,
                setting: {
                  methodName: childSetting.methodName,
                  httpMethod: childSetting.httpMethod,
                  endpoint: childSetting.endpoint,
                  baseUrl: childSetting.baseUrl,
                  defaultBody: childSetting.defaultBody,
                  defaultHeaders: childSetting.defaultHeaders,
                  timeout: childSetting.timeout,
                  requiresAuth: childSetting.requiresAuth,
                  pollingConfig: childSetting.pollingConfig,
                  responseMapping: childSetting.responseMapping,
                },
                searchCriteria: searchCriteria,
                parentResponse: callResult.rawData,
                token: authToken,
              });

              integrationResults.set(childSetting.id, {
                methodName: childSetting.methodName,
                status: childCallResult.status as IntegrationResult['status'],
                data: childCallResult.rawData,
                error: childCallResult.errorMessage,
                integrationId: childIntegrationId,
                settingId: childSetting.id,
              });
            } catch (childError) {
              integrationResults.set(childSetting.id, {
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
      } catch (error) {
        integrationResults.set(rootSetting.id, {
          methodName: rootSetting.methodName,
          status: 'failed',
          error: error instanceof Error ? error.message : String(error),
          settingId: rootSetting.id,
        });
      }
    });

    await Promise.allSettled(rootPromises);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Inner helper: Handle cancellation
  // ═══════════════════════════════════════════════════════════════════════════

  async function handleCancellation(checkId: string): Promise<void> {
    overallStatus = 'failed';
    await updateBackgroundCheck({
      id: checkId,
      status: 'failed',
      errorMessage: 'cancelled',
      completedAt: new Date(),
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Inner helper: Build final return value
  // ═══════════════════════════════════════════════════════════════════════════

  function buildResult() {
    const results = Array.from(integrationResults.values());
    return {
      backgroundCheckId,
      status: overallStatus,
      totalIntegrations: results.length,
      completedCount: results.filter((r) => r.status === 'success').length,
      failedCount: results.filter(
        (r) => r.status === 'failed' || r.status === 'api_failure',
      ).length,
      integrationResults: results,
    };
  }
}
