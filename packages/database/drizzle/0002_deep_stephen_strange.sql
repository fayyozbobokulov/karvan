CREATE TYPE "public"."background_check_error_stage" AS ENUM('external_services', 'mapping', 'upsert');--> statement-breakpoint
CREATE TYPE "public"."background_check_status" AS ENUM('pending', 'submitted', 'processing', 'mapping', 'completed', 'failed');--> statement-breakpoint
CREATE TYPE "public"."batch_status" AS ENUM('pending', 'processing', 'completed', 'failed', 'partial');--> statement-breakpoint
CREATE TYPE "public"."integration_status" AS ENUM('pending', 'running', 'success', 'completed', 'failed', 'skipped', 'api_failure', 'unauthorized', 'not_found', 'params_missing', 'timeout');--> statement-breakpoint
CREATE TYPE "public"."notification_type" AS ENUM('task_assigned', 'action_completed', 'flow_completed', 'flow_failed', 'rejection', 'request_change', 'timeout', 'info');--> statement-breakpoint
CREATE TYPE "public"."record_history_action" AS ENUM('created', 'updated', 'deleted', 'completed', 'submitted');--> statement-breakpoint
ALTER TYPE "public"."flow_instance_status" ADD VALUE 'paused';--> statement-breakpoint
CREATE TABLE "background_check_batches" (
	"id" text PRIMARY KEY NOT NULL,
	"name" text,
	"total_items" integer DEFAULT 0 NOT NULL,
	"status" "batch_status" DEFAULT 'pending' NOT NULL,
	"pending_count" integer DEFAULT 0 NOT NULL,
	"submitted_count" integer DEFAULT 0 NOT NULL,
	"processing_count" integer DEFAULT 0 NOT NULL,
	"completed_count" integer DEFAULT 0 NOT NULL,
	"failed_count" integer DEFAULT 0 NOT NULL,
	"created_by" text NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	"completed_at" timestamp
);
--> statement-breakpoint
CREATE TABLE "background_checks" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text,
	"pinpp" text,
	"tin" text,
	"search_criteria" jsonb NOT NULL,
	"status" "background_check_status" DEFAULT 'pending' NOT NULL,
	"external_service_results" jsonb,
	"mapped_data" jsonb,
	"records_upsert_result" jsonb,
	"submitted_at" timestamp,
	"processing_completed_at" timestamp,
	"mapping_completed_at" timestamp,
	"completed_at" timestamp,
	"error_message" text,
	"error_stage" "background_check_error_stage",
	"batch_id" text,
	"integration_setting_ids" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"temporal_workflow_id" text,
	"user_snapshot" jsonb,
	"created_by" text NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "background_checks_temporal_workflow_id_unique" UNIQUE("temporal_workflow_id")
);
--> statement-breakpoint
CREATE TABLE "egov_tokens" (
	"id" text PRIMARY KEY NOT NULL,
	"service_name" text NOT NULL,
	"access_token" text NOT NULL,
	"access_token_expires_at" timestamp NOT NULL,
	"expires_in" integer NOT NULL,
	"token_type" text DEFAULT 'Bearer' NOT NULL,
	"metadata" jsonb,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "event_handlers" (
	"id" text PRIMARY KEY NOT NULL,
	"name" text,
	"description" text,
	"tags" jsonb DEFAULT '[]'::jsonb,
	"triggers" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"actions" jsonb NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "integration_settings" (
	"id" text PRIMARY KEY NOT NULL,
	"method_name" text NOT NULL,
	"service_name" text NOT NULL,
	"http_method" text DEFAULT 'POST' NOT NULL,
	"endpoint" text NOT NULL,
	"base_url" text,
	"default_body" jsonb,
	"default_headers" jsonb,
	"default_query_params" jsonb,
	"description" text,
	"category" text,
	"timeout" integer DEFAULT 60000 NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"requires_auth" boolean DEFAULT true NOT NULL,
	"parent_id" text,
	"delay_ms" integer DEFAULT 0 NOT NULL,
	"polling_config" jsonb,
	"response_mapping" jsonb,
	"is_available" boolean DEFAULT true NOT NULL,
	"last_checked_at" timestamp,
	"unavailable_reason" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "integration_settings_method_name_unique" UNIQUE("method_name")
);
--> statement-breakpoint
CREATE TABLE "integrations" (
	"id" text PRIMARY KEY NOT NULL,
	"request_id" text NOT NULL,
	"integration_setting_id" text,
	"method_name" text NOT NULL,
	"status" "integration_status" DEFAULT 'pending' NOT NULL,
	"raw_data" jsonb,
	"request_body" jsonb,
	"pinpp" text,
	"search_criteria" jsonb,
	"record_ids" jsonb DEFAULT '[]'::jsonb,
	"error_message" text,
	"error_code" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "notifications" (
	"id" text PRIMARY KEY NOT NULL,
	"recipient_id" text NOT NULL,
	"type" "notification_type" NOT NULL,
	"title" text NOT NULL,
	"message" text NOT NULL,
	"flow_instance_id" text,
	"flow_definition_id" text,
	"unit_instance_id" text,
	"actor_id" text,
	"is_read" boolean DEFAULT false NOT NULL,
	"read_at" timestamp,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "record_history" (
	"id" text PRIMARY KEY NOT NULL,
	"record_id" text NOT NULL,
	"record_type_id" text NOT NULL,
	"action" "record_history_action" NOT NULL,
	"data" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"attachments" jsonb,
	"metadata" jsonb,
	"created_by" text,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "record_types" (
	"id" text PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"is_enabled" boolean DEFAULT true NOT NULL,
	"allow_multiple" boolean DEFAULT false NOT NULL,
	"allowed_owners" integer DEFAULT 1 NOT NULL,
	"icon" text,
	"tags" jsonb DEFAULT '[]'::jsonb,
	"json_schema" jsonb,
	"completed_json_schema" jsonb,
	"settings" jsonb,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "records" (
	"id" text PRIMARY KEY NOT NULL,
	"user_id" text,
	"record_type_id" text NOT NULL,
	"pinpp" text NOT NULL,
	"data" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"attachments" jsonb,
	"completed_at" timestamp,
	"completed_by" text,
	"locked_at" timestamp,
	"locked_by" text,
	"created_by" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "background_checks" ADD CONSTRAINT "background_checks_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "background_checks" ADD CONSTRAINT "background_checks_batch_id_background_check_batches_id_fk" FOREIGN KEY ("batch_id") REFERENCES "public"."background_check_batches"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "integrations" ADD CONSTRAINT "integrations_request_id_background_checks_id_fk" FOREIGN KEY ("request_id") REFERENCES "public"."background_checks"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "integrations" ADD CONSTRAINT "integrations_integration_setting_id_integration_settings_id_fk" FOREIGN KEY ("integration_setting_id") REFERENCES "public"."integration_settings"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_recipient_id_users_id_fk" FOREIGN KEY ("recipient_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_flow_instance_id_flow_instances_id_fk" FOREIGN KEY ("flow_instance_id") REFERENCES "public"."flow_instances"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_unit_instance_id_unit_instances_id_fk" FOREIGN KEY ("unit_instance_id") REFERENCES "public"."unit_instances"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_actor_id_users_id_fk" FOREIGN KEY ("actor_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "record_history" ADD CONSTRAINT "record_history_record_id_records_id_fk" FOREIGN KEY ("record_id") REFERENCES "public"."records"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "record_history" ADD CONSTRAINT "record_history_record_type_id_record_types_id_fk" FOREIGN KEY ("record_type_id") REFERENCES "public"."record_types"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "records" ADD CONSTRAINT "records_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "records" ADD CONSTRAINT "records_record_type_id_record_types_id_fk" FOREIGN KEY ("record_type_id") REFERENCES "public"."record_types"("id") ON DELETE no action ON UPDATE no action;