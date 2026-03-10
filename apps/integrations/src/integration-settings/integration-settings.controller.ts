import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  Query,
} from '@nestjs/common';
import { IntegrationSettingsService } from './integration-settings.service';
import type { InsertIntegrationSetting } from '@workflow/database';

// ── Controller ────────────────────────────────────────────────────────────

@Controller('api')
export class IntegrationSettingsController {
  constructor(
    private readonly integrationSettingsService: IntegrationSettingsService,
  ) {}

  // GET /api/integration-settings — List with optional filters
  @Get('integration-settings')
  async findAll(
    @Query('category') category?: string,
    @Query('isActive') isActive?: string,
    @Query('serviceName') serviceName?: string,
  ) {
    return this.integrationSettingsService.findAll({
      category,
      isActive: isActive !== undefined ? isActive === 'true' : undefined,
      serviceName,
    });
  }

  // GET /api/integration-settings/:id — Get by id
  @Get('integration-settings/:id')
  async findOne(@Param('id') id: string) {
    return this.integrationSettingsService.findOne(id);
  }

  // POST /api/integration-settings — Create new setting
  @Post('integration-settings')
  async create(@Body() dto: InsertIntegrationSetting) {
    return this.integrationSettingsService.create(dto);
  }

  // PUT /api/integration-settings/:id — Update setting
  @Put('integration-settings/:id')
  async update(
    @Param('id') id: string,
    @Body() dto: Partial<InsertIntegrationSetting>,
  ) {
    return this.integrationSettingsService.update(id, dto);
  }

  // DELETE /api/integration-settings/:id — Soft delete (set isActive=false)
  @Delete('integration-settings/:id')
  async remove(@Param('id') id: string) {
    return this.integrationSettingsService.remove(id);
  }
}
