import {
  proxyActivities,
  startChild,
  setHandler,
  condition,
} from '@temporalio/workflow';

import type * as integrationActivities from '../../activities/integration/index';
import { integrationExecution } from './integration-execution.workflow';
import {
  type BackgroundCheckInput,
  type BackgroundCheckProgress,
  type IntegrationResult,
  type IntegrationSettingRow,
  type IntegrationExecutionResult,
  cancelBackgroundCheckSignal,
  retryFailedIntegrationsSignal,
  retryIntegrationSignal,
  getBackgroundCheckProgressQuery,
} from './types';
import { TASK_QUEUES } from '@workflow/database';

// ── Activities (only status updates — everything else is in child workflows) ─

const { updateBackgroundCheck, loadActiveIntegrationSettings } =
  proxyActivities<typeof integrationActivities>({
    startToCloseTimeout: '2 minutes',
    retry: { maximumAttempts: 3 },
  });

// ── Constants ────────────────────────────────────────────────────────────────

const MAX_CONCURRENT_INTEGRATIONS = 10;

// ═══════════════════════════════════════════════════════════════════════════════
// PARENT WORKFLOW — Background Check Orchestrator
// ═══════════════════════════════════════════════════════════════════════════════

export async function backgroundCheckOrchestrator(input: BackgroundCheckInput) {
  const { backgroundCheckId, pinpp, searchCriteria, integrationSettingIds } =
    input;

  // ── Local state ──────────────────────────────────────────────────────────

  let cancellationRequested = false;
  let retryRequested = false;
  let retrySettingId: string | null = null;
  let overallStatus = 'submitted';

  const integrationResults = new Map<string, IntegrationResult>();

  // ── Signal handlers ──────────────────────────────────────────────────────

  setHandler(cancelBackgroundCheckSignal, () => {
    cancellationRequested = true;
  });

  setHandler(retryFailedIntegrationsSignal, () => {
    retryRequested = true;
  });

  setHandler(retryIntegrationSignal, (payload) => {
    retrySettingId = payload.settingId;
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

  if (cancellationRequested) return handleCancellation();

  const allSettings = (await loadActiveIntegrationSettings({
    settingIds: integrationSettingIds,
  })) as IntegrationSettingRow[];

  // ── Step 3: Group settings into root + children ──────────────────────────

  if (cancellationRequested) return handleCancellation();

  const { groups } = groupSettings(allSettings);

  // Initialize all integrations as pending
  for (const setting of allSettings) {
    integrationResults.set(setting.id, {
      methodName: setting.methodName,
      status: 'pending',
      settingId: setting.id,
    });
  }

  // ── Step 4: Execute integration groups as child workflows ────────────────

  if (cancellationRequested) return handleCancellation();

  overallStatus = 'processing';
  await updateBackgroundCheck({
    id: backgroundCheckId,
    status: 'processing',
  });

  await executeChildWorkflows(groups);

  // ── Step 5: Handle retry loop ────────────────────────────────────────────

  while (retryRequested) {
    retryRequested = false;
    const targetSettingId = retrySettingId;
    retrySettingId = null;

    if (cancellationRequested) return handleCancellation();

    const failedGroups = groups.filter((g) => {
      if (targetSettingId) {
        return g.rootSetting.id === targetSettingId;
      }
      const result = integrationResults.get(g.rootSetting.id);
      return (
        result &&
        (result.status === 'failed' || result.status === 'api_failure')
      );
    });

    if (failedGroups.length > 0) {
      await executeChildWorkflows(failedGroups);
    }
  }

  // ── Step 6: Aggregate and store results ──────────────────────────────────

  if (cancellationRequested) return handleCancellation();

  const allResults = Array.from(integrationResults.values());

  overallStatus = 'mapping';
  await updateBackgroundCheck({
    id: backgroundCheckId,
    status: 'mapping',
    externalServiceResults: {
      integrations: allResults.map((r) => ({
        methodName: r.methodName,
        status: r.status,
        data: r.data,
        error: r.error,
      })),
    },
    mappedData: {
      results: allResults
        .filter((r) => r.status === 'success')
        .map((r) => ({
          methodName: r.methodName,
          data: r.data,
          recordIds: r.recordIds,
        })),
    },
    processingCompletedAt: new Date(),
    mappingCompletedAt: new Date(),
  });

  // ── Step 7: Brief window for late retry signals ──────────────────────────

  const retrySignalReceived = await condition(() => retryRequested, 1000);

  if (retrySignalReceived && retryRequested) {
    retryRequested = false;
    const targetSettingId = retrySettingId;
    retrySettingId = null;

    const failedGroups = groups.filter((g) => {
      if (targetSettingId) return g.rootSetting.id === targetSettingId;
      const result = integrationResults.get(g.rootSetting.id);
      return (
        result &&
        (result.status === 'failed' || result.status === 'api_failure')
      );
    });

    if (failedGroups.length > 0) {
      await executeChildWorkflows(failedGroups);
    }
  }

  // ── Step 8: Final status ─────────────────────────────────────────────────

  if (cancellationRequested) return handleCancellation();

  const finalResults = Array.from(integrationResults.values());
  const allFailed = finalResults.every(
    (r) => r.status === 'failed' || r.status === 'api_failure',
  );

  overallStatus = allFailed ? 'failed' : 'completed';

  await updateBackgroundCheck({
    id: backgroundCheckId,
    status: overallStatus as 'completed' | 'failed',
    completedAt: new Date(),
  });

  return buildResult();

  // ═══════════════════════════════════════════════════════════════════════════
  // Inner helpers
  // ═══════════════════════════════════════════════════════════════════════════

  interface IntegrationGroup {
    rootSetting: IntegrationSettingRow;
    childSettings: IntegrationSettingRow[];
  }

  function groupSettings(settings: IntegrationSettingRow[]) {
    const childrenByParent = new Map<string, IntegrationSettingRow[]>();
    for (const s of settings) {
      if (s.parentId) {
        const children = childrenByParent.get(s.parentId) || [];
        children.push(s);
        childrenByParent.set(s.parentId, children);
      }
    }

    const rootSettings = settings.filter((s) => !s.parentId);
    const result: IntegrationGroup[] = rootSettings.map((root) => ({
      rootSetting: root,
      childSettings: childrenByParent.get(root.id) || [],
    }));

    return { groups: result };
  }

  async function executeChildWorkflows(
    groupsToExecute: IntegrationGroup[],
  ): Promise<void> {
    let runningCount = 0;
    const promises: Promise<void>[] = [];

    for (const group of groupsToExecute) {
      if (cancellationRequested) break;

      // Semaphore: wait for a slot
      if (runningCount >= MAX_CONCURRENT_INTEGRATIONS) {
        await condition(
          () =>
            runningCount < MAX_CONCURRENT_INTEGRATIONS || cancellationRequested,
        );
      }
      if (cancellationRequested) break;

      runningCount++;

      const childPromise = (async () => {
        try {
          const handle = await startChild(integrationExecution, {
            args: [
              {
                backgroundCheckId,
                pinpp: pinpp || '',
                searchCriteria,
                rootSetting: group.rootSetting,
                childSettings: group.childSettings,
                serviceName: group.rootSetting.serviceName,
              },
            ],
            workflowId: `bg-${backgroundCheckId}-${group.rootSetting.id}`,
            taskQueue: TASK_QUEUES.INTEGRATION_PROCESSING,
            retry: {
              maximumAttempts: 3,
              initialInterval: '10s',
              backoffCoefficient: 2,
            },
          });

          const result: IntegrationExecutionResult = await handle.result();

          // Merge child workflow results into parent state
          applyGroupResult(group, result);
        } catch (error) {
          // Child workflow failed entirely
          integrationResults.set(group.rootSetting.id, {
            methodName: group.rootSetting.methodName,
            status: 'failed',
            error: error instanceof Error ? error.message : String(error),
            settingId: group.rootSetting.id,
          });
          for (const child of group.childSettings) {
            integrationResults.set(child.id, {
              methodName: child.methodName,
              status: 'failed',
              error: 'Parent workflow failed',
              settingId: child.id,
            });
          }
        } finally {
          runningCount--;
        }
      })();

      promises.push(childPromise);
    }

    await Promise.allSettled(promises);
  }

  function applyGroupResult(
    group: IntegrationGroup,
    result: IntegrationExecutionResult,
  ) {
    integrationResults.set(group.rootSetting.id, result.rootResult);

    for (const childResult of result.childResults) {
      if (childResult.settingId) {
        integrationResults.set(childResult.settingId, childResult);
      }
    }
  }

  async function handleCancellation() {
    overallStatus = 'failed';
    await updateBackgroundCheck({
      id: backgroundCheckId,
      status: 'failed',
      errorMessage: 'cancelled',
      completedAt: new Date(),
    });
    return buildResult();
  }

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
