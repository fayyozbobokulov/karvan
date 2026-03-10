import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { BackgroundChecksService } from './background-checks.service';

// ── DTOs ──────────────────────────────────────────────────────────────────

class CreateBackgroundCheckDto {
  pinpp?: string;
  tin?: string;
  searchCriteria!: Record<string, any>;
  userId?: string;
  integrationSettingIds?: string[];
  createdBy!: string;
}

class CancelBackgroundCheckDto {
  reason?: string;
}

// ── Controller ────────────────────────────────────────────────────────────

@Controller('api')
export class BackgroundChecksController {
  constructor(
    private readonly backgroundChecksService: BackgroundChecksService,
  ) {}

  // POST /api/background-checks — Create and start a new background check
  @Post('background-checks')
  async create(@Body() dto: CreateBackgroundCheckDto) {
    return this.backgroundChecksService.create(dto);
  }

  // GET /api/background-checks — List background checks with filters
  @Get('background-checks')
  async findAll(
    @Query('status') status?: string,
    @Query('pinpp') pinpp?: string,
    @Query('batchId') batchId?: string,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    return this.backgroundChecksService.findAll({
      status,
      pinpp,
      batchId,
      limit: limit ? parseInt(limit, 10) : undefined,
      offset: offset ? parseInt(offset, 10) : undefined,
    });
  }

  // GET /api/background-checks/:id — Get a single background check
  @Get('background-checks/:id')
  async findOne(@Param('id') id: string) {
    return this.backgroundChecksService.findOne(id);
  }

  // GET /api/background-checks/:id/progress — Query Temporal for progress
  @Get('background-checks/:id/progress')
  async getProgress(@Param('id') id: string) {
    return this.backgroundChecksService.getProgress(id);
  }

  // POST /api/background-checks/:id/cancel — Cancel a running background check
  @Post('background-checks/:id/cancel')
  async cancel(@Param('id') id: string, @Body() dto: CancelBackgroundCheckDto) {
    return this.backgroundChecksService.cancel(id, dto.reason);
  }

  // POST /api/background-checks/:id/retry — Retry failed integrations
  @Post('background-checks/:id/retry')
  async retryFailed(@Param('id') id: string) {
    return this.backgroundChecksService.retryFailed(id);
  }

  // GET /api/background-check-batches — List all batches
  @Get('background-check-batches')
  async listBatches() {
    return this.backgroundChecksService.listBatches();
  }

  // GET /api/background-check-batches/:id — Get a single batch with summary
  @Get('background-check-batches/:id')
  async getBatch(@Param('id') id: string) {
    return this.backgroundChecksService.getBatch(id);
  }
}
