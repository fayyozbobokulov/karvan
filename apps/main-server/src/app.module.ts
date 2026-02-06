import { Module } from '@nestjs/common';
import { DocumentsModule } from './documents/documents.module';
import { TemporalModule } from './temporal/temporal.module';

@Module({
  imports: [TemporalModule, DocumentsModule],
})
export class AppModule {}
