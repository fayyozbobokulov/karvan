import { Module } from '@nestjs/common';
import { DatabaseModule } from '@workflow/database';
import { RecordsService } from './records.service';
import { RecordsController } from './records.controller';

@Module({
  imports: [DatabaseModule],
  controllers: [RecordsController],
  providers: [RecordsService],
  exports: [RecordsService],
})
export class RecordsModule {}
