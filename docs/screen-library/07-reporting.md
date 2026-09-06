# Screen Library · 07 · Reporting

> Foundation: AMDS v1.0 · Archetypes: **C — List** + **B — Dashboard** for the hub, **D — Detail** + **H — Content** for a report, **A — Focused Task** for Export.
> Deeper references: [`dashboard-system.md`](dashboard-system.md), [`../feature-library/04-analytics.md`](../feature-library/04-analytics.md) (Reports feature). Entries = deltas + specifics.

Screens: Reports Dashboard · Report Detail · Export Screen

Flow map:
```
Bottom nav / Dashboard "Reports" ─► Reports Dashboard ─► Report Detail ─► [run / change params] ─► results
Report Detail ─► "Export" ─► Export Screen ─► (job) ─► notification ─► secure download link
Reports Dashboard ─► "Scheduled" tab ─► manage scheduled report deliveries
```

---

## 7.1 Reports Dashboard

**Archetype:** C (catalog) with a **B**-style summary strip · **Route:** `/reports?tab=all|favorites|scheduled&category=&q=`

1. **Purpose** — the catalog / hub of available reports: browse, search, favorite, open, and manage scheduled deliveries.
2. **User Goal** — "Find the report I need (or one I run often), open it, or check on a scheduled export."
3. **Layout** — C's skeleton + a light B header:
   - App bar "Reports" + search + overflow (Request a new report, Export history).
   - **Tabs:** All · Favorites · Scheduled.
   - Optional **summary strip** (B-style): "2 exports ready to download" (`info` Banner → Export history) · "1 scheduled report failed" (`danger` → fix).
   - **Category filter chips:** Operations · Finance · HR · Safety/K3 · Inventory · Compliance (product-configurable).
   - **Report row / card:** icon by category · **report name** (`titleMedium`) + one-line description · metadata (last run, owner, "Scheduled" badge) · trailing = favorite ★ toggle + chevron.
   - **Scheduled tab:** rows show cadence ("Every Monday 07:00"), recipients, next run, last status (`success`/`danger` chip), and a "Run now" / "Pause" action.
   - No FAB (report definitions are usually admin-created); "Request a new report" in overflow.
4. **Component Hierarchy** — C's + `AmdsSegmented(tabs)`, `AmdsBanner(exportsReady|scheduleFailed)?`, `ChipRow(categories)`, `ReportRow(icon, name, desc, meta, ★ AmdsIconButton, chevron)`, `ScheduledRow(cadence, recipients, nextRun, statusChip, AmdsIconButton menu)`.
5. **Information Architecture** — grouped by category; Favorites surfaces the user's frequent reports; Scheduled is operational (delivery status matters). Each row says enough to pick the right report (name + description + last run). Search matches name + description + category.
6. **User Flow** — C's. `open → (Favorites tab default if the user has any, else All) → search/filter → tap a report → Report Detail`. `★ toggle → moves to Favorites`. `Scheduled tab → row → schedule detail (edit cadence/recipients/params, pause, run now, view last run's output)`. Summary Banner → Export history / failed-schedule detail.
7. **States** — C's. Deltas:
   - **Loading:** `AmdsSkeletonList` of report rows; tabs shown.
   - **Empty:** All → "No reports available for your role yet" + "Request a report". Favorites → "Star a report to see it here." Scheduled → "No scheduled reports" + "Schedule one from a report".
   - **Success:** categorized rows; favorites starred; scheduled rows show status.
   - **Error:** "Couldn't load reports" + Retry.
   - **Offline:** cached catalog + favorites (report definitions rarely change); "Run" and "Export" disabled offline with "Connect to run reports"; scheduled status shown "as of HH:MM".
8. **Accessibility** — C's. Row announces "name, description, last run {date}, {scheduled}". ★ toggle = `role=switch`/toggle button, "Add {report} to favorites" / "Remove from favorites". Scheduled-row status conveyed by chip **text** ("Last run failed"). Tabs with position + count. Summary Banner `role=status` (or `alert` for the failure).
9. **Animations** — C's list stagger. ★ toggle: a quick scale `spring` + fill crossfade; the row animates into/out of the Favorites list on tab switch. Reduced-motion: instant fill.
10. **Dark Mode** — C's. Category icon circles = translucent containers; ★ filled `#FBBF24`, empty `#64748B`; scheduled status chips translucent + -100 text; "exports ready" Banner `infoContainer`.
11. **Tablet** — C's list-detail: **catalog left, Report Detail right** on landscape. Portrait: 2-column card grid for the catalog if descriptions are short, else single list max-640. Scheduled management is a comfortable table on tablet.
12. **Developer Notes** — **all:** `GET /reports?category=&q=&favorite=&scheduled=`; a report definition = `{ id, name, description, category, params[] (schema), permissions, supportsSchedule, supportsExportFormats[] }`. Favorites persist per user. Scheduled deliveries = `{ reportId, params, cadence (cron), recipients[], formats[], nextRunAt, lastRun{status, at, outputRef} }`; "Run now" enqueues a job. Summary strip pulls from the export-jobs + schedules services. **Compose:** Paging 3 + `LazyColumn`. **Flutter:** `PagedListView` + `RecordListConfig`. **RN:** `FlashList` + React Query.
13. **UX Best Practices** — Favorites-first for repeat users. Clear names + descriptions so users pick right. Scheduled delivery status is operational — surface failures. Search across name + description. Offline: browse yes, run no. "Request a report" as an escape hatch when the catalog lacks what they need.

