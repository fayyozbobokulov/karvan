export const TASK_QUEUES = {
  DOCUMENT_PROCESSING: "document-processing",
  FLOW_EXECUTION: "flow-execution",
  INTEGRATION_PROCESSING: "integration-processing",
} as const;

export const WORKFLOW_TYPES = {
  DOCUMENT_PROCESSING: "documentProcessingWorkflow",
  EXECUTE_FLOW_GRAPH: "executeFlowGraph",
  BACKGROUND_CHECK_ORCHESTRATOR: "backgroundCheckOrchestrator",
} as const;

export const DOCUMENT_STATUS = {
  PENDING: "pending",
  PROCESSING: "processing",
  COMPLETED: "completed",
  FAILED: "failed",
} as const;

export type DocumentStatus =
  (typeof DOCUMENT_STATUS)[keyof typeof DOCUMENT_STATUS];

export const UNIT_TYPES = {
  DOCUMENT: "DOCUMENT",
  TASK: "TASK",
  ACTION: "ACTION",
  CONDITION: "CONDITION",
  NOTIFICATION: "NOTIFICATION",
  AUTOMATION: "AUTOMATION",
  GATE: "GATE",
  PARALLEL: "PARALLEL",
} as const;

export type UnitType = (typeof UNIT_TYPES)[keyof typeof UNIT_TYPES];

export const BACKGROUND_CHECK_STATUS = {
  PENDING: "pending",
  SUBMITTED: "submitted",
  PROCESSING: "processing",
  MAPPING: "mapping",
  COMPLETED: "completed",
  FAILED: "failed",
} as const;

export type BackgroundCheckStatus =
  (typeof BACKGROUND_CHECK_STATUS)[keyof typeof BACKGROUND_CHECK_STATUS];

export const INTEGRATION_STATUS = {
  PENDING: "pending",
  RUNNING: "running",
  SUCCESS: "success",
  COMPLETED: "completed",
  FAILED: "failed",
  SKIPPED: "skipped",
  API_FAILURE: "api_failure",
  UNAUTHORIZED: "unauthorized",
  NOT_FOUND: "not_found",
  PARAMS_MISSING: "params_missing",
  TIMEOUT: "timeout",
} as const;

export type IntegrationStatus =
  (typeof INTEGRATION_STATUS)[keyof typeof INTEGRATION_STATUS];
