import { Body, Controller, Post, BadRequestException } from '@nestjs/common';
import {
  insertDocumentSchema,
  type SelectDocument,
  type SelectTask,
} from '@workflow/database';
import { z, ZodError } from 'zod/v4';
import { DocumentsService } from './documents.service';

const findByIdSchema = z.object({
  id: z.string(),
});

@Controller('documents')
export class DocumentsController {
  constructor(private readonly documentsService: DocumentsService) {}

  @Post('create')
  async create(@Body() body: unknown): Promise<SelectDocument> {
    return this.documentsService.create(this.parse(insertDocumentSchema, body));
  }

  @Post('list')
  async findAll(): Promise<SelectDocument[]> {
    return this.documentsService.findAll();
  }

  @Post('get')
  async findById(@Body() body: unknown): Promise<SelectDocument> {
    const { id } = this.parse(findByIdSchema, body);
    return this.documentsService.findById(id);
  }

  @Post('scenario')
  async createScenario(@Body() body: unknown): Promise<SelectDocument> {
    const schema = z.object({
      title: z.string(),
      authorId: z.string(),
      assigneeId: z.string(),
    });
    return this.documentsService.createGovernmentScenario(
      this.parse(schema, body),
    );
  }

  @Post('action')
  async handleAction(@Body() body: unknown): Promise<{ success: true }> {
    const schema = z.object({
      documentId: z.string(),
      taskId: z.string(),
      action: z.enum(['sign', 'reject']),
      comment: z.string().optional(),
    });
    await this.documentsService.handleAction(this.parse(schema, body));
    return { success: true };
  }

  @Post('tasks')
  async findAllTasks(): Promise<SelectTask[]> {
    return this.documentsService.findAllTasks();
  }

  private parse<T>(schema: z.ZodType<T>, body: unknown): T {
    try {
      return schema.parse(body);
    } catch (error) {
      if (error instanceof ZodError) {
        throw new BadRequestException(error.issues);
      }
      throw error;
    }
  }
}