---

## 7.2 Report Detail

**Archetype:** D (parameterized record) + **H** (rendered output) · **Route:** `/reports/:id?params=<encoded>`

1. **Purpose** — configure a report's parameters, run it, view the rendered result, and export or schedule it.
2. **User Goal** — "Set the parameters I need, see the result, and get it out (export / share / schedule)."
3. **Layout** — D's skeleton, split into **params** and **output**:
   - App bar: back · report name · overflow (Schedule, Export, Save as favorite, About this report).
   - **Parameters card (collapsible):** the report's `params` schema rendered by the **form engine** — date range, site/scope, grouping, thresholds, filters. A **"Run report"** primary button (or auto-run on open with defaults).
   - **Applied-parameters chip row** (once run): removable-ish chips summarizing the current params + "Edit parameters".
   - **Output region:**
     - **Summary tiles** (B-style `AmdsKpiCard` row) — the report's headline numbers.
     - **Primary visualization** (`AmdsChartCard`) if the report has one.
     - **Data table** (data-display) — the tabular result: responsive (row-transformation on phone, scrollable grid on tablet), sortable, with pagination for large sets.
     - **Narrative / notes** (H) — any generated commentary, methodology note, data-completeness disclaimer ("data through yesterday"), and the run timestamp.
   - **Sticky footer:** "Export" (primary) · "Schedule" (secondary).
4. **Component Hierarchy** — D's + `ParametersCard(FormEngine(report.params))`, `AmdsButton("Run report")`, `AppliedParamsChipRow`, `SummaryTileRow(AmdsKpiCard × n)`, `AmdsChartCard?`, `AmdsDataTable(data-display)`, `NarrativeBlock`, `StickyFooter(Export, Schedule)`.
5. **Information Architecture** — parameters up top (collapsible once run so the output dominates), output below. The **current parameters are always visible** as chips so the numbers are never ambiguous. Data completeness + run time always shown. The table is the source of truth; charts/tiles are summaries of it.
6. **User Flow** — `open → (defaults pre-filled — date range = last month, scope = my site) → "Run report" (or auto-run) → loading → output renders → review → { sort/paginate the table | tap a chart → "View as table" | "Edit parameters" → params card expands → change → "Run" again → output updates } → "Export" → Export Screen (§7.3) | "Schedule" → schedule sheet (cadence, recipients, formats) → saved`.
7. **States** —
   - **Loading:** parameters card real (disabled) + output area skeleton (tile row + chart block + table rows). Long-running report (>~5s) → a determinate/indeterminate progress with "Generating report…" and a Cancel.
   - **Empty:** valid params but **no matching data** → "No data for these parameters" (distinct from zeros) + "Edit parameters" + keep the params visible; a report that legitimately returns zeros shows "0" in tiles with a note.
   - **Success:** full output + applied-params chips + run timestamp + completeness note.
   - **Error:** parameter validation → inline in the params form (focus first error). Generation failure → "Couldn't generate this report" + Retry + trace id, params preserved. Timeout → "This report is taking too long — we'll email it to you when it's ready" → converts to an async job.
   - **Offline:** if a cached run exists for these exact params → show it "as of HH:MM"; otherwise "Connect to run this report". Export/Schedule disabled offline.
