export type HttpMethod = "get" | "post" | "put" | "delete" | "patch";

/** Configuration injected from the host application — no process.env in this package. */
export interface IntegrationConfig {
  /** Default base URL for all eGov API calls (e.g. "https://apimgw.egov.uz:8243") */
  baseUrl: string;
}

export interface IntegrationToken {
  accessToken: string;
  tokenType: string;
}

export interface IntegrationSettingConfig {
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

export interface PollingConfig {
  intervalMs: number;
  maxAttempts: number;
  successCondition?: string;
}

export interface IntegrationRequest {
  methodName: string;
  searchCriteria: Record<string, unknown>;
  parentResponse?: Record<string, unknown>;
  token?: IntegrationToken;
  setting: IntegrationSettingConfig;
}

export interface IntegrationResponse {
  success: boolean;
  code: number | null;
  message: string;
  data: Record<string, unknown> | unknown[] | null;
  raw: Record<string, unknown>;
}

export type IntegrationErrorStatus =
  | "api_failure"
  | "unauthorized"
  | "not_found"
  | "params_missing"
  | "timeout";

export interface IntegrationError {
  status: IntegrationErrorStatus;
  message: string;
  code: string | null;
  raw?: unknown;
}

export interface IntegrationCallResult {
  status: "success" | IntegrationErrorStatus;
  response?: IntegrationResponse;
  error?: IntegrationError;
  rawHttpData?: Record<string, unknown>;
}

export interface IntegrationServiceMeta {
  supportedMethods: string[];
  serviceName: string;
  category: string;
}
