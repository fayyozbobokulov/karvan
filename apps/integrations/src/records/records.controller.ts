import { Body, Controller, Get, Param, Post, Put, Query } from '@nestjs/common';
import { RecordsService } from './records.service';
import type { InsertRecord, InsertRecordType } from '@workflow/database';

// ── Controller ────────────────────────────────────────────────────────────

@Controller('api')
export class RecordsController {
  constructor(private readonly recordsService: RecordsService) {}

  // GET /api/records — List records with filters
  @Get('records')
  async findAll(
    @Query('pinpp') pinpp?: string,
    @Query('recordTypeId') recordTypeId?: string,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string,
  ) {
    return this.recordsService.findAll({
      pinpp,
      recordTypeId,
      limit: limit ? parseInt(limit, 10) : undefined,
      offset: offset ? parseInt(offset, 10) : undefined,
    });
  }

  // GET /api/records/by-pinpp/:pinpp — Get all records for a person
  @Get('records/by-pinpp/:pinpp')
  async findByPinpp(@Param('pinpp') pinpp: string) {
    return this.recordsService.findByPinpp(pinpp);
  }

  // GET /api/records/:id — Get a single record with history
  @Get('records/:id')
  async findOne(@Param('id') id: string) {
    return this.recordsService.findOne(id);
  }

  // GET /api/record-types — List all record types
  @Get('record-types')
  async findAllRecordTypes() {
    return this.recordsService.findAllRecordTypes();
  }

  // GET /api/record-types/:id — Get a single record type
  @Get('record-types/:id')
  async findOneRecordType(@Param('id') id: string) {
    return this.recordsService.findOneRecordType(id);
  }

  // POST /api/record-types — Create a new record type
  @Post('record-types')
  async createRecordType(@Body() dto: InsertRecordType) {
    return this.recordsService.createRecordType(dto);
  }

  // PUT /api/record-types/:id — Update a record type
  @Put('record-types/:id')
  async updateRecordType(
    @Param('id') id: string,
    @Body() dto: Partial<InsertRecordType>,
  ) {
    return this.recordsService.updateRecordType(id, dto);
  }
}
