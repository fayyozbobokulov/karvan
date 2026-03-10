import { Inject, Injectable, Logger, NotFoundException } from '@nestjs/common';
import { eq } from 'drizzle-orm';
import {
  DRIZZLE,
  eventHandlers,
  type InsertEventHandler,
} from '@workflow/database';
import type { NodePgDatabase } from 'drizzle-orm/node-postgres';
import type * as schema from '@workflow/database';

@Injectable()
export class EventHandlersService {
  private readonly logger = new Logger(EventHandlersService.name);

  constructor(
    @Inject(DRIZZLE) private readonly db: NodePgDatabase<typeof schema>,
  ) {}

  // ── List all event handlers ────────────────────────────────────────────

  async findAll() {
    return await this.db
      .select()
      .from(eventHandlers)
      .orderBy(eventHandlers.createdAt);
  }

  // ── Get a single event handler ─────────────────────────────────────────

  async findOne(id: string) {
    const [handler] = await this.db
      .select()
      .from(eventHandlers)
      .where(eq(eventHandlers.id, id));

    if (!handler) {
      throw new NotFoundException(`Event handler not found: ${id}`);
    }

    return handler;
  }

  // ── Create a new event handler ─────────────────────────────────────────

  async create(input: InsertEventHandler) {
    const [handler] = await this.db
      .insert(eventHandlers)
      .values(input)
      .returning();

    this.logger.log(`Created event handler ${handler.id}: ${handler.name}`);

    return handler;
  }

  // ── Update an event handler ────────────────────────────────────────────

  async update(id: string, input: Partial<InsertEventHandler>) {
    const [existing] = await this.db
      .select()
      .from(eventHandlers)
      .where(eq(eventHandlers.id, id));

    if (!existing) {
      throw new NotFoundException(`Event handler not found: ${id}`);
    }

    const [updated] = await this.db
      .update(eventHandlers)
      .set({ ...input, updatedAt: new Date() })
      .where(eq(eventHandlers.id, id))
      .returning();

    this.logger.log(`Updated event handler ${id}`);

    return updated;
  }

  // ── Soft delete an event handler ───────────────────────────────────────

  async remove(id: string) {
    const [existing] = await this.db
      .select()
      .from(eventHandlers)
      .where(eq(eventHandlers.id, id));

    if (!existing) {
      throw new NotFoundException(`Event handler not found: ${id}`);
    }

    const [updated] = await this.db
      .update(eventHandlers)
      .set({ isActive: false, updatedAt: new Date() })
      .where(eq(eventHandlers.id, id))
      .returning();

    this.logger.log(`Soft-deleted event handler ${id}`);

    return updated;
  }
}
