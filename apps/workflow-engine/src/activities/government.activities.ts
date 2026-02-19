import { eq, and } from 'drizzle-orm';
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import {
  documents,
  users,
  tasks,
  type SelectDocument,
  type SelectUser,
  type SelectTask,
} from '@workflow/database';

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

export async function notifyUser(params: { userId: string; message: string }) {
  const database = getDb();
  const [user] = await database
    .select()
    .from(users)
    .where(eq(users.id, params.userId));

  if (!user) {
    throw new Error(`User ${params.userId} not found`);
  }

  // Simulate notification (log to console)
  console.log(
    `[NOTIFICATION] To: ${user.email} (${user.name}) - Message: ${params.message}`,
  );
  return { sent: true, userId: params.userId };
}

export async function createTask(params: {
  documentId: string;
  assigneeId: string;
  type: string;
}): Promise<SelectTask> {
  const database = getDb();

  const [task] = await database
    .insert(tasks)
    .values({
      documentId: params.documentId,
      assigneeId: params.assigneeId,
      type: params.type,
      status: 'pending',
    })
    .returning();

  // Notify the assignee
  await notifyUser({
    userId: params.assigneeId,
    message: `You have a new ${params.type} task for document ${params.documentId}`,
  });

  return task;
}

export async function signDocument(params: {
  documentId: string;
  taskId: string;
}) {
  const database = getDb();

  await database.transaction(async (tx) => {
    // 1. Update task
    await tx
      .update(tasks)
      .set({ status: 'completed', updatedAt: new Date() })
      .where(eq(tasks.id, params.taskId));

    // 2. Update document status
    await tx
      .update(documents)
      .set({ status: 'signed', updatedAt: new Date() })
      .where(eq(documents.id, params.documentId));
  });

  return { success: true };
}

export async function rejectDocument(params: {
  documentId: string;
  taskId: string;
  comment: string;
}) {
  const database = getDb();

  await database.transaction(async (tx) => {
    // 1. Update task
    await tx
      .update(tasks)
      .set({
        status: 'rejected',
        comment: params.comment,
        updatedAt: new Date(),
      })
      .where(eq(tasks.id, params.taskId));

    // 2. Update document status
    await tx
      .update(documents)
      .set({ status: 'rejected', updatedAt: new Date() })
      .where(eq(documents.id, params.documentId));
  });

  return { success: true };
}

export async function archiveDocument(documentId: string) {
  const database = getDb();

  await database
    .update(documents)
    .set({ status: 'completed', updatedAt: new Date() })
    .where(eq(documents.id, documentId));

  return { archived: true };
}
