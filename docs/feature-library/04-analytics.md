# Feature Library · 04 · Analytics & Reporting

> Foundation: AMDS v1.0 · Inherits [`00-framework.md`](00-framework.md). Features: **Dashboard Analytics · Reports**.

---

## Feature: Dashboard Analytics

### 1. Purpose
Compute, cache, and serve the KPIs, trends, breakdowns, and alerts that power the four dashboard archetypes (Executive / Operational / Monitoring / Analytics), scoped to the user's role, sites, and permissions, fast enough for a "glance in 5 seconds" experience and honest about data freshness.

### 2. Business Flow
1. **Ingest** — domain services emit events (`work_order.completed`, `incident.opened`, `approval.decided`) to the bus; an ETL/streaming pipeline lands them in a **warehouse** (columnar store) and/or maintains **pre-aggregated rollups** (per day × dimension).
2. **Define** — each metric has a definition (source, aggregation, unit, "good direction", target, thresholds) in a metric registry; dashboards are compositions of metric definitions + layout, configurable per role.
3. **Request** — the mobile app calls a **BFF dashboard endpoint** with `period` + `scope`; the BFF resolves the user's allowed scope, fans out to the metric service / rollup store, assembles a **partial-tolerant** response (each block succeeds or fails independently), and returns it with a `generatedAt` + `dataThrough` timestamp.
4. **Cache** — results cached (per user-scope + period) at the edge/Redis with short TTLs; monitoring dashboards use a live stream instead.
5. **Consume** — the app renders KPIs → priorities → charts → activity → quick actions; every KPI links to a filtered list; the global filter re-queries everything.
6. **Alert** — threshold breaches produce alert-strip items and (via Notifications) pushes.
7. **Drill** — Analytics dashboards support dimension pivots and segment drill-downs against the warehouse.

### 3. UX Flow
```
Open app → Dashboard (role-appropriate archetype)
  cached paints instantly ("Updated 2m ago") + skeleton for pending blocks → background refresh
  → filter (period / site / team) → all blocks re-query → active chips
  → tap KPI → filtered List View
  → tap chart → Analytics dashboard (that metric, range)  → change dimension / compare / drill segment → breadcrumb
  → "View as table" on any chart → data table
  → pull-to-refresh → revalidate in place (no re-animation), "Updated just now"
Monitoring: auto-refresh 15–60s, diff updates, new critical alert sorts to top (no modal)
```
Screens: [`../screen-library/02-dashboard.md`](../screen-library/02-dashboard.md) + [`../specs/dashboard.md`](../specs/dashboard.md); dashboard system doc [`../07-dashboard-system.md`](../screen-library/dashboard-system.md).

### 4. Screen Mapping
| Screen | Route | Template |
|---|---|---|
| Operational Dashboard | `/dashboard` | 02 §2.2 (full spec: specs/dashboard.md) |
| Executive Dashboard | `/dashboard/executive` | 02 §2.1 |
| Monitoring Dashboard | `/dashboard/monitoring` | 02 §2.3 |
| Analytics Dashboard | `/dashboard/analytics` or `/analytics/:metric` | 02 §2.4 |
| Chart "view as table" | bottom sheet | data-display |

### 5. Required Components
KPI Card · Chart Card · List (activity, priorities, breakdown) · Table (segment breakdown, "view as table") · Chips/Segmented (filters, range) · Banner (alerts) · Skeleton (dashboard) · Pull-to-refresh · FAB — all [16 §2,9,10,11](../component-library/api-reference.md). Feature composites: `MetricDeltaChip` (sentiment-aware), `Sparkline`, `HealthBar`, `DrillBreadcrumb`.

