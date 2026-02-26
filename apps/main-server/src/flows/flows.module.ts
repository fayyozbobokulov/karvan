import { Module } from '@nestjs/common';
import { DatabaseModule } from '@workflow/database';
import { FlowsService } from './flows.service';
import { FlowsController } from './flows.controller';
import { TemporalModule } from '../temporal/temporal.module';

@Module({
  imports: [DatabaseModule, TemporalModule],
  controllers: [FlowsController],
  providers: [FlowsService],
  exports: [FlowsService],
})
export class FlowsModule {}
