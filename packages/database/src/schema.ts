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
