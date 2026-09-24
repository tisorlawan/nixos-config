import { useEffect, useMemo, useRef, useState } from 'react';
import { byDay, cacheRate, formatNumber as fmt, selectRows, sumUsage } from './usage.js';

const clientName = client => client === 'claude' ? 'Claude' : 'Codex';
const time = value => new Intl.DateTimeFormat('en-GB', {
  timeZone: 'Asia/Jakarta', hour: '2-digit', minute: '2-digit', second: '2-digit',
}).format(new Date(value));

function useUsage() {
  const [data, setData] = useState(null);
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(true);
  const [revision, setRevision] = useState(0);
  useEffect(() => {
    let stopped = false, timer, controller;
    async function load() {
      if (document.hidden) {
        timer = setTimeout(load, 15_000);
        return;
      }
      controller = new AbortController();
      const timeout = setTimeout(() => controller?.abort(), 15_000);
      setBusy(true);
      try {
        const response = await fetch('/api/usage', { cache: 'no-store', signal: controller.signal });
        if (!response.ok) throw new Error('Unable to read usage. Check the dashboard service and retry.');
        const next = await response.json();
        if (!Array.isArray(next.rows)) throw new Error('The usage API returned invalid data.');
        if (!stopped) { setData(next); setError(''); }
      } catch (failure) {
        if (!stopped) setError(failure.name === 'AbortError'
          ? 'Refresh timed out. Retry to read current usage.'
          : failure.message);
      } finally {
        clearTimeout(timeout);
        controller = null;
        if (!stopped) { setBusy(false); timer = setTimeout(load, 15_000); }
      }
    }
    function onVisible() {
      if (!document.hidden && !controller) { clearTimeout(timer); load(); }
    }
    load();
    document.addEventListener('visibilitychange', onVisible);
    return () => {
      stopped = true;
      clearTimeout(timer);
      controller?.abort();
      document.removeEventListener('visibilitychange', onVisible);
    };
  }, [revision]);
  return { data, error, busy, refresh: () => setRevision(value => value + 1) };
}

function exportCsv(rows) {
  const fields = ['day', 'model', 'requests', 'threads', 'cached_input_tokens',
    'cache_write_input_tokens', 'uncached_input_tokens', 'input_tokens',
    'output_tokens', 'reasoning_output_tokens'];
  const cell = value => {
    let text = String(value ?? '');
    if (/^[=+@-]/.test(text)) text = "'" + text;
    return '"' + text.replaceAll('"', '""') + '"';
  };
  const csv = [fields.join(','), ...rows.map(row => fields.map(field => cell(row[field])).join(','))].join('\r\n');
  const url = URL.createObjectURL(new Blob([csv], { type: 'text/csv;charset=utf-8' }));
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = 'agent-usage-wib.csv';
  anchor.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}

function Stat({ label, value, note }) {
  return <div className="stat">
    <dt>{label}</dt><dd>{fmt(value)}</dd>{note && <p>{note}</p>}
  </div>;
}

function Composition({ row, max }) {
  const parts = [
    ['read', row.cached_input_tokens], ['write', row.cache_write_input_tokens], ['fresh', row.uncached_input_tokens],
  ];
  return <div className="composition" role="img"
    aria-label={`${fmt(row.cached_input_tokens)} cache read, ${fmt(row.cache_write_input_tokens)} cache write, ${fmt(row.uncached_input_tokens)} fresh input tokens`}>
    {parts.map(([kind, count]) => <span key={kind} className={kind}
      style={{ width: `${max > 0 ? 100 * count / max : 0}%` }} />)}
  </div>;
}

function Sources({ sources }) {
  return <details className="sources">
    <summary>Sources ({sources.filter(source => source.exists).length})</summary>
    <ul>{sources.map(source => <li key={`${source.client}-${source.path}`}>
      <code>{source.path}</code>
      <span>{clientName(source.client)} · {source.error ? 'read error' : source.exists
        ? `${source.files} logs, ${source.requests} requests` : 'no logs'}</span>
      {source.error && <p className="source-error">{source.error}</p>}
    </li>)}</ul>
  </details>;
}