### 6. Database / Store Suggestions
| Store | Contents | Notes |
|---|---|---|
| `metric_definition` (OLTP config) | `key, name, source_event, aggregation, unit, good_direction, target, thresholds (jsonb), category, roles_visible[]` | the registry |
| `dashboard_definition` (OLTP config) | `key, role, layout (jsonb: ordered blocks referencing metric keys), archetype` | per-role dashboards |
| **Rollup tables** (warehouse or OLTP) | `metric_rollup(metric_key, tenant_id, dim (site/team/category/…), dim_value, bucket_date, value)` | pre-aggregated per day × dimension |
| **Fact tables** (warehouse) | `fact_work_order`, `fact_incident`, `fact_approval` — one row per event, wide dimensions | for ad-hoc Analytics drill |
| `dashboard_snapshot` (cache) | `user_scope_hash, period, payload (jsonb), generated_at, data_through` | Redis or a table; short TTL |
| `metric_alert` | `id, tenant_id, metric_key, dim_value, threshold, breached_at, resolved_at, severity` | drives alert strip + notifications |
| `saved_view` | `id, user_id, screen, params (jsonb), name, is_default` | Analytics saved filters |

### 7. API Endpoint Suggestions
| Method · Path | Purpose | AuthZ |
|---|---|---|
| `GET /v1/dashboard?variant=operational&period=week&scope[site]=EAST` | assembled, partial-tolerant dashboard payload (`blocks{}` each with `status`) | authenticated; server intersects `scope` with allowed |
| `GET /v1/metrics/{key}?period=&scope=&compare=prev` | one metric: value, delta, sparkline, target status | metric's `roles_visible` |
| `GET /v1/analytics?metric=&range=&dimension=&segment=&compare=&cursor=` | trend + segment breakdown (paged) | `analytics:read` |
| `GET /v1/analytics/{metric}/table?...` | the numeric table alternative for a chart | same |
| `GET /v1/dashboard/alerts?scope=` | active alert-strip items | authenticated |
| `GET/POST/DELETE /v1/me/saved-views` | Analytics saved filters | self |
| **Realtime** (monitoring): `GET /v1/monitoring/stream` (SSE/WS) — health, incident, metric deltas | `monitoring:read` |
| `GET /v1/dashboard/executive?period=` | pre-aggregated exec summary (heavier cache) | `dashboard:executive` |

### 8. State Management Suggestions
- `DashboardController` → `DashboardUiState { header, filter, freshness, connectivity, blocks: { kpis: BlockState<...>, needsYou, trend, activity, quickActions } }` (see [`../specs/dashboard.md`](../specs/dashboard.md) §9.1). Blocks load independently; cache the last successful state per `(variant, period, scope)` (encrypted); fresh 5 min → stale styling → hard-expire 24 h.
- Refresh triggers: cold start, foreground if > 5 min, pull-to-refresh, tab double-tap; debounce so back-within-30s doesn't refetch; cancel in-flight on navigate-away.
- `dashboardFilterProvider` (period + scope) is global to the dashboard; changing it invalidates all block queries.
- Monitoring: a `monitoringStreamProvider` (SSE) applies **diffs** to keyed collections; a heartbeat watchdog flips to "stale" if no update past the interval.
- Analytics: `analyticsController` with `saved views`; debounce control changes 250 ms; cache per filter-combo hash for instant back-nav; every chart has a `viewAsTable` toggle backed by a separate query.

### 9. Jetpack Compose Implementation Suggestions
- `:feature:dashboard`. `CustomScrollView`-equivalent = `LazyColumn` of block composables; each block reads a `collectAsStateWithLifecycle` slice.
- Charts: **Vico**; prepare series off the main thread (`withContext(Dispatchers.Default)`); disable draw animation when reduced-motion.
- Monitoring: OkHttp SSE / WebSocket → a `Flow<MonitoringEvent>`; `LazyColumn` with stable keys + `animateItemPlacement()`; never replace the whole list.
- `MetricDeltaChip` computes tint from `goodDirection` × sign, not raw sign.

### 10. Flutter Implementation Suggestions
- `feature_dashboard`. `CustomScrollView` + slivers; `SliverAppBar(large)` + pinned filter bar.
- Charts: **fl_chart** in `AmdsChartCard`; `compute()` for point prep / LTTB downsample; `MediaQuery.disableAnimations` gates the curve animation.
- Monitoring: `web_socket_channel` / SSE (`http` + a line splitter) → `StreamProvider`; `SliverAnimatedList` with keyed diffs.
- Snapshot cache in `hive`/`drift` keyed by scope-hash; paint before the network returns.

