import { pgTable, text, timestamp, jsonb, integer } from "drizzle-orm/pg-core";
import { createSchemaFactory } from "drizzle-zod";
import { z } from "zod/v4";
import { v7 as uuidv7 } from "uuid";

const { createInsertSchema, createSelectSchema } = createSchemaFactory();

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
    enum: ["pending", "processing", "completed", "failed"],
  })
    .default("pending")
    .notNull(),
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
