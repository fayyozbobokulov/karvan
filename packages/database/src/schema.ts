import { pgTable, text, timestamp, jsonb, integer } from "drizzle-orm/pg-core";
import { createSchemaFactory } from "drizzle-zod";
import { z } from "zod/v4";
import { v7 as uuidv7 } from "uuid";

const { createInsertSchema, createSelectSchema } = createSchemaFactory();

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
  status: text("status", {
    enum: [
      "pending",
      "processing",
      "completed",
      "failed",
      "signed",
      "rejected",
    ],
  })
    .default("pending")
    .notNull(),
  authorId: text("author_id").references(() => users.id),
  metadata: jsonb("metadata").$type<z.infer<typeof documentMetadataSchema>>(),
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
  type: text("type").notNull(), // e.g., 'signing', 'review'
  status: text("status", {
    enum: ["pending", "completed", "rejected"],
  })
    .default("pending")
    .notNull(),
  comment: text("comment"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const insertTaskSchema = createInsertSchema(tasks);
export const selectTaskSchema = createSelectSchema(tasks);

export type InsertTask = z.infer<typeof insertTaskSchema>;
export type SelectTask = z.infer<typeof selectTaskSchema>;
