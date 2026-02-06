export const TASK_QUEUES = {
  DOCUMENT_PROCESSING: "document-processing",
} as const;

export const WORKFLOW_TYPES = {
  DOCUMENT_PROCESSING: "documentProcessingWorkflow",
} as const;

export const DOCUMENT_STATUS = {
  PENDING: "pending",
  PROCESSING: "processing",
  COMPLETED: "completed",
  FAILED: "failed",
} as const;

export type DocumentStatus =
  (typeof DOCUMENT_STATUS)[keyof typeof DOCUMENT_STATUS];
