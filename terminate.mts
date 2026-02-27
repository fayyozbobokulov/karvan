import { Client, Connection } from '@temporalio/client';

async function main() {
  const conn = await Connection.connect({ address: 'localhost:7233' });
  const client = new Client({ connection: conn });

  const workflowId = 'flow-incoming_letter-1772190277571';
  try {
    const handle = client.workflow.getHandle(workflowId);
    await handle.terminate('Corrupted workflow history');
    console.log('Terminated:', workflowId);
  } catch (e: any) {
    console.error('Failed:', e.message);
  }

  process.exit(0);
}
main();
