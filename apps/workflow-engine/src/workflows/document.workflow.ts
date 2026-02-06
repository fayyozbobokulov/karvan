import { proxyActivities, ApplicationFailure } from '@temporalio/workflow';
import type { SelectDocument } from '@workflow/database';
import type * as activities from '../activities/document.activities';

const {
  validateDocument,
  processDocument,
  markDocumentComplete,
  markDocumentFailed,
} = proxyActivities<typeof activities>({
  startToCloseTimeout: '30s',
  retry: {
    maximumAttempts: 3,
  },
});

export async function documentProcessingWorkflow(
  document: SelectDocument,
): Promise<SelectDocument> {
  let current = document;

  try {
    current = await validateDocument(current);
    current = await processDocument(current);
    current = await markDocumentComplete(current);
    return current;
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    await markDocumentFailed(current, message);
    throw ApplicationFailure.nonRetryable(
      `Document processing failed: ${message}`,
    );
  }
}
