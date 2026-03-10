import { Inject, Injectable, Logger, NotFoundException } from '@nestjs/common';
import { eq, and, type SQL } from 'drizzle-orm';
import {
  DRIZZLE,
  integrationSettings,
  type InsertIntegrationSetting,
} from '@workflow/database';
import type { NodePgDatabase } from 'drizzle-orm/node-postgres';
import type * as schema from '@workflow/database';

@Injectable()
export class IntegrationSettingsService {
  private readonly logger = new Logger(IntegrationSettingsService.name);

  constructor(
    @Inject(DRIZZLE) private readonly db: NodePgDatabase<typeof schema>,
  ) {}

  // ── List integration settings with filters ─────────────────────────────

  async findAll(filters: {
    category?: string;
    isActive?: boolean;
    serviceName?: string;
  }) {
    const conditions: SQL[] = [];

    if (filters.category) {
      conditions.push(eq(integrationSettings.category, filters.category));
    }
    if (filters.isActive !== undefined) {
      conditions.push(eq(integrationSettings.isActive, filters.isActive));
    }
    if (filters.serviceName) {
      conditions.push(eq(integrationSettings.serviceName, filters.serviceName));
    }

    return await this.db
      .select()
      .from(integrationSettings)
      .where(conditions.length > 0 ? and(...conditions) : undefined)
      .orderBy(integrationSettings.serviceName, integrationSettings.methodName);
  }

  // ── Get a single integration setting ───────────────────────────────────

  async findOne(id: string) {
    const [setting] = await this.db
      .select()
      .from(integrationSettings)
      .where(eq(integrationSettings.id, id));

    if (!setting) {
      throw new NotFoundException(`Integration setting not found: ${id}`);
    }

    return setting;
  }

  // ── Create a new integration setting ───────────────────────────────────

  async create(input: InsertIntegrationSetting) {
    const [setting] = await this.db
      .insert(integrationSettings)
      .values(input)
      .returning();

    this.logger.log(
      `Created integration setting ${setting.id}: ${setting.methodName}`,
    );

    return setting;
  }

  // ── Update an integration setting ──────────────────────────────────────

  async update(id: string, input: Partial<InsertIntegrationSetting>) {
    const [existing] = await this.db
      .select()
      .from(integrationSettings)
      .where(eq(integrationSettings.id, id));

    if (!existing) {
      throw new NotFoundException(`Integration setting not found: ${id}`);
    }

    const [updated] = await this.db
      .update(integrationSettings)
      .set({ ...input, updatedAt: new Date() })
      .where(eq(integrationSettings.id, id))
      .returning();

    this.logger.log(`Updated integration setting ${id}`);

    return updated;
  }

  // ── Soft delete an integration setting ─────────────────────────────────

  async remove(id: string) {
    const [existing] = await this.db
      .select()
      .from(integrationSettings)
      .where(eq(integrationSettings.id, id));

    if (!existing) {
      throw new NotFoundException(`Integration setting not found: ${id}`);
    }

    const [updated] = await this.db
      .update(integrationSettings)
      .set({ isActive: false, updatedAt: new Date() })
      .where(eq(integrationSettings.id, id))
      .returning();

    this.logger.log(`Soft-deleted integration setting ${id}`);

    return updated;
  }
}
