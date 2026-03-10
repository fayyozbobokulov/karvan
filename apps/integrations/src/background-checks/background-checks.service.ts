import {
  Inject,
  Injectable,
  Logger,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { eq, desc, and, sql, type SQL } from 'drizzle-orm';
import {
  DRIZZLE,
  backgroundChecks,
  backgroundCheckBatches,
  integrations,
  integrationSettings,
} from '@workflow/database';
import type { NodePgDatabase } from 'drizzle-orm/node-postgres';
import type * as schema from '@workflow/database';
import { TemporalService } from '../temporal/temporal.service';

@Injectable()
export class BackgroundChecksService {
  private readonly logger = new Logger(BackgroundChecksService.name);

  constructor(
    @Inject(DRIZZLE) private readonly db: NodePgDatabase<typeof schema>,
    private readonly temporalService: TemporalService,
  ) {}

  // ── Create a new background check ──────────────────────────────────────

  async create(input: {
    pinpp?: string;
    tin?: string;
    searchCriteria: Record<string, any>;
    userId?: string;
    integrationSettingIds?: string[];
    createdBy: string;
  }) {
    // 1. Determine integration setting IDs
    let settingIds = input.integrationSettingIds;

    if (!settingIds || settingIds.length === 0) {
      const activeSettings = await this.db
        .select({ id: integrationSettings.id })
        .from(integrationSettings)
        .where(eq(integrationSettings.isActive, true));

      settingIds = activeSettings.map((s) => s.id);
    }

    // 2. Insert background check row
    const [check] = await this.db
      .insert(backgroundChecks)
      .values({
        pinpp: input.pinpp,
        tin: input.tin,
        searchCriteria: input.searchCriteria,
        userId: input.userId || null,
        integrationSettingIds: settingIds,
        createdBy: input.createdBy,
        status: 'pending',
      })
      .returning();

    // 3. Generate temporal workflow ID and start workflow
    const temporalWorkflowId = `bg-check-${check.id}`;

    await this.db
      .update(backgroundChecks)
      .set({ temporalWorkflowId })
      .where(eq(backgroundChecks.id, check.id));

    await this.temporalService.startBackgroundCheckWorkflow({
      backgroundCheckId: check.id,
      pinpp: input.pinpp,
      tin: input.tin,
      searchCriteria: input.searchCriteria,
      integrationSettingIds: settingIds,
      temporalWorkflowId,
    });

    this.logger.log(
      `Created background check ${check.id} with workflow ${temporalWorkflowId}`,
    );

    return {
      ...check,
      temporalWorkflowId,
    };
  }

  // ── List background checks with filters ────────────────────────────────

  async findAll(filters: {
    status?: string;
    pinpp?: string;
    batchId?: string;
    limit?: number;
    offset?: number;
  }) {
    const conditions: SQL[] = [];

    if (filters.status) {
      conditions.push(eq(backgroundChecks.status, filters.status as any));
    }
    if (filters.pinpp) {
      conditions.push(eq(backgroundChecks.pinpp, filters.pinpp));
    }
    if (filters.batchId) {
      conditions.push(eq(backgroundChecks.batchId, filters.batchId));
    }

    const query = this.db
      .select()
      .from(backgroundChecks)
      .where(conditions.length > 0 ? and(...conditions) : undefined)
      .orderBy(desc(backgroundChecks.createdAt))
      .limit(filters.limit ?? 50)
      .offset(filters.offset ?? 0);

    const results = await query;

    // Get total count for pagination
    const [countResult] = await this.db
      .select({ count: sql<number>`count(*)` })
      .from(backgroundChecks)
      .where(conditions.length > 0 ? and(...conditions) : undefined);

    return {
      data: results,
      total: Number(countResult.count),
      limit: filters.limit ?? 50,
      offset: filters.offset ?? 0,
    };
  }

  // ── Get a single background check with integrations ────────────────────

  async findOne(id: string) {
    const [check] = await this.db
      .select()
      .from(backgroundChecks)
      .where(eq(backgroundChecks.id, id));

    if (!check) {
      throw new NotFoundException(`Background check not found: ${id}`);
    }

    // Load associated integrations
    const checkIntegrations = await this.db
      .select()
      .from(integrations)
      .where(eq(integrations.requestId, id))
      .orderBy(integrations.createdAt);

    return {
      ...check,
      integrations: checkIntegrations,
    };
  }

  // ── Query Temporal for progress ────────────────────────────────────────

  async getProgress(id: string) {
    const [check] = await this.db
      .select()
      .from(backgroundChecks)
      .where(eq(backgroundChecks.id, id));

    if (!check) {
      throw new NotFoundException(`Background check not found: ${id}`);
    }

    if (check.temporalWorkflowId) {
      try {
        const progress =
          await this.temporalService.queryBackgroundCheckProgress(
            check.temporalWorkflowId,
          );
        if (progress) {
          return {
            ...progress,
            backgroundCheckId: id,
            dbStatus: check.status,
          };
        }
      } catch {
        // If Temporal query fails, fall through to DB state
      }
    }

    // Fallback: compute progress from DB
    const checkIntegrations = await this.db
      .select()
      .from(integrations)
      .where(eq(integrations.requestId, id));

    const total = checkIntegrations.length;
    const completed = checkIntegrations.filter(
      (i) => i.status === 'success' || i.status === 'completed',
    ).length;
    const failed = checkIntegrations.filter(
      (i) =>
        i.status === 'failed' ||
        i.status === 'api_failure' ||
        i.status === 'timeout',
    ).length;

    return {
      backgroundCheckId: id,
      status: check.status,
      totalIntegrations: total,
      completedIntegrations: completed,
      failedIntegrations: failed,
      pendingIntegrations: total - completed - failed,
      dbStatus: check.status,
    };
  }

  // ── Cancel a running background check ──────────────────────────────────

  async cancel(id: string, reason?: string) {
    const [check] = await this.db
      .select()
      .from(backgroundChecks)
      .where(eq(backgroundChecks.id, id));

    if (!check) {
      throw new NotFoundException(`Background check not found: ${id}`);
    }

    const nonCancellableStatuses = ['completed', 'failed'];
    if (nonCancellableStatuses.includes(check.status)) {
      throw new ConflictException(
        `Background check ${id} is in status "${check.status}" and cannot be cancelled`,
      );
    }

    if (!check.temporalWorkflowId) {
      throw new ConflictException(
        `Background check ${id} has no associated Temporal workflow`,
      );
    }

    await this.temporalService.cancelBackgroundCheck(check.temporalWorkflowId);

    this.logger.log(
      `Cancelled background check ${id}: reason=${reason ?? 'none'}`,
    );

    return { status: 'ok' };
  }

  // ── Retry failed integrations ──────────────────────────────────────────

  async retryFailed(id: string) {
    const [check] = await this.db
      .select()
      .from(backgroundChecks)
      .where(eq(backgroundChecks.id, id));

    if (!check) {
      throw new NotFoundException(`Background check not found: ${id}`);
    }

    if (!check.temporalWorkflowId) {
      throw new ConflictException(
        `Background check ${id} has no associated Temporal workflow`,
      );
    }

    await this.temporalService.retryFailedIntegrations(
      check.temporalWorkflowId,
    );

    this.logger.log(`Sent retry signal for background check ${id}`);

    return { status: 'ok' };
  }

  // ── List background check batches ──────────────────────────────────────

  async listBatches() {
    return await this.db
      .select()
      .from(backgroundCheckBatches)
      .orderBy(desc(backgroundCheckBatches.createdAt));
  }

  // ── Get a single batch with summary counts ─────────────────────────────

  async getBatch(id: string) {
    const [batch] = await this.db
      .select()
      .from(backgroundCheckBatches)
      .where(eq(backgroundCheckBatches.id, id));

    if (!batch) {
      throw new NotFoundException(`Batch not found: ${id}`);
    }

    // Get summary counts from background checks in this batch
    const [summary] = await this.db
      .select({
        total: sql<number>`count(*)`,
        pending: sql<number>`count(*) filter (where ${backgroundChecks.status} = 'pending')`,
        submitted: sql<number>`count(*) filter (where ${backgroundChecks.status} = 'submitted')`,
        processing: sql<number>`count(*) filter (where ${backgroundChecks.status} = 'processing')`,
        completed: sql<number>`count(*) filter (where ${backgroundChecks.status} = 'completed')`,
        failed: sql<number>`count(*) filter (where ${backgroundChecks.status} = 'failed')`,
      })
      .from(backgroundChecks)
      .where(eq(backgroundChecks.batchId, id));

    return {
      ...batch,
      summary: {
        total: Number(summary.total),
        pending: Number(summary.pending),
        submitted: Number(summary.submitted),
        processing: Number(summary.processing),
        completed: Number(summary.completed),
        failed: Number(summary.failed),
      },
    };
  }
}
