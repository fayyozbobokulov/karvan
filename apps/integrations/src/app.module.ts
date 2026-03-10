import { Module } from '@nestjs/common';
import { DatabaseModule } from '@workflow/database';
import { TemporalModule } from './temporal/temporal.module';
import { BackgroundChecksModule } from './background-checks/background-checks.module';
import { IntegrationSettingsModule } from './integration-settings/integration-settings.module';
import { RecordsModule } from './records/records.module';
import { EventHandlersModule } from './event-handlers/event-handlers.module';

@Module({
  imports: [
    DatabaseModule,
    TemporalModule,
    BackgroundChecksModule,
    IntegrationSettingsModule,
    RecordsModule,
    EventHandlersModule,
  ],
})
export class AppModule {}