### 11. React Native Implementation Suggestions
- `features/dashboard`. `ScrollView`/`SectionList` of memoized blocks; React Query per block with `staleTime`.
- Charts: **victory-native** / `react-native-svg`; `useMemo` for series; `animate={!reduceMotion}`.
- Monitoring: `reconnecting-websocket` / `react-native-sse` → `queryClient.setQueryData` diff updates; `FlashList` + `LayoutAnimation`.
- Persist the last snapshot in MMKV; hydrate React Query cache on mount.

### 12. Security Considerations
- **Scope enforcement server-side** — the client sends a desired `scope`, the server intersects it with the user's authorized sites/teams/regions; a user can never widen scope via the filter or a crafted request.
- **Row-level aggregation leakage** — ensure aggregates can't be used to infer restricted rows (e.g. a count of 1 in a segment the user shouldn't see) — apply minimum-cohort suppression ("< 5") on sensitive dimensions.
- **Metric visibility** — each `metric_definition.roles_visible` gates the metric; blocks the user can't see are omitted, not returned-and-hidden.
- **PII in breakdowns** — Analytics drill-downs by person/employee are gated by `pii:read`; otherwise anonymized.
- **Caching** — cache keys include the full scope + user-permission fingerprint so a permission change doesn't serve stale over-scoped data; short TTLs; invalidate on `permissions_changed`.
- **Export from Analytics** goes through the Reports/Export path (governance rules apply).
- **Monitoring stream** — the SSE/WS channel authenticates the user and only streams events for services/sites in scope; no tenant cross-talk on a shared broker (topic-per-tenant or filtered).

### 13. Scalability Considerations
- **Never aggregate OLTP at request time** for dashboards — read from **pre-computed rollups** (per day × dimension) refreshed by a streaming/batch pipeline; the request just slices and sums a small rollup set.
- **BFF assembly** — fan out to metric queries in parallel with a per-block timeout; return partials; cache the assembled payload per `(variant, period, scope-hash)` in Redis (TTL 30–120 s operational, longer for executive).
- **Analytics ad-hoc** — run against a columnar warehouse (BigQuery / ClickHouse / Redshift), not Postgres; pre-materialize the common cuts; cap `range` and downsample series server-side (≤ 120 points).
- **Monitoring** — the stream is fed by the metrics pipeline, not by querying stores per tick; the mobile client gets throttled deltas (≤ 1/s), keyed and diffed.
- **Shift-start thundering herd** — thousands of dashboard requests at 07:00: pre-warm the cache with a scheduled job for common scopes; serve stale-while-revalidate.
- **Cost control** — warehouse queries are expensive; cache aggressively, restrict raw drill to a role, and offer scheduled reports for heavy recurring needs (see Reports).

---

## Feature: Reports

### 1. Purpose
Let users run parameterized, saved, shareable reports (operational, financial, compliance), view the rendered result on mobile, export it as a file (CSV/XLSX/PDF), and schedule recurring deliveries — distinct from the exploratory Analytics dashboard.

### 2. Business Flow
1. **Author** — an analyst/admin defines a **report** (a query template + a parameter schema + an output layout: summary tiles, a chart, a table, a narrative) in a report catalog; assigns visibility (roles/tenants) and allowed export formats.
2. **Discover** — users browse/search the catalog, favorite frequent reports.
3. **Run** — a user opens a report, sets parameters (date range, scope, grouping, thresholds — smart defaults), runs it. Short reports render inline; long ones become **async jobs** that finish and notify.
4. **Consume** — view summary + chart + sortable/paginated table + narrative + `generatedAt`/`dataThrough`; sort/paginate the table; "View as table" on the chart.
5. **Export** — choose format + scope (current view / all columns / selected rows) → sync download (small) or async job → secure, expiring link delivered by notification; governance rules exclude restricted fields.
6. **Schedule** — set a cadence + recipients + format; a job runs it and emails/notifies the output; failures alert the owner.
7. **Audit** — every run and export is logged (who, what params, when, what was included).

### 3. UX Flow
```
Nav "Reports" → Reports Dashboard (All / Favorites / Scheduled, categories, search)
  → tap report → Report Detail: parameters card → "Run" → output (tiles + chart + table + narrative)
      → sort/paginate table · "View as table" on chart · "Edit parameters" → re-run
      → "Export" → Export Screen (format, scope, options, delivery) → download / "we'll notify you" → notification → secure link
      → "Schedule" → cadence + recipients + format → saved
Scheduled tab → manage deliveries (pause / run now / view last output / fix failures)
```
Screens: [`../screen-library/07-reporting.md`](../screen-library/07-reporting.md).

