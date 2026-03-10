import {
  pgTable,
  text,
  timestamp,
  jsonb,
  integer,
  boolean,
  pgEnum,
  uuid,
} from "drizzle-orm/pg-core";
import { createSchemaFactory } from "drizzle-zod";
import { z } from "zod/v4";
import { v7 as uuidv7 } from "uuid";

const { createInsertSchema, createSelectSchema } = createSchemaFactory();

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

export const documentStatusEnum = pgEnum("document_status", [
  "draft",
  "pending",
  "processing",
  "failed",
  "validating",
  "in_review",
  "in_approval",
  "awaiting_signature",
  "signed",
  "registering",
  "distributing",
  "completed",
  "rejected",
  "returned",
]);

export const taskActionEnum = pgEnum("task_action", [
  "review",
  "approve",
  "sign",
  "acknowledge",
]);

// ---------------------------------------------------------------------------
// Unit-Based Workflow Engine Enums
// ---------------------------------------------------------------------------

export const unitTypeEnum = pgEnum("unit_type", [
  "DOCUMENT",
  "TASK",
  "ACTION",
  "CONDITION",
  "NOTIFICATION",
  "AUTOMATION",
  "GATE",
  "PARALLEL",
]);

export const flowInstanceStatusEnum = pgEnum("flow_instance_status", [
  "running",
  "waiting",
  "completed",
  "failed",
  "cancelled",
  "paused",
]);

export const unitInstanceStatusEnum = pgEnum("unit_instance_status", [
  "pending",
  "active",
  "completed",
  "failed",
  "skipped",
  "cancelled",
]);

// ---------------------------------------------------------------------------
// Users
// ---------------------------------------------------------------------------

