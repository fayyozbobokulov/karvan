export const TASK_QUEUES = {
  DOCUMENT_PROCESSING: "document-processing",
  FLOW_EXECUTION: "flow-execution",
} as const;

export const WORKFLOW_TYPES = {
  DOCUMENT_PROCESSING: "documentProcessingWorkflow",
  EXECUTE_FLOW_GRAPH: "executeFlowGraph",
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