### 4. Screen Mapping
| Screen | Route | Template |
|---|---|---|
| Reports Dashboard | `/reports?tab=all\|favorites\|scheduled` | 07 §7.1 (Archetype C + B strip) |
| Report Detail | `/reports/:id?params=<encoded>` | 07 §7.2 (D + H) |
| Export Screen | `/export?source=<ref>` (modal) | 07 §7.3 (Archetype A + E) |
| Export history | `/reports/exports` | Archetype C |
| Schedule editor | bottom sheet / `/reports/:id/schedule` | Archetype E |

### 5. Required Components
List/Cards (catalog) · Search · Chips (categories) · Form engine (parameters) · KPI cards + Chart Card + Table (output) · Bottom Sheet (export options) · Radio/Segmented (format, scope) · Progress (async job) · Snackbar/Banner (export ready) · Badge (favorite ★, schedule status) — [16 §2,3,4,9,10,11,12,14](../component-library/api-reference.md). Feature composites: `ParameterForm`, `ReportOutput`, `ExportSheet`, `ScheduleEditor`.

### 6. Database / Store Suggestions
| Entity | Key columns | Notes |
|---|---|---|
| `report_definition` | `id, tenant_id?, key, name, description, category, query_template (ref), param_schema (jsonb), layout (jsonb), formats_allowed[], roles_visible[], supports_schedule` | catalog |
| `report_run` | `id, report_id, requested_by, params (jsonb), params_hash, status (queued/running/succeeded/failed), started_at, finished_at, row_count, output_ref?, data_through, trace_id` | one per execution |
| `report_favorite` | `user_id, report_id` | |
| `report_schedule` | `id, report_id, params (jsonb), cadence (cron), timezone, recipients[], formats[], next_run_at, last_run_id, active, created_by` | |
| `export_job` | `id, source_ref (report_run \| list-query \| analytics), format, scope, options (jsonb), status, file_ref, size_bytes, expires_at, requested_by, trace_id` | |
| `report_run_cache` | `params_hash → output_ref` | reuse identical runs |
| Output storage | object store (PDF/XLSX/CSV), signed URLs, lifecycle-expire | |

### 7. API Endpoint Suggestions
| Method · Path | Purpose | AuthZ |
|---|---|---|
| `GET /v1/reports?category=&q=&favorite=&scheduled=&cursor=` | catalog | `reports:read` (+ per-report `roles_visible`) |
| `GET /v1/reports/{id}` | definition + param schema | as above |
| `POST /v1/reports/{id}/run` | `{params}` → `200 {run}` (sync) or `202 {jobId}` (async) | as above |
| `GET /v1/report-runs/{id}` | status + result (`{summary, series, table (paged), narrative, generatedAt, dataThrough}`) | requester / `reports:read` |
| `GET /v1/report-runs/{id}/table?sort=&cursor=` | paged table slice | as above |
| `POST /v1/reports/{id}/favorite` · `DELETE …` | toggle | self |
| `POST /v1/exports` | `{sourceRef, format, scope, options}` → `200 {fileRef}` or `202 {jobId}` | permission on the source + `export:<source>` |
| `GET /v1/export-jobs/{id}` | status + signed URL when ready | requester |
| `GET /v1/me/exports?cursor=` | export history (re-download while valid) | self |
| `GET/POST/PATCH/DELETE /v1/reports/{id}/schedules` | manage deliveries | `reports:schedule` |
| `POST /v1/report-schedules/{id}/run-now` | ad-hoc trigger | owner |

### 8. State Management Suggestions
- `ReportCatalogController` (Archetype C) — favorites default tab if any; category filter; search.
- `ReportDetailController` — `parameterForm` (the form engine over `param_schema`) → `run()` → polls `report_run` if async → `output` state (`Loading/Empty(noData)/Data/Error/Timeout→async`). Cache the run by `params_hash` for instant back-nav + offline. Table sort/paginate = separate query.
- `ExportController` — computes the summary line (row/column count) from scope+format; picks sync vs async by size; on async → dismiss + rely on a notification; exposes `exportHistory`.
- `ScheduleController` — CRUD over `report_schedule`; shows `last_run` status.
- Offline: catalog + favorites cached; "Run"/"Export" disabled; a cached run for identical params shows "as of HH:MM".