8. **Accessibility** — D's + H's. Parameters form = full form a11y (labels, required, errors, first-error focus). Applied-params chips summarized as text ("Parameters: last month, site East, grouped by department"). Summary tiles announce value + label. **Table has full data-table semantics** (data-display §12) — this is the primary a11y path; charts offer "View as table". Narrative headings marked. Run timestamp + completeness note announced. Long-run progress announces start + completion politely. Export/Schedule buttons labelled with the report name.
9. **Animations** — params card collapse/expand (250ms height + fade, chevron rotate). "Run" → output area skeleton → content crossfade (150ms, zero layout shift). Chart draw-in on first render only (300ms `decelerate`). Table re-sort: rows crossfade. Reduced-motion: instant, no draw-in.
10. **Dark Mode** — D's. Params card `surfaceVariant`; applied-params chips translucent; summary tiles + chart use B's dark chart palette; table uses data-display dark tokens (header `surfaceVariant`, zebra optional at 50%, selected row tint); narrative callouts translucent + -100 text.
11. **Tablet** — Landscape: **two-pane** — parameters + summary tiles left (or a top strip), the table + chart right (more columns visible, comfortable density); or params as a collapsible left rail. Portrait: stacked, table in row-transformation mode with a "Table view" toggle for the grid.
12. **Developer Notes** — **all:** `POST /reports/:id/run { params }` → returns `{ runId, summary, series?, table (paged), narrative, generatedAt, dataThrough, completeness }` — **run server-side**, never assemble on the client. Cache the run keyed by `reportId + params hash` for instant back-nav and offline. Long reports → the endpoint returns `202 { jobId }` → poll / push → notification → the result opens here or in Export history. Params schema drives the form engine (reuse `FormSchema`). Table: server-side sort/paginate (keyset); the phone row-transformation picks config-declared key columns. `?params=` in the deep link is a compact encoded blob (no PII in the URL). "Schedule" writes a scheduled-delivery record (§7.1). **Compose:** collapsible `params` via `AnimatedVisibility`; table via a `LazyColumn`/Paging + horizontal scroll. **Flutter:** `AmdsDataTable` + `fl_chart`; `compute` for any client formatting. **RN:** `FlashList` grid + `victory-native`.
13. **UX Best Practices** — parameters always visible (as chips) so numbers are never ambiguous. Sensible defaults, auto-run where cheap. Show data completeness + run time. Table is the source of truth; charts summarize it; "View as table" everywhere. Long runs convert to async with a notification, not a spinner-of-death. Cache runs for back-nav + offline. Export/Schedule from here, respecting the current params.

---

## 7.3 Export Screen

**Archetype:** A — Focused Task (with a small **E** form) · **Presentation:** a full-screen sheet or a bottom sheet (`AmdsBottomSheet` on phone, dialog on tablet). Triggered from Report Detail, a Data List, Analytics, Approval History, or User List.

**Route:** `/export?source=<ref>` (or presented modally)

1. **Purpose** — let the user produce a downloadable/shareable file of the data they're looking at, in the format and scope they choose, respecting permissions and governance.
2. **User Goal** — "Get this data out as a file I can open elsewhere or send to someone, without surprises about what's included."
3. **Layout** — A's focused task:
   - Top bar: `X` / drag handle · "Export" · (no trailing action — the CTA is in the body/footer).
   - **What's being exported:** a summary line — "{Report/List name} · {row count} rows · filters: {summary}". If the count is large, note it ("12,480 rows — this may take a minute").
   - **Format** (`AmdsRadioGroup` or segmented): **CSV** · **Excel (XLSX)** · **PDF** (formatted report) · (context) **JSON**. Each with a one-line description.
   - **Scope** (`AmdsRadioGroup`): "Current view (with filters & sort)" (default) · "All columns" · "Selected rows only" (if a selection exists) · "All data (ignore filters)" (permission-gated).
   - **Options** (contextual): include header row (CSV), date format, timezone, delimiter, "Include summary/charts" (PDF), password-protect (PDF, per policy), "Anonymize PII" (governance).
   - **Delivery:** "Download now" (small exports) · "Email me a link" / "Notify me when ready" (large/async).
   - **Governance note:** "Some fields are excluded from exports per data policy" (when applicable), with a "What's excluded?" link.
   - **Primary button:** "Export" (full-width, `Large`).
