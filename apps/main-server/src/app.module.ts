import { Module } from '@nestjs/common';
import { DocumentsModule } from './documents/documents.module';
import { TemporalModule } from './temporal/temporal.module';
import { FlowsModule } from './flows/flows.module';

@Module({
  imports: [TemporalModule, DocumentsModule, FlowsModule],
})
export class AppModule {}
