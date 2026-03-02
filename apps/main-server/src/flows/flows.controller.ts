import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { FlowsService } from './flows.service';
import { unitTypeEnum, flowInstanceStatusEnum } from '@workflow/database';

// ── DTOs ──────────────────────────────────────────────────────────────────

class StartFlowDto {
  flowDefinitionId!: string;
  roleAssignments!: Record<string, string>;
  variables!: Record<string, unknown>;
  startedBy?: string;
}

class SignalFlowDto {
  nodeId!: string;
  action!: string;
  comment?: string;
  data?: Record<string, unknown>;
}

// ── Controller ────────────────────────────────────────────────────────────

@Controller('api')
export class FlowsController {
  constructor(private readonly flowsService: FlowsService) {}

  // POST /api/flows/start — Start a new flow instance
  @Post('flows/start')
  async startFlow(@Body() dto: StartFlowDto) {
    return this.flowsService.startFlow(dto);
  }

  // POST /api/flows/:id/signal — Send human decision signal
  @Post('flows/:id/signal')
  async signalFlow(
    @Param('id') flowInstanceId: string,
    @Body() dto: SignalFlowDto,
  ) {
    return this.flowsService.signalFlow(flowInstanceId, dto);
  }

  // GET /api/flows/:id/status — Query Temporal for current state
  @Get('flows/:id/status')
  async getFlowStatus(@Param('id') flowInstanceId: string) {
    return this.flowsService.getFlowStatus(flowInstanceId);
  }

  // GET /api/flows/:id/audit — Get audit trail from DB
  @Get('flows/:id/audit')
  async getFlowAudit(@Param('id') flowInstanceId: string) {
    return this.flowsService.getFlowAudit(flowInstanceId);
  }

  // GET /api/flows/:id — Get flow instance detail with graph + unit instances
  @Get('flows/:id')
  async getFlowInstance(@Param('id') flowInstanceId: string) {
    return this.flowsService.getFlowInstance(flowInstanceId);
  }

  // GET /api/unit-definitions — List unit catalog
  @Get('unit-definitions')
  async getUnitDefinitions(
    @Query('type') type?: (typeof unitTypeEnum.enumValues)[number],
  ) {
    return this.flowsService.getUnitDefinitions(type);
  }

  // GET /api/flow-definitions — List flow templates
  @Get('flow-definitions')
  async getFlowDefinitions(@Query('category') category?: string) {
    return this.flowsService.getFlowDefinitions(category);
  }

  // GET /api/my-tasks — Get pending tasks for current user
  @Get('my-tasks')
  async getMyTasks(@Query('userId') userId: string) {
    return this.flowsService.getMyTasks(userId);
  }

  // GET /api/flow-instances — List all flow instances
  @Get('flow-instances')
  async listFlowInstances(
    @Query('status')
    status?: (typeof flowInstanceStatusEnum.enumValues)[number],
  ) {
    return this.flowsService.listFlowInstances(status);
  }
}