4. **Component Hierarchy** — `AmdsBottomSheet`/`AmdsScaffold(focused)` → `Column[ SummaryLine, AmdsRadioGroup(format), AmdsRadioGroup(scope), OptionsSection (conditional), DeliveryChoice, GovernanceNote?, AmdsButton(primary "Export", loading) ]`.
5. **Information Architecture** — the user must understand **exactly what will be in the file** before they commit: which rows (scope), which columns, which format, and any exclusions. Format choice drives which options appear. Delivery method is chosen automatically by size but overridable.
6. **User Flow** —
   ```
   trigger → sheet opens (format = CSV or last-used, scope = current view)
     → pick format → relevant options appear
     → pick scope → summary line updates the row/column count
     → tap "Export"
         ├─ small (sync) → "Preparing…" → file ready → hand off:
         │      • phone: system share sheet (Save to Files / send) — NOTE: an in-app "download" link does not work in a webview/sandbox; use the OS share/save
         │      • the sheet shows "Exported · Open / Share" then dismisses
         ├─ large (async) → "We're preparing your export. We'll notify you when it's ready." → sheet dismisses
         │      → push notification "Your export is ready" → tap → secure, expiring download link (Export history)
         └─ error → keep the sheet, inline error + Retry
   ```
7. **States** —
   - **Loading:** "Export" button → "Preparing…" spinner (sync); async → immediate confirmation + dismiss.
   - **Empty:** nothing to export (0 rows in scope) → "There's no data to export for the current filters" + the button disabled with that reason.
   - **Success:** sync → share/save hand-off + "Exported"; async → "We'll notify you" confirmation.
   - **Error:** generation failed → "Couldn't create the export — try again" + trace id; too large even for async / quota exceeded → clear message + suggest narrowing filters.
   - **Offline:** the whole screen is disabled with "You must be online to export"; the trigger can be hidden offline instead.
8. **Accessibility** — A's. Format/scope groups have legends; each option's description is associated. The summary line updates are announced politely when scope/format changes the count. The governance note + "What's excluded?" is reachable. "Export" button announces the resulting action ("Export 240 rows as CSV"). Async confirmation announced and focus moves to it. **Downloading is a deliberate user action** — the button is the only way it happens (no auto-export). Reduced-motion respected.
9. **Animations** — sheet slide-up 250ms `standard`. Options sections expand/collapse on format change (200ms height + fade). Button → "Preparing…" spinner. Success → brief check then dismiss (200ms). Reduced-motion: instant.
10. **Dark Mode** — A's sheet: surface `#1E293B` (raised) + strong shadow + drag handle `#475569`; radio groups + options dark; governance note in `warningContainer`; primary button green-400 fill.
11. **Tablet** — presented as a **centered dialog (≤560)** rather than a bottom sheet; options laid out in two columns where they fit; otherwise identical.
12. **Developer Notes** — **all:** `POST /exports { source, format, scope, options }` → `200 { fileRef }` (small) or `202 { jobId }` (large; threshold e.g. > 5k rows or > a few MB). **Delivery:** sync → download the bytes then hand to `share_plus` / `Intent.ACTION_SEND` / `Share.share` **or** save via SAF / `UIActivityViewController` — **never** an `<a download>` in a webview (inert in the sandbox). Async → job runs server-side, result stored with a **short-lived, permission-checked, signed URL**; push notification carries the `jobId`; an "Export history" list (overflow on Reports Dashboard) shows past exports with re-download (while the link is valid). **Governance:** the server enforces field exclusions + PII rules regardless of the client's options; the client just reflects them. CSV = UTF-8 **with BOM** (Excel), configurable delimiter, RFC-4180 quoting. PDF = a real formatted report (title, applied filters, timestamp, page numbers), not a screenshot. No sensitive data in URLs or analytics. **Compose:** `FileProvider` + share intent. **Flutter:** write to a temp dir + `Share.shareXFiles` / `SAF`. **RN:** `react-native-share` / `expo-sharing` / `CameraRoll`/`FileSystem`.
13. **UX Best Practices** — show exactly what the file will contain before committing (rows, columns, format, exclusions). Default to "current view with filters". Auto-pick sync vs async by size, tell the user which. Async → notification + secure expiring link, never a frozen UI. Hand off via the OS share/save, not a download link. Confirm it's a download/share action. Respect governance server-side. Localize number/date/encoding.
