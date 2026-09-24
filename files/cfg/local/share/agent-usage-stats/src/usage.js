export const usageFields = ['input_tokens', 'uncached_input_tokens', 'cached_input_tokens',
  'cache_write_input_tokens', 'output_tokens', 'reasoning_output_tokens', 'requests'];

export function sumUsage(rows) {
  return rows.reduce((total, row) => {
    for (const field of usageFields) total[field] += row[field] || 0;
    return total;
  }, Object.fromEntries(usageFields.map(field => [field, 0])));
}

export function selectRows(rows, { client = 'all', model = 'all', from = '', to = '' }) {
  return rows.filter(row => (model === 'all' || row.model === model)
    && (!from || row.day >= from) && (!to || row.day <= to)
    && (client === 'all' || row.by_client[client]))
    .map(row => client === 'all' ? row : {
      ...row, ...row.by_client[client], clients: [client],
    });
}

export function byDay(rows) {
  const days = new Map();
  for (const row of rows) {
    if (!days.has(row.day)) days.set(row.day, []);
    days.get(row.day).push(row);
  }
  return [...days].sort(([a], [b]) => b.localeCompare(a))
    .map(([day, entries]) => ({ day, ...sumUsage(entries) }));
}

export const formatNumber = value => (value || 0).toLocaleString('en-US');
export const cacheRate = (cached, input) => input ? `${(100 * cached / input).toFixed(1)}%` : '—';