export default function App() {
  const { data, error, busy, refresh } = useUsage();
  const [filters, setFilters] = useState({ client: 'all', model: 'all', from: '', to: '' });
  const [sort, setSort] = useState('recent');
  const invalidRange = !!(filters.from && filters.to && filters.from > filters.to);
  const rows = useMemo(() => {
    const selected = invalidRange ? [] : selectRows(data?.rows || [], filters);
    return selected.sort((a, b) => {
      if (sort === 'cached') return b.cached_input_tokens - a.cached_input_tokens || b.day.localeCompare(a.day);
      if (sort === 'output') return b.output_tokens - a.output_tokens || b.day.localeCompare(a.day);
      return b.day.localeCompare(a.day) || b.cached_input_tokens - a.cached_input_tokens || a.model.localeCompare(b.model);
    });
  }, [data, filters, sort, invalidRange]);
  const totals = sumUsage(rows);
  const days = byDay(rows);
  const availableModels = [...new Set((data?.rows || [])
    .filter(row => filters.client === 'all' || row.by_client[filters.client]).map(row => row.model))].sort();
  const update = (key, value) => setFilters(current => ({ ...current, [key]: value }));
  const setRange = range => {
    if (range === 'all') return setFilters(current => ({ ...current, from: '', to: '' }));
    const today = data.today;
    const start = new Date(`${today}T00:00:00Z`);
    if (range === 'week') start.setUTCDate(start.getUTCDate() - 6);
    setFilters(current => ({ ...current, from: start.toISOString().slice(0, 10), to: today }));
  };
  const hasUsage = data && data.rows.length > 0;
  const defaulted = useRef(false);
  useEffect(() => {
    if (!data || defaulted.current) return;
    defaulted.current = true;
    setFilters(current => ({ ...current, from: data.today, to: data.today }));
  }, [data]);
  const isToday = data && filters.from === data.today && filters.to === data.today;

  return <>
    <main>
      <header className="header">
        <h1>Agent usage</h1>
        <div className="refresh-controls">
          <p className={`status ${error ? 'failed' : ''}`} role="status">
            {busy ? 'Refreshing…' : error ? 'Refresh failed' : `Updated ${time(data.generated_at)}`}
          </p>
          <button onClick={refresh} disabled={busy}>Refresh</button>
        </div>
      </header>

      {error && <div role="alert" className="error">{error}
        {data && <span>Showing the last successful refresh.</span>}
      </div>}

      <div className="toolbar" aria-label="Usage filters">
        <label>Agent<select value={filters.client} onChange={event => {
          setFilters(current => ({ ...current, client: event.target.value, model: 'all' }));
        }}><option value="all">All agents</option><option value="codex">Codex</option><option value="claude">Claude</option></select></label>
        <label className="model-filter">Model<select value={filters.model} onChange={event => update('model', event.target.value)}>
          <option value="all">All models</option>{availableModels.map(model => <option key={model}>{model}</option>)}
        </select></label>
        <label>From<input type="date" value={filters.from} onChange={event => update('from', event.target.value)} aria-invalid={invalidRange} /></label>
        <label>To<input type="date" value={filters.to} onChange={event => update('to', event.target.value)} aria-invalid={invalidRange} /></label>
        <div className="ranges" role="group" aria-label="Date presets">
          <button disabled={!data} className={isToday ? 'selected' : ''} onClick={() => setRange('today')}>Today</button>
          <button disabled={!data} onClick={() => setRange('week')}>7 days</button>
          <button disabled={!data} className={!filters.from && !filters.to ? 'selected' : ''} onClick={() => setRange('all')}>All time</button>
        </div>
      </div>
      {invalidRange && <p role="alert" className="range-error">The start date must be on or before the end date.</p>}

      {!data && !error ? <div className="skeleton" aria-label="Loading usage" aria-busy="true">
        <div /><div /><div />
      </div> : data && <>
        <dl className="stats" aria-label="Filtered usage totals">
          <Stat label="Cache read" value={totals.cached_input_tokens}
            note={`${cacheRate(totals.cached_input_tokens, totals.input_tokens)} of input`} />
          <Stat label="Cache write" value={totals.cache_write_input_tokens} />
          <Stat label="Fresh input" value={totals.uncached_input_tokens} />
          <Stat label="Output" value={totals.output_tokens}
            note={`${fmt(totals.reasoning_output_tokens)} reasoning`} />
        </dl>

        <section className="model-section" id="usage" aria-labelledby="model-title">
          <div className="section-header">
            <h2 id="model-title">By model</h2>
            <div className="table-actions">
              <label className="sort-label">Sort<select value={sort} onChange={event => setSort(event.target.value)}>
                <option value="recent">Newest</option><option value="cached">Cache read</option><option value="output">Output</option>
              </select></label>
              <button disabled={!rows.length} onClick={() => exportCsv(rows)}>Export CSV</button>
            </div>
          </div>
          {!rows.length ? <div className="empty">
            <p>{hasUsage ? 'No usage matches these filters.' : 'No usage recorded yet.'}</p>
            {hasUsage && <button onClick={() => setFilters({ client: 'all', model: 'all', from: '', to: '' })}>Clear filters</button>}
          </div> : <div className="table-scroll" tabIndex="0" role="region" aria-label="Usage by model, scroll horizontally for more columns">
            <table><caption className="sr-only">Token counts grouped by model and WIB calendar day</caption>
              <thead><tr><th scope="col">Day · WIB</th><th scope="col">Model</th><th scope="col">Requests</th>
                <th scope="col">Cache read</th><th scope="col">Cache write</th><th scope="col">Fresh input</th>
                <th scope="col">Output</th><th scope="col">Cache share</th></tr></thead>
              <tbody>{rows.map(row => <tr key={`${row.day}-${row.model}`}>
                <td className="day">{row.day}</td><th scope="row"><span className="model-id">{row.model}</span>
                  <span className="client-label">{row.clients.map(clientName).join(' + ')} · {row.threads} {row.threads === 1 ? 'session' : 'sessions'}</span></th>
                <td>{fmt(row.requests)}</td><td>{fmt(row.cached_input_tokens)}</td>
                <td>{fmt(row.cache_write_input_tokens)}</td><td>{fmt(row.uncached_input_tokens)}</td><td>{fmt(row.output_tokens)}</td>
                <td>{cacheRate(row.cached_input_tokens, row.input_tokens)}</td>
              </tr>)}</tbody>
              <tfoot><tr><th scope="row" colSpan="2">Total</th><td>{fmt(totals.requests)}</td>
                <td>{fmt(totals.cached_input_tokens)}</td><td>{fmt(totals.cache_write_input_tokens)}</td>
                <td>{fmt(totals.uncached_input_tokens)}</td><td>{fmt(totals.output_tokens)}</td>
                <td>{cacheRate(totals.cached_input_tokens, totals.input_tokens)}</td></tr></tfoot>
            </table>
          </div>}
        </section>

        {days.length > 0 && <section className="daily-section" aria-labelledby="daily-title">
          <div className="section-header"><h2 id="daily-title">Input by day</h2>
            <div className="legend"><span><i className="read" />Cache read</span><span><i className="write" />Cache write</span><span><i className="fresh" />Fresh input</span></div>
          </div>
          <div className="daily-list">{days.map(day => <div className="daily-row" key={day.day}>
            <span className="day">{day.day}</span><Composition row={day} max={Math.max(...days.map(value => value.input_tokens))} />
            <span className="daily-count">{fmt(day.cached_input_tokens)}</span>
            <span className="daily-rate">{cacheRate(day.cached_input_tokens, day.input_tokens)}</span>
          </div>)}</div>
        </section>}

        <Sources sources={data.sources} />
      </>}
      <footer>Days are WIB (UTC+7). Cache share = cache read ÷ total input, which includes cache writes.</footer>
    </main>
  </>;
}
