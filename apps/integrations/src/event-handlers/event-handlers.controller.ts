import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
} from '@nestjs/common';
import { EventHandlersService } from './event-handlers.service';
import type { InsertEventHandler } from '@workflow/database';

// ── Controller ────────────────────────────────────────────────────────────

@Controller('api')
export class EventHandlersController {
  constructor(private readonly eventHandlersService: EventHandlersService) {}

  // GET /api/event-handlers — List all event handlers
  @Get('event-handlers')
  async findAll() {
    return this.eventHandlersService.findAll();
  }

  // GET /api/event-handlers/:id — Get by id
  @Get('event-handlers/:id')
  async findOne(@Param('id') id: string) {
    return this.eventHandlersService.findOne(id);
  }

  // POST /api/event-handlers — Create a new event handler
  @Post('event-handlers')
  async create(@Body() dto: InsertEventHandler) {
    return this.eventHandlersService.create(dto);
  }

  // PUT /api/event-handlers/:id — Update an event handler
  @Put('event-handlers/:id')
  async update(
    @Param('id') id: string,
    @Body() dto: Partial<InsertEventHandler>,
  ) {
    return this.eventHandlersService.update(id, dto);
  }

  // DELETE /api/event-handlers/:id — Soft delete (set isActive=false)
  @Delete('event-handlers/:id')
  async remove(@Param('id') id: string) {
    return this.eventHandlersService.remove(id);
  }
}
