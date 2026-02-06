import { Body, Controller, Post, BadRequestException } from '@nestjs/common';
import { insertDocumentSchema, type SelectDocument } from '@workflow/database';
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
