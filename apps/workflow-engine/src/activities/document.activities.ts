import { eq } from 'drizzle-orm';
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import { documents, type SelectDocument } from '@workflow/database';

let db: ReturnType<typeof drizzle> | null = null;

function getDb() {
  if (!db) {
    const pool = new Pool({
      connectionString: process.env.DATABASE_URL,
    });
    db = drizzle(pool);
  }
  return db;
}

export async function validateDocument(
  document: SelectDocument,
): Promise<SelectDocument> {
  const database = getDb();

  await database
    .update(documents)
    .set({ status: 'processing', updatedAt: new Date() })
    .where(eq(documents.id, document.id));

  return { ...document, status: 'processing' };
}

export async function processDocument(
  document: SelectDocument,
): Promise<SelectDocument> {
  // Placeholder for actual document processing logic
  // e.g. parse content, extract text, generate thumbnails, etc.
  return document;
}

export async function markDocumentComplete(
  document: SelectDocument,
): Promise<SelectDocument> {
  const database = getDb();

  await database
    .update(documents)
    .set({ status: 'completed', updatedAt: new Date() })
    .where(eq(documents.id, document.id));

  return { ...document, status: 'completed' };
}

export async function markDocumentFailed(
  document: SelectDocument,
  error: string,
): Promise<SelectDocument> {
  const database = getDb();

  await database
    .update(documents)
    .set({ status: 'failed', updatedAt: new Date() })
    .where(eq(documents.id, document.id));

  return { ...document, status: 'failed' };
}
