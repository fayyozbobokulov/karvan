import { eq } from 'drizzle-orm';
import { drizzle } from 'drizzle-orm/node-postgres';
import { Pool } from 'pg';
import { v4 as uuid } from 'uuid';
import {
  documents,
  tasks,
  auditLogs,
  documentRegistry,
  distributions,
  users,
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

export async function validateDocument(input: { documentId: string }) {
  const database = getDb();
  const [doc] = await database
    .select()
    .from(documents)
    .where(eq(documents.id, input.documentId));

  const errors: string[] = [];
  if (!doc) errors.push('Document not found');
  if (!doc?.fileUrl) errors.push('No file attached');
  if (!doc?.title) errors.push('Title is required');
  if (!doc?.metadata) errors.push('Metadata is required');

  return { isValid: errors.length === 0, errors };
}

export async function createTask(input: {
  documentId: string;
  assigneeRole: string;
  actionType: string;
}) {
  const database = getDb();

  const [assignee] = await database
    .select()
    .from(users)
    .where(eq(users.role, input.assigneeRole));

  if (!assignee)
    throw new Error(`No user found with role: ${input.assigneeRole}`);

  const taskId = uuid();
  await database.insert(tasks).values({
    id: taskId,
    documentId: input.documentId,
    assigneeId: assignee.id,
    type: input.actionType, // For backwards compatibility
    actionType: input.actionType as any,
    status: 'pending',
  });

  return { id: taskId, assigneeId: assignee.id };
}

export async function completeTask(input: { taskId: string; action: string }) {
  const database = getDb();
  await database
    .update(tasks)
    .set({ status: input.action as any, completedAt: new Date() })
    .where(eq(tasks.id, input.taskId));
}

export async function updateDocumentStatus(input: {
  documentId: string;
  status: any;
}) {
  const database = getDb();
  await database
    .update(documents)
    .set({ status: input.status, updatedAt: new Date() })
    .where(eq(documents.id, input.documentId));
}

export async function signDocument(input: { documentId: string }) {
  const database = getDb();
  await database
    .update(documents)
    .set({ status: 'signed', signedAt: new Date(), updatedAt: new Date() })
    .where(eq(documents.id, input.documentId));
}

export async function registerDocument(input: { documentId: string }) {
  const database = getDb();
  const year = new Date().getFullYear();

  const countRes = await database.select().from(documentRegistry);
  const seq = String(countRes.length + 1).padStart(5, '0');
  const registryNumber = `GOV-${year}-${seq}`;

  await database.insert(documentRegistry).values({
    documentId: input.documentId,
    registryNumber,
    registeredBy: 'system',
  });

  return { registryNumber };
}

export async function distributeDocument(input: {
  documentId: string;
  registryNumber: string;
}) {
  const database = getDb();
  const allUsers = await database.select().from(users);

  for (const user of allUsers) {
    await database.insert(distributions).values({
      documentId: input.documentId,
      recipientId: user.id,
      channel: 'portal',
    });
  }

  return { distributedTo: allUsers.length };
}

export async function recordAuditLog(input: {
  documentId: string;
  fromStatus: string;
  toStatus: string;
  action: string;
}) {
  const database = getDb();
  await database.insert(auditLogs).values({
    documentId: input.documentId,
    action: input.action,
    fromStatus: input.fromStatus,
    toStatus: input.toStatus,
  });
}

export async function sendNotification(input: {
  userId: string;
  message: string;
}) {
  console.log(`[NOTIFICATION] To: ${input.userId} — ${input.message}`);
}

export async function escalateTask(input: { taskId: string; reason: string }) {
  console.log(`[ESCALATION] Task ${input.taskId} escalated: ${input.reason}`);
}
