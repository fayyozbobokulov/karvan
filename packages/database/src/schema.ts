import {
  pgTable,
  text,
  timestamp,
  jsonb,
  integer,
  pgEnum,
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
