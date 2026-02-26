CREATE TYPE "public"."flow_instance_status" AS ENUM('running', 'waiting', 'completed', 'failed', 'cancelled');--> statement-breakpoint
CREATE TYPE "public"."unit_instance_status" AS ENUM('pending', 'active', 'completed', 'failed', 'skipped', 'cancelled');--> statement-breakpoint
CREATE TYPE "public"."unit_type" AS ENUM('DOCUMENT', 'TASK', 'ACTION', 'CONDITION', 'NOTIFICATION', 'AUTOMATION', 'GATE', 'PARALLEL');--> statement-breakpoint
ALTER TYPE "public"."document_status" ADD VALUE 'processing' BEFORE 'validating';--> statement-breakpoint
ALTER TYPE "public"."document_status" ADD VALUE 'failed' BEFORE 'validating';--> statement-breakpoint
ALTER TYPE "public"."document_status" ADD VALUE 'signed' BEFORE 'registering';--> statement-breakpoint
CREATE TABLE "flow_audit_log" (
	"id" text PRIMARY KEY NOT NULL,
	"flow_instance_id" text NOT NULL,
	"unit_instance_id" text,
	"actor_id" text,
	"action" text NOT NULL,
	"from_status" text,
	"to_status" text,
	"comment" text,
	"metadata" jsonb DEFAULT '{}'::jsonb,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "flow_definitions" (
	"id" text PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"description" text,
	"icon" text,
	"color" text,
	"category" text,
	"roles" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"graph" jsonb NOT NULL,
	"estimated_duration" text,
	"version" integer DEFAULT 1 NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "flow_instances" (
	"id" text PRIMARY KEY NOT NULL,
	"flow_definition_id" text NOT NULL,
	"temporal_workflow_id" text NOT NULL,
	"status" "flow_instance_status" DEFAULT 'running' NOT NULL,
	"current_node_ids" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"context" jsonb DEFAULT '{"roleAssignments":{},"variables":{},"completedNodes":[],"nodeOutputs":{},"activeNodes":[]}'::jsonb NOT NULL,
	"started_by" text,
	"started_at" timestamp DEFAULT now() NOT NULL,
	"completed_at" timestamp,
	CONSTRAINT "flow_instances_temporal_workflow_id_unique" UNIQUE("temporal_workflow_id")
);
--> statement-breakpoint
CREATE TABLE "unit_definitions" (
	"id" text PRIMARY KEY NOT NULL,
	"type" "unit_type" NOT NULL,
	"name" text NOT NULL,
	"description" text,
	"config" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"version" integer DEFAULT 1 NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "unit_instances" (
	"id" text PRIMARY KEY NOT NULL,
	"flow_instance_id" text NOT NULL,
	"unit_definition_id" text NOT NULL,
	"node_id" text NOT NULL,
	"status" "unit_instance_status" DEFAULT 'pending' NOT NULL,
	"assignee_id" text,
	"input" jsonb DEFAULT '{}'::jsonb,
	"output" jsonb DEFAULT '{}'::jsonb,
	"started_at" timestamp,
	"completed_at" timestamp,
	"deadline_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "flow_audit_log" ADD CONSTRAINT "flow_audit_log_flow_instance_id_flow_instances_id_fk" FOREIGN KEY ("flow_instance_id") REFERENCES "public"."flow_instances"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "flow_audit_log" ADD CONSTRAINT "flow_audit_log_unit_instance_id_unit_instances_id_fk" FOREIGN KEY ("unit_instance_id") REFERENCES "public"."unit_instances"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "flow_audit_log" ADD CONSTRAINT "flow_audit_log_actor_id_users_id_fk" FOREIGN KEY ("actor_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "flow_instances" ADD CONSTRAINT "flow_instances_flow_definition_id_flow_definitions_id_fk" FOREIGN KEY ("flow_definition_id") REFERENCES "public"."flow_definitions"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "flow_instances" ADD CONSTRAINT "flow_instances_started_by_users_id_fk" FOREIGN KEY ("started_by") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "unit_instances" ADD CONSTRAINT "unit_instances_flow_instance_id_flow_instances_id_fk" FOREIGN KEY ("flow_instance_id") REFERENCES "public"."flow_instances"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "unit_instances" ADD CONSTRAINT "unit_instances_unit_definition_id_unit_definitions_id_fk" FOREIGN KEY ("unit_definition_id") REFERENCES "public"."unit_definitions"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "unit_instances" ADD CONSTRAINT "unit_instances_assignee_id_users_id_fk" FOREIGN KEY ("assignee_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;