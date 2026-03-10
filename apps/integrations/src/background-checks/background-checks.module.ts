import { Module } from '@nestjs/common';
import { DatabaseModule } from '@workflow/database';
import { TemporalModule } from '../temporal/temporal.module';
import { BackgroundChecksService } from './background-checks.service';
import { BackgroundChecksController } from './background-checks.controller';

@Module({
  imports: [DatabaseModule, TemporalModule],
  controllers: [BackgroundChecksController],
  providers: [BackgroundChecksService],
  exports: [BackgroundChecksService],
})
export class BackgroundChecksModule {}
