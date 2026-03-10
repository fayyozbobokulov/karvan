/**
 * Resolve a dot-notation path from an object.
 * Returns `unknown` since JSON values are inherently untyped.
 */
export function getByPath(obj: Record<string, unknown>, path: string): unknown {
  return path.split('.').reduce<unknown>((acc, key) => {
    if (acc == null || typeof acc !== 'object') return undefined;
    return (acc as Record<string, unknown>)[key];
  }, obj);
}

/**
 * Walk a JSON tree and replace $placeholder tokens with values from searchCriteria.
 */
export function replacePlaceholders(
  template: unknown,
  searchCriteria: Record<string, unknown>,
): unknown {
  if (typeof template === 'string' && template.startsWith('$')) {
    const path = template.slice(1);
    return getByPath(searchCriteria, path) ?? template;
  }
  if (Array.isArray(template)) {
    return template.map((item) => replacePlaceholders(item, searchCriteria));
  }
  if (template !== null && typeof template === 'object') {
    const result: Record<string, unknown> = {};
    for (const [key, value] of Object.entries(template)) {
      result[key] = replacePlaceholders(value, searchCriteria);
    }
    return result;
  }
  return template;
}
