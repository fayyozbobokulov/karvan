import { defineSignal, defineQuery } from '@temporalio/workflow';
import type {
  SelectIntegrationSetting,
  PollingConfig,
} from '@workflow/database';

// ── Derived types from DB schema ─────────────────────────────────────────────

/** Fields from SelectIntegrationSetting needed by workflows */
export type IntegrationSettingRow = Pick<
  SelectIntegrationSetting,
  | 'id'
  | 'methodName'
  | 'httpMethod'
  | 'endpoint'
  | 'baseUrl'
  | 'defaultBody'
  | 'defaultHeaders'
  | 'timeout'
  | 'requiresAuth'
  | 'pollingConfig'
  | 'responseMapping'
  | 'parentId'
  | 'serviceName'
  | 'delayMs'
>;

// ── Workflow I/O types ───────────────────────────────────────────────────────

export interface BackgroundCheckInput {
  backgroundCheckId: string;
  pinpp?: string;
  tin?: string;
  searchCriteria: Record<string, unknown>;
  integrationSettingIds: string[];
}

export interface IntegrationResult {
  methodName: string;
  status: 'success' | 'failed' | 'api_failure' | 'pending';
  data?: Record<string, unknown>;
  error?: string;
  integrationId?: string;
  settingId?: string;
  recordIds?: string[];
}

export interface BackgroundCheckProgress {
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

/** Input for child workflow — one root integration + its children */
export interface IntegrationExecutionInput {
  backgroundCheckId: string;
  pinpp: string;
  searchCriteria: Record<string, unknown>;
  rootSetting: IntegrationSettingRow;
  childSettings: IntegrationSettingRow[];
  serviceName: string;
}

export interface IntegrationExecutionResult {
  rootResult: IntegrationResult;
  childResults: IntegrationResult[];
  eventHandlerRecordIds: Record<string, string[]>;
}

// ── Setting param for executeIntegrationCall activity ────────────────────────

export interface SettingParam {
  methodName: string;
  httpMethod: string;
  endpoint: string;
  baseUrl?: string | null;
  defaultBody?: Record<string, unknown> | null;
  defaultHeaders?: Record<string, unknown> | null;
  timeout: number;
  requiresAuth: boolean;
  pollingConfig?: PollingConfig | null;
  responseMapping?: Record<string, string> | null;
}

// ── Signals ──────────────────────────────────────────────────────────────────

export const cancelBackgroundCheckSignal = defineSignal(
  'cancelBackgroundCheck',
);
export const retryFailedIntegrationsSignal = defineSignal(
  'retryFailedIntegrations',
);
export const retryIntegrationSignal =
  defineSignal<[{ settingId: string }]>('retryIntegration');

// ── Queries ──────────────────────────────────────────────────────────────────

export const getBackgroundCheckProgressQuery =
  defineQuery<BackgroundCheckProgress>('getBackgroundCheckProgress');