export const users = pgTable("users", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  name: text("name").notNull(),
  role: text("role").notNull(),
  email: text("email").notNull().unique(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertUserSchema = createInsertSchema(users);
export const selectUserSchema = createSelectSchema(users);

export type InsertUser = z.infer<typeof insertUserSchema>;
export type SelectUser = z.infer<typeof selectUserSchema>;

// ---------------------------------------------------------------------------
// Workflows
// ---------------------------------------------------------------------------

export const workflowBlueprintSchema = z.object({
  version: z.string(),
  steps: z.array(
    z.object({
      id: z.string(),
      type: z.string(),
      config: z.record(z.string(), z.unknown()).optional(),
      next: z.string().optional(),
    }),
  ),
});

export const workflows = pgTable("workflows", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  name: text("name").notNull(),
  blueprint: jsonb("blueprint")
    .$type<z.infer<typeof workflowBlueprintSchema>>()
    .notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertWorkflowSchema = createInsertSchema(workflows, {
  blueprint: workflowBlueprintSchema,
});
export const selectWorkflowSchema = createSelectSchema(workflows, {
  blueprint: workflowBlueprintSchema,
});

export type InsertWorkflow = z.infer<typeof insertWorkflowSchema>;
export type SelectWorkflow = z.infer<typeof selectWorkflowSchema>;

// ---------------------------------------------------------------------------
// Documents
// ---------------------------------------------------------------------------

export const documentMetadataSchema = z.object({
  author: z.string().optional(),
  tags: z.array(z.string()).optional(),
  version: z.number().optional(),
  source: z.string().optional(),
  department: z.string().optional(),
  category: z.string().optional(),
  priority: z.string().optional(),
});

export const documents = pgTable("documents", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  title: text("title").notNull(),
  description: text("description"),
  fileUrl: text("file_url").notNull(),
  mimeType: text("mime_type").notNull(),
  sizeBytes: integer("size_bytes"),
  status: documentStatusEnum("status").default("pending").notNull(),
  authorId: text("author_id").references(() => users.id),
  metadata: jsonb("metadata").$type<z.infer<typeof documentMetadataSchema>>(),
  signedAt: timestamp("signed_at"),
  completedAt: timestamp("completed_at"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertDocumentSchema = createInsertSchema(documents, {
  metadata: documentMetadataSchema.optional(),
});
export const selectDocumentSchema = createSelectSchema(documents, {
  metadata: documentMetadataSchema.optional(),
});

export type InsertDocument = z.infer<typeof insertDocumentSchema>;
export type SelectDocument = z.infer<typeof selectDocumentSchema>;

// ---------------------------------------------------------------------------
// Tasks
// ---------------------------------------------------------------------------

export const tasks = pgTable("tasks", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  documentId: text("document_id")
    .notNull()
    .references(() => documents.id),
  assigneeId: text("assignee_id")
    .notNull()
    .references(() => users.id),
  type: text("type").notNull(), // DEPRECATED: use actionType
  actionType: taskActionEnum("action_type"),
  status: text("status", {
    // extended text statuses to handle action completions
    enum: [
      "pending",
      "completed",
      "rejected",
      "approved",
      "returned",
      "signed",
    ],
  })
    .default("pending")
    .notNull(),
  comment: text("comment"),
  completedAt: timestamp("completed_at"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertTaskSchema = createInsertSchema(tasks);
export const selectTaskSchema = createSelectSchema(tasks);

export type InsertTask = z.infer<typeof insertTaskSchema>;
export type SelectTask = z.infer<typeof selectTaskSchema>;

// ---------------------------------------------------------------------------
// Audit Logs
// ---------------------------------------------------------------------------

export const auditLogs = pgTable("audit_logs", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  documentId: text("document_id").references(() => documents.id),
  action: text("action").notNull(),
  actor: text("actor_id").references(() => users.id),
  fromStatus: text("from_status"),
  toStatus: text("to_status"),
  comment: text("comment"),
  metadata: jsonb("metadata"),
  createdAt: timestamp("created_at").defaultNow(),
});

export const insertAuditLogSchema = createInsertSchema(auditLogs);
export const selectAuditLogSchema = createSelectSchema(auditLogs);

export type InsertAuditLog = z.infer<typeof insertAuditLogSchema>;
export type SelectAuditLog = z.infer<typeof selectAuditLogSchema>;

// ---------------------------------------------------------------------------
// Document Registry
// ---------------------------------------------------------------------------

export const documentRegistry = pgTable("document_registry", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  documentId: text("document_id").references(() => documents.id),
  registryNumber: text("registry_number").unique(),
  registeredAt: timestamp("registered_at").defaultNow(),
  registeredBy: text("registered_by"),
});

export const insertDocumentRegistrySchema =
  createInsertSchema(documentRegistry);
export const selectDocumentRegistrySchema =
  createSelectSchema(documentRegistry);

export type InsertDocumentRegistry = z.infer<
  typeof insertDocumentRegistrySchema
>;
export type SelectDocumentRegistry = z.infer<
  typeof selectDocumentRegistrySchema
>;

// ---------------------------------------------------------------------------
// Distributions
// ---------------------------------------------------------------------------

export const distributions = pgTable("distributions", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  documentId: text("document_id").references(() => documents.id),
  recipientId: text("recipient_id").references(() => users.id),
  channel: text("channel"), // 'email', 'portal', 'api'
  sentAt: timestamp("sent_at").defaultNow(),
  acknowledgedAt: timestamp("acknowledged_at"),
});

export const insertDistributionSchema = createInsertSchema(distributions);
export const selectDistributionSchema = createSelectSchema(distributions);

export type InsertDistribution = z.infer<typeof insertDistributionSchema>;
export type SelectDistribution = z.infer<typeof selectDistributionSchema>;

// ===========================================================================
// UNIT-BASED WORKFLOW ENGINE TABLES
// ===========================================================================

// ---------------------------------------------------------------------------
// Unit Definitions — Master catalog of reusable atomic units
// ---------------------------------------------------------------------------

export const unitDefinitions = pgTable("unit_definitions", {
  id: text("id").primaryKey(),
  // Format: "type:name" e.g. "doc:business_trip_plan", "action:sign"
  type: unitTypeEnum("type").notNull(),
  name: text("name").notNull(),
  description: text("description"),
  config: jsonb("config").$type<Record<string, any>>().notNull().default({}),
  // Config contains type-specific properties:
  //   DOCUMENT: { template, fields[], creator }
  //   ACTION: { allowedActions[], requiresComment, timeout }
  //   TASK: { deadline, output }
  //   CONDITION: { expression, branches }
  //   NOTIFICATION: { channel[], template }
  //   AUTOMATION: { handler, retryPolicy }
  //   GATE: { mode: 'all' | 'any' }
  //   PARALLEL: {} (branches defined in flow graph)
  version: integer("version").notNull().default(1),
  isActive: boolean("is_active").notNull().default(true),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertUnitDefinitionSchema = createInsertSchema(unitDefinitions);
export const selectUnitDefinitionSchema = createSelectSchema(unitDefinitions);

export type InsertUnitDefinition = z.infer<typeof insertUnitDefinitionSchema>;
export type SelectUnitDefinition = z.infer<typeof selectUnitDefinitionSchema>;

// ---------------------------------------------------------------------------
// Flow Definitions — Reusable flow templates stored as directed graphs
// ---------------------------------------------------------------------------

export interface FlowNode {
  id: string;
  unit: string; // reference to unit_definitions.id
  label: string;
  config?: Record<string, any>;
  next: string[] | Record<string, string[]>;
  isTerminal?: boolean;
  isError?: boolean;
  isLoop?: boolean;
}

export const flowDefinitions = pgTable("flow_definitions", {
  id: text("id").primaryKey(),
  // e.g. "business_trip", "leave_request", "procurement"
  name: text("name").notNull(),
  description: text("description"),
  icon: text("icon"),
  color: text("color"),
  category: text("category"), // e.g. "hr", "finance", "admin"
  roles: jsonb("roles").$type<string[]>().notNull().default([]),
  // Array of role identifiers needed by this flow
  graph: jsonb("graph").$type<FlowNode[]>().notNull(),
  // The flow graph — array of nodes with edges
  estimatedDuration: text("estimated_duration"),
  version: integer("version").notNull().default(1),
  isActive: boolean("is_active").notNull().default(true),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertFlowDefinitionSchema = createInsertSchema(flowDefinitions);
export const selectFlowDefinitionSchema = createSelectSchema(flowDefinitions);

export type InsertFlowDefinition = z.infer<typeof insertFlowDefinitionSchema>;
export type SelectFlowDefinition = z.infer<typeof selectFlowDefinitionSchema>;

// ---------------------------------------------------------------------------
// Flow Instances — Runtime state of a single flow execution
// ---------------------------------------------------------------------------

export interface FlowContext {
  roleAssignments: Record<string, string>;
  variables: Record<string, any>;
  completedNodes: string[];
  nodeOutputs: Record<string, any>;
  activeNodes: string[];
}

export const flowInstances = pgTable("flow_instances", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  flowDefinitionId: text("flow_definition_id")
    .notNull()
    .references(() => flowDefinitions.id),
  temporalWorkflowId: text("temporal_workflow_id").notNull().unique(),
  status: flowInstanceStatusEnum("status").notNull().default("running"),
  currentNodeIds: jsonb("current_node_ids")
    .$type<string[]>()
    .notNull()
    .default([]),
  context: jsonb("context").$type<FlowContext>().notNull().default({
    roleAssignments: {},
    variables: {},
    completedNodes: [],
    nodeOutputs: {},
    activeNodes: [],
  }),
  startedBy: text("started_by").references(() => users.id),
  startedAt: timestamp("started_at").defaultNow().notNull(),
  completedAt: timestamp("completed_at"),
});

export const insertFlowInstanceSchema = createInsertSchema(flowInstances);
export const selectFlowInstanceSchema = createSelectSchema(flowInstances);

export type InsertFlowInstance = z.infer<typeof insertFlowInstanceSchema>;
export type SelectFlowInstance = z.infer<typeof selectFlowInstanceSchema>;

// ---------------------------------------------------------------------------
// Unit Instances — Runtime record for each unit execution within a flow
// ---------------------------------------------------------------------------

export const unitInstances = pgTable("unit_instances", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  flowInstanceId: text("flow_instance_id")
    .notNull()
    .references(() => flowInstances.id),
  unitDefinitionId: text("unit_definition_id")
    .notNull()
    .references(() => unitDefinitions.id),
  nodeId: text("node_id").notNull(),
  // The node ID from the flow graph (e.g. "1", "5", "R1")
  status: unitInstanceStatusEnum("status").notNull().default("pending"),
  assigneeId: text("assignee_id").references(() => users.id),
  input: jsonb("input").$type<Record<string, any>>().default({}),
  output: jsonb("output").$type<Record<string, any>>().default({}),
  startedAt: timestamp("started_at"),
  completedAt: timestamp("completed_at"),
  deadlineAt: timestamp("deadline_at"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

export const insertUnitInstanceSchema = createInsertSchema(unitInstances);
export const selectUnitInstanceSchema = createSelectSchema(unitInstances);

export type InsertUnitInstance = z.infer<typeof insertUnitInstanceSchema>;
export type SelectUnitInstance = z.infer<typeof selectUnitInstanceSchema>;

// ---------------------------------------------------------------------------
// Flow Audit Log — Immutable, append-only record of every flow action
// ---------------------------------------------------------------------------

export const flowAuditLog = pgTable("flow_audit_log", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  flowInstanceId: text("flow_instance_id")
    .notNull()
    .references(() => flowInstances.id),
  unitInstanceId: text("unit_instance_id").references(() => unitInstances.id),
  actorId: text("actor_id").references(() => users.id),
  action: text("action").notNull(),
  // e.g. "SIGN", "REJECT", "APPROVE", "COMPLETE", "GENERATE", "TIMEOUT"
  fromStatus: text("from_status"),
  toStatus: text("to_status"),
  comment: text("comment"),
  metadata: jsonb("metadata").$type<Record<string, any>>().default({}),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

export const insertFlowAuditLogSchema = createInsertSchema(flowAuditLog);
export const selectFlowAuditLogSchema = createSelectSchema(flowAuditLog);

export type InsertFlowAuditLog = z.infer<typeof insertFlowAuditLogSchema>;
export type SelectFlowAuditLog = z.infer<typeof selectFlowAuditLogSchema>;

// ---------------------------------------------------------------------------
// Notifications — In-app notification records
// ---------------------------------------------------------------------------

export const notificationTypeEnum = pgEnum("notification_type", [
  "task_assigned",
  "action_completed",
  "flow_completed",
  "flow_failed",
  "rejection",
  "request_change",
  "timeout",
  "info",
]);

export const notifications = pgTable("notifications", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  recipientId: text("recipient_id")
    .notNull()
    .references(() => users.id),
  type: notificationTypeEnum("type").notNull(),
  title: text("title").notNull(),
  message: text("message").notNull(),
  flowInstanceId: text("flow_instance_id").references(() => flowInstances.id),
  flowDefinitionId: text("flow_definition_id"),
  unitInstanceId: text("unit_instance_id").references(() => unitInstances.id),
  actorId: text("actor_id").references(() => users.id),
  isRead: boolean("is_read").notNull().default(false),
  readAt: timestamp("read_at"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

export const insertNotificationSchema = createInsertSchema(notifications);
export const selectNotificationSchema = createSelectSchema(notifications);

export type InsertNotification = z.infer<typeof insertNotificationSchema>;
export type SelectNotification = z.infer<typeof selectNotificationSchema>;

// ===========================================================================
// INTEGRATION & BACKGROUND CHECK TABLES
// ===========================================================================

// ---------------------------------------------------------------------------
// Integration Enums
// ---------------------------------------------------------------------------

export const backgroundCheckStatusEnum = pgEnum("background_check_status", [
  "pending",
  "submitted",
  "processing",
  "mapping",
  "completed",
  "failed",
]);

export const backgroundCheckErrorStageEnum = pgEnum(
  "background_check_error_stage",
  ["external_services", "mapping", "upsert"],
);

export const integrationStatusEnum = pgEnum("integration_status", [
  "pending",
  "running",
  "success",
  "completed",
  "failed",
  "skipped",
  "api_failure",
  "unauthorized",
  "not_found",
  "params_missing",
  "timeout",
]);

export const recordHistoryActionEnum = pgEnum("record_history_action", [
  "created",
  "updated",
  "deleted",
  "completed",
  "submitted",
]);

export const batchStatusEnum = pgEnum("batch_status", [
  "pending",
  "processing",
  "completed",
  "failed",
  "partial",
]);

// ---------------------------------------------------------------------------
// Integration Settings — Config for 70+ eGov API methods
// ---------------------------------------------------------------------------

export interface PollingConfig {
  intervalMs: number;
  maxAttempts: number;
  successCondition?: string;
}

export const integrationSettings = pgTable("integration_settings", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  methodName: text("method_name").notNull().unique(),
  serviceName: text("service_name").notNull(),
  httpMethod: text("http_method").notNull().default("POST"),
  endpoint: text("endpoint").notNull(),
  baseUrl: text("base_url"),
  defaultBody: jsonb("default_body").$type<Record<string, any>>(),
  defaultHeaders: jsonb("default_headers").$type<Record<string, any>>(),
  defaultQueryParams: jsonb("default_query_params").$type<
    Record<string, any>
  >(),
  description: text("description"),
  category: text("category"),
  timeout: integer("timeout").notNull().default(60000),
  isActive: boolean("is_active").notNull().default(true),
  requiresAuth: boolean("requires_auth").notNull().default(true),
  parentId: text("parent_id"),
  delayMs: integer("delay_ms").notNull().default(0),
  pollingConfig: jsonb("polling_config").$type<PollingConfig>(),
  responseMapping: jsonb("response_mapping").$type<Record<string, string>>(),
  isAvailable: boolean("is_available").notNull().default(true),
  lastCheckedAt: timestamp("last_checked_at"),
  unavailableReason: text("unavailable_reason"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertIntegrationSettingSchema =
  createInsertSchema(integrationSettings);
export const selectIntegrationSettingSchema =
  createSelectSchema(integrationSettings);

export type InsertIntegrationSetting = z.infer<
  typeof insertIntegrationSettingSchema
>;
export type SelectIntegrationSetting = z.infer<
  typeof selectIntegrationSettingSchema
>;

// ---------------------------------------------------------------------------
// Background Check Batches — Batch tracking for bulk imports
// ---------------------------------------------------------------------------

export const backgroundCheckBatches = pgTable("background_check_batches", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  name: text("name"),
  totalItems: integer("total_items").notNull().default(0),
  status: batchStatusEnum("status").notNull().default("pending"),
  pendingCount: integer("pending_count").notNull().default(0),
  submittedCount: integer("submitted_count").notNull().default(0),
  processingCount: integer("processing_count").notNull().default(0),
  completedCount: integer("completed_count").notNull().default(0),
  failedCount: integer("failed_count").notNull().default(0),
  createdBy: text("created_by").notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
  completedAt: timestamp("completed_at"),
});

export const insertBackgroundCheckBatchSchema = createInsertSchema(
  backgroundCheckBatches,
);
export const selectBackgroundCheckBatchSchema = createSelectSchema(
  backgroundCheckBatches,
);

export type InsertBackgroundCheckBatch = z.infer<
  typeof insertBackgroundCheckBatchSchema
>;
export type SelectBackgroundCheckBatch = z.infer<
  typeof selectBackgroundCheckBatchSchema
>;

// ---------------------------------------------------------------------------
// Background Checks — Each row is one background check request
// ---------------------------------------------------------------------------

export const backgroundChecks = pgTable("background_checks", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  userId: text("user_id").references(() => users.id),
  pinpp: text("pinpp"),
  tin: text("tin"),
  searchCriteria: jsonb("search_criteria")
    .$type<Record<string, any>>()
    .notNull(),
  status: backgroundCheckStatusEnum("status").notNull().default("pending"),
  externalServiceResults: jsonb("external_service_results").$type<
    Record<string, any>
  >(),
  mappedData: jsonb("mapped_data").$type<Record<string, any>>(),
  recordsUpsertResult: jsonb("records_upsert_result").$type<
    Record<string, any>
  >(),
  submittedAt: timestamp("submitted_at"),
  processingCompletedAt: timestamp("processing_completed_at"),
  mappingCompletedAt: timestamp("mapping_completed_at"),
  completedAt: timestamp("completed_at"),
  errorMessage: text("error_message"),
  errorStage: backgroundCheckErrorStageEnum("error_stage"),
  batchId: text("batch_id").references(() => backgroundCheckBatches.id),
  integrationSettingIds: jsonb("integration_setting_ids")
    .$type<string[]>()
    .notNull()
    .default([]),
  temporalWorkflowId: text("temporal_workflow_id").unique(),
  userSnapshot: jsonb("user_snapshot").$type<Record<string, any>>(),
  createdBy: text("created_by").notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertBackgroundCheckSchema = createInsertSchema(backgroundChecks);
export const selectBackgroundCheckSchema = createSelectSchema(backgroundChecks);

export type InsertBackgroundCheck = z.infer<typeof insertBackgroundCheckSchema>;
export type SelectBackgroundCheck = z.infer<typeof selectBackgroundCheckSchema>;

// ---------------------------------------------------------------------------
// Integrations — Individual integration execution results
// ---------------------------------------------------------------------------

export const integrations = pgTable("integrations", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  requestId: text("request_id")
    .notNull()
    .references(() => backgroundChecks.id),
  integrationSettingId: text("integration_setting_id").references(
    () => integrationSettings.id,
  ),
  methodName: text("method_name").notNull(),
  status: integrationStatusEnum("status").notNull().default("pending"),
  rawData: jsonb("raw_data").$type<Record<string, any>>(),
  requestBody: jsonb("request_body").$type<Record<string, any>>(),
  pinpp: text("pinpp"),
  searchCriteria: jsonb("search_criteria").$type<Record<string, any>>(),
  recordIds: jsonb("record_ids").$type<string[]>().default([]),
  errorMessage: text("error_message"),
  errorCode: text("error_code"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertIntegrationSchema = createInsertSchema(integrations);
export const selectIntegrationSchema = createSelectSchema(integrations);

export type InsertIntegration = z.infer<typeof insertIntegrationSchema>;
export type SelectIntegration = z.infer<typeof selectIntegrationSchema>;

// ---------------------------------------------------------------------------
// eGov Tokens — OAuth2 token storage
// ---------------------------------------------------------------------------

export const egovTokens = pgTable("egov_tokens", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  serviceName: text("service_name").notNull(),
  accessToken: text("access_token").notNull(),
  accessTokenExpiresAt: timestamp("access_token_expires_at").notNull(),
  expiresIn: integer("expires_in").notNull(),
  tokenType: text("token_type").notNull().default("Bearer"),
  metadata: jsonb("metadata").$type<Record<string, any>>(),
  isActive: boolean("is_active").notNull().default(true),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertEgovTokenSchema = createInsertSchema(egovTokens);
export const selectEgovTokenSchema = createSelectSchema(egovTokens);

export type InsertEgovToken = z.infer<typeof insertEgovTokenSchema>;
export type SelectEgovToken = z.infer<typeof selectEgovTokenSchema>;

// ---------------------------------------------------------------------------
// Record Types — Record type definitions (e.g. "passport_info", "address_info")
// ---------------------------------------------------------------------------

export const recordTypes = pgTable("record_types", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  name: text("name").notNull(),
  isEnabled: boolean("is_enabled").notNull().default(true),
  allowMultiple: boolean("allow_multiple").notNull().default(false),
  allowedOwners: integer("allowed_owners").notNull().default(1),
  icon: text("icon"),
  tags: jsonb("tags").$type<string[]>().default([]),
  jsonSchema: jsonb("json_schema").$type<Record<string, any>>(),
  completedJsonSchema: jsonb("completed_json_schema").$type<
    Record<string, any>
  >(),
  settings: jsonb("settings").$type<Record<string, any>>(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertRecordTypeSchema = createInsertSchema(recordTypes);
export const selectRecordTypeSchema = createSelectSchema(recordTypes);

export type InsertRecordType = z.infer<typeof insertRecordTypeSchema>;
export type SelectRecordType = z.infer<typeof selectRecordTypeSchema>;

// ---------------------------------------------------------------------------
// Records — Generic records created from integration results
// ---------------------------------------------------------------------------

export const records = pgTable("records", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  userId: text("user_id").references(() => users.id),
  recordTypeId: text("record_type_id")
    .notNull()
    .references(() => recordTypes.id),
  pinpp: text("pinpp").notNull(),
  data: jsonb("data").$type<Record<string, any>>().notNull().default({}),
  attachments: jsonb("attachments").$type<any[]>(),
  completedAt: timestamp("completed_at"),
  completedBy: text("completed_by"),
  lockedAt: timestamp("locked_at"),
  lockedBy: text("locked_by"),
  createdBy: text("created_by"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertRecordSchema = createInsertSchema(records);
export const selectRecordSchema = createSelectSchema(records);

export type InsertRecord = z.infer<typeof insertRecordSchema>;
export type SelectRecord = z.infer<typeof selectRecordSchema>;

// ---------------------------------------------------------------------------
// Record History — Audit trail for records
// ---------------------------------------------------------------------------

export const recordHistory = pgTable("record_history", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  recordId: text("record_id")
    .notNull()
    .references(() => records.id),
  recordTypeId: text("record_type_id")
    .notNull()
    .references(() => recordTypes.id),
  action: recordHistoryActionEnum("action").notNull(),
  data: jsonb("data").$type<Record<string, any>>().notNull().default({}),
  attachments: jsonb("attachments").$type<any[]>(),
  metadata: jsonb("metadata").$type<Record<string, any>>(),
  createdBy: text("created_by"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

export const insertRecordHistorySchema = createInsertSchema(recordHistory);
export const selectRecordHistorySchema = createSelectSchema(recordHistory);

export type InsertRecordHistory = z.infer<typeof insertRecordHistorySchema>;
export type SelectRecordHistory = z.infer<typeof selectRecordHistorySchema>;

// ---------------------------------------------------------------------------
// Event Handlers — JSON-configured event processing pipelines
// ---------------------------------------------------------------------------

export interface EventHandlerTrigger {
  sourceSystem: string;
  event: string;
  conditions?: Record<string, any>;
}

export interface EventHandlerAction {
  name: string;
  settings: Record<string, any>;
}

export const eventHandlers = pgTable("event_handlers", {
  id: text("id")
    .primaryKey()
    .$defaultFn(() => uuidv7()),
  name: text("name"),
  description: text("description"),
  tags: jsonb("tags").$type<string[]>().default([]),
  triggers: jsonb("triggers")
    .$type<EventHandlerTrigger[]>()
    .notNull()
    .default([]),
  actions: jsonb("actions").$type<EventHandlerAction[]>().notNull(),
  isActive: boolean("is_active").notNull().default(true),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertEventHandlerSchema = createInsertSchema(eventHandlers);
export const selectEventHandlerSchema = createSelectSchema(eventHandlers);

export type InsertEventHandler = z.infer<typeof insertEventHandlerSchema>;
export type SelectEventHandler = z.infer<typeof selectEventHandlerSchema>;
