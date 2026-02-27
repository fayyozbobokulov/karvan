import { Module } from '@nestjs/common';
import { DocumentsModule } from './documents/documents.module';
import { TemporalModule } from './temporal/temporal.module';
import { FlowsModule } from './flows/flows.module';
import { NotificationsModule } from './notifications/notifications.module';

@Module({
  imports: [TemporalModule, DocumentsModule, FlowsModule, NotificationsModule],
})
export class AppModule {}
