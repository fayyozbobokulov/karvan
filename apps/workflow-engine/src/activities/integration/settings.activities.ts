import { eq, and, inArray } from 'drizzle-orm';
import {
  integrationSettings,
  type SelectIntegrationSetting,
} from '@workflow/database';
import { getDb } from './db';

export async function loadActiveIntegrationSettings(input: {
  settingIds?: string[];
}): Promise<SelectIntegrationSetting[]> {
  const database = getDb();

  let rows: SelectIntegrationSetting[];

  if (input.settingIds && input.settingIds.length > 0) {
    rows = await database
      .select()
      .from(integrationSettings)
      .where(inArray(integrationSettings.id, input.settingIds));
  } else {
    rows = await database
      .select()
      .from(integrationSettings)
      .where(
        and(
          eq(integrationSettings.isActive, true),
          eq(integrationSettings.isAvailable, true),
        ),
      );
  }

  // Topological sort: parents before children
  const idSet = new Set(rows.map((r) => r.id));
  const sorted: SelectIntegrationSetting[] = [];
  const visited = new Set<string>();

  function visit(id: string) {
    if (visited.has(id)) return;
    visited.add(id);
    const row = rows.find((r) => r.id === id);
    if (!row) return;
    if (row.parentId && idSet.has(row.parentId)) {
      visit(row.parentId);
    }
    sorted.push(row);
  }

  for (const row of rows) {
    visit(row.id);
  }

  return sorted;
}