### 9. Jetpack Compose Implementation Suggestions
- `:feature:reports`. Catalog: Paging 3. Detail: collapsible parameters via `AnimatedVisibility`; output = `LazyColumn` (tiles row, `AmdsChartCard`, a paginated table composable, narrative `Text`).
- Async run: a `WorkManager`-independent poll loop in the VM (`while(active) { delay(2s); fetch }`) or subscribe to a `report.run.finished` notification.
- Export: `FileProvider` + `Intent.ACTION_SEND` / Storage Access Framework `CreateDocument` — **never** a raw download link (inert in a webview).

### 10. Flutter Implementation Suggestions
- `feature_reports`. Catalog: `PagedListView`. Detail: `ExpansionTile` params + `ReportOutput` widget; table via `data_table_2` (server sort/paginate) or the phone row-transformation.
- Async: poll `report_run` via a `Stream.periodic` provider until terminal, or listen for the completion notification.
- Export: write bytes to a temp dir → `Share.shareXFiles` / `SAF`; async → show a "we'll notify you" snackbar; `open_filex` to open a downloaded file.
- Charts via `fl_chart` in `AmdsChartCard`; `compute` for formatting.

### 11. React Native Implementation Suggestions
- `features/reports`. Catalog: `FlashList` + React Query infinite. Detail: parameters via `react-hook-form` over the schema; output components memoized.
- Async: React Query `refetchInterval` on the run query while `status` is non-terminal; or a WS/notification trigger.
- Export: `react-native-blob-util` to fetch bytes → `react-native-share` / `Share`; async → toast + rely on notification; `FileViewer` to open.
- Table: `FlashList` grid with server-side sort/pagination.

### 12. Security Considerations
- **Governance/field exclusion is server-enforced** — the server strips restricted columns from any output regardless of the client's "all columns" choice; the client only reflects what's excluded ("Some fields are excluded per data policy").
- **Row scoping** — a report's query is parameterized with the caller's tenant + authorized scope; a user can't run a report over data they can't see, and scheduled reports run **as the schedule owner's** permissions (re-evaluated at run time, not at creation).
- **Export delivery** — files stored with a **short-lived, signed, permission-checked** URL; never a public link; no sensitive data in the URL itself; the app hands files to the OS share/save, never an `<a download>`.
- **CSV injection** — prefix cells starting with `= + - @` with a quote; set proper content-type; UTF-8 BOM for Excel.
- **PDF** — a real server-rendered report (title, applied filters, timestamp, page numbers), watermarked with the requester + timestamp for compliance reports; optional password protection.
- **Schedule recipients** — only internal users / verified addresses; adding an external recipient requires elevated permission + is audited.
- **Audit** — `report_run` + `export_job` record params, row count, and (hash of) output for every execution; retained per policy.
- **Rate limiting** — cap runs/exports per user per hour; heavy reports are async-only.

### 13. Scalability Considerations
- **Compute reports server-side against the warehouse**, never on the client; parameterize + cache by `params_hash` (identical re-runs return the cached `output_ref`).
- **Async by default for anything non-trivial** — a job queue + a pool of report workers; the mobile client polls a cheap status endpoint or gets a push; the UI never blocks.
- **Output storage** — object storage with lifecycle rules (auto-expire exports after e.g. 7 days); CDN for repeated downloads.
- **Scheduled reports** — a scheduler enqueues jobs at `next_run_at`; stagger cadences to avoid a top-of-hour spike; back-pressure the worker pool; alert + retry on failure.
- **Large tables on mobile** — server-side sort + keyset pagination; the phone renders a row-transformation of key columns; the full grid is a tablet/landscape affordance.
- **Warehouse cost** — pre-materialize common report shapes; concurrency-limit ad-hoc runs; separate the reporting warehouse from OLTP so heavy queries never touch the transactional path.
- **Multi-tenant fairness** — per-tenant quotas on concurrent runs + export volume so one tenant's month-end can't starve others.
