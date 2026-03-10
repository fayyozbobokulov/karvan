import { Module } from '@nestjs/common';
import { DatabaseModule } from '@workflow/database';
import { EventHandlersService } from './event-handlers.service';
import { EventHandlersController } from './event-handlers.controller';

@Module({
  imports: [DatabaseModule],
  controllers: [EventHandlersController],
  providers: [EventHandlersService],
  exports: [EventHandlersService],
})
export class EventHandlersModule {}
