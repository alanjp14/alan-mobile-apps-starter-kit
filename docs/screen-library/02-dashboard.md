# Screen Library · 02 · Dashboard

> Foundation: AMDS v1.0 · Archetype: **B — Dashboard** (framework §4.B) · Deep reference: [`../specs/dashboard.md`](../specs/dashboard.md) (full operational-dashboard spec with per-block state matrix, 24 edge cases, A1–A22 animations, `DashboardUiState` shape).
> The 4 dashboards share archetype B; they differ in **audience, block mix, cadence, and interactivity**. Entries below are deltas.

| | Executive | Operational | Monitoring | Analytics |
|---|---|---|---|---|
| Audience | Leadership | Managers / supervisors | NOC / on-call | Analysts |
| Question | "How are we doing vs target?" | "What needs me today?" | "Is anything broken, how bad?" | "Why — let me slice it" |
| Cadence | Weekly / monthly | Daily / per shift | Real-time (15–60s) | On-demand exploration |
| Interactivity | Low | Medium (inline actions) | Low (ack/resolve) | High (filters, drill) |
| Primary block | 1 North-Star trend + target | "Needs you" action lists | Health bar + active incidents | Control bar + primary chart + segment table |
| Refresh | Pull / open | Pull / open / tab-double | **Auto** + pull | Debounced on filter change |

---

## 2.1 Executive Dashboard

**Archetype:** B · **Route:** `/dashboard/executive` (or `/dashboard` for exec-role users)

1. **Purpose** — a one-screen, comparison-heavy summary of headline outcomes and the North-Star trend for leadership.
2. **User Goal** — "Glance, understand where we stand vs target, leave informed without scrolling past one screen."
3. **Layout** — B's skeleton. Blocks: global filter (This month / QTD / YTD + region/division) → **KPI grid 4–6** (Revenue, Cost, Headcount, TRIFR/safety, NPS/CSAT, Utilization — each: big value, delta vs prior period, tiny sparkline, target indicator) → **one North-Star trend** line (12 periods) with a target band → **breakdown bar list** (top/bottom performers by division/region) → **2–4 highlights** (auto/curated callouts) → minimal recent activity (board-level events only) → quick actions ("View full report", "Share snapshot", "Drill in").
4. **Component Hierarchy** — B's + `AmdsKpiCard(variant: detailed, showTarget)` × 6, `AmdsChartCard(line + targetBand)`, `BreakdownBarList`, `HighlightCard × n`. **No FAB.**
5. **Information Architecture** — no more than one scroll. Every number has a **period + comparison + target**. Sentiment tint, not raw green/red. Rounded values (1.2M, 4.3%) with exact on tap. Links to the Operational/Analytics dashboards for depth.
6. **User Flow** — `open → KPIs → tap a KPI → Analytics (that metric) → back`. `Share snapshot → generates a clean PDF/image respecting filters → share sheet (confirm)`. Change period → all blocks re-query.
7. **States** — B's. Deltas: **Empty** — "Reporting starts once data is available for {period}"; **Stale** — exec data is often day-old by design → show "As of {date}" prominently, not as a warning, unless truly overdue.
8. **Accessibility** — B's. Each KPI announces value + delta + **target status** ("Revenue, 1.2 million, up 4% versus last month, 3% below target"). Highlights are a labelled list. Share action confirms and describes the output.
9. **Animations** — B's, but **calmer**: count-up only on first open, no sparkline draw on refresh, no stagger beyond the KPI row. Target band fades in with the chart.
10. **Dark Mode** — B's. Target band = `primary` @ 12% opacity; sparklines lightened; highlight cards use translucent semantic containers.
11. **Tablet** — B's. Landscape: KPI 6-up in one row; the North-Star chart large-left, breakdown + highlights right. Optimized for a wall/boardroom display (larger type option, dim-on-idle).
12. **Developer Notes** — **all:** exec metrics come from a pre-aggregated warehouse endpoint (`/dashboard/executive?period=&scope=`), not live transactional queries; cache aggressively (per period). Snapshot export = server-rendered PDF (title, filters, timestamp, page numbers) delivered via share/secure link, **not** a screenshot. `share_plus` / `ACTION_SEND` / `Share`. Number formatting: abbreviate ≥10k, locale-aware, currency codes.
13. **UX Best Practices** — one screen. Comparison + target on every metric. Tint by sentiment. Round with exact-on-tap. Don't put operational noise here — link out. Make "Share" produce something board-ready.

---

## 2.2 Operational Dashboard

**Archetype:** B · **Route:** `/dashboard` (default for manager/supervisor roles) · **Full spec:** [`../specs/dashboard.md`](../specs/dashboard.md)

1. **Purpose** — the home base: today's status, the user's priorities (approvals, overdue, unassigned), and fast paths to frequent actions.
2. **User Goal** — "In ~5s tell me what needs me, then let me act on it or dive into detail."
3. **Layout** — B's skeleton, fully realized: filter (shift/today/week + team/site) → **alert strip** → **KPI grid 4** (throughput today, open items, overdue, on-time %) → **"Needs you"** action lists (Pending my approval · Overdue tasks · Unassigned — inline Approve/Assign) → **one operational chart** (opened vs closed, 7 days) → **recent activity** (team events) → **quick actions / FAB** (New incident / work order / log entry / start inspection).
4. **Component Hierarchy** — see [`../specs/dashboard.md`](../specs/dashboard.md) §4 (23-row component map).
5–13. **All dimensions** — see [`../specs/dashboard.md`](../specs/dashboard.md) §1–§10 (User Goal, UX Flow, Wireframes for phone + tablet-portrait + tablet-landscape, Component Mapping, States incl. per-block matrix, 24 Edge Cases, Accessibility with verified contrast tables, A1–A22 Animations, Developer Notes for Compose/Flutter/RN, Layout reference tokens).

**K3 / field note** (applies when this is a mining-safety / field-ops app): maximize contrast + target size (glove/outdoor use), offline-first (queue actions, clear pending state), **"Report hazard / incident" is the FAB** and never behind an overflow, minimize typing (pickers, scan, voice-to-text), keep-awake option, high-visibility alert styling.

---

## 2.3 Monitoring Dashboard

**Archetype:** B · **Route:** `/dashboard/monitoring`

1. **Purpose** — real-time health of services / devices / sites for a NOC or ops centre: is everything OK, what's broken, how severe.
2. **User Goal** — "Glance from across the room: is anything red? What's the active incident and who owns it?"
3. **Layout** — B's skeleton, status-first:
   - **Global health bar** (one line): overall status (Operational / Degraded / Outage) + counts (🔴 3 · 🟠 7 · 🟢 142) + "updated 12s ago" with a live pulse.
   - **Active incidents** list: severity chip · title · affected component/site · duration · assignee · ack/resolve quick actions. Sorted severity → age; most severe pinned top.
   - **Status grid / heatmap**: services/devices as tiles colored by state; tap → detail with recent metrics.
   - **Key metrics**: 2–4 live mini-charts (latency, error rate, throughput, availability), short windows (1h/6h/24h), auto-scrolling.
   - **Alert feed**: reverse-chronological stream with filters (severity / service / acknowledged).
   - Quick actions: Acknowledge all · Create incident · Open runbook · Page on-call.
4. **Component Hierarchy** — B's + `HealthBar`, `IncidentListItem(severityChip, duration, AmdsIconButton ack/resolve)`, `StatusTileGrid`, `LiveMiniChart × n`, `AlertFeedList(filterChips)`. FAB → "Create incident" (or none; use the quick action).
5. **Information Architecture** — **severity encoding = color + icon + text + position** (colorblind-safe). Red = active user-impacting; amber = degraded/at-risk; green = healthy; **grey = unknown/no data** (never "fine"). Acknowledge ≠ Resolve (separate). Stale data is an **alarm state**.
6. **User Flow** — `open → scan health bar → tap an active incident → Incident Detail (metrics, timeline, runbook) → Acknowledge (stops paging) → later Resolve (closes)`. `tap a status tile → device/service detail`. `new critical alert → sorts to top with a distinct entry + optional sound/haptic (respect settings) → does NOT steal focus or open a modal`.
7. **States** —
   - **Loading:** health bar skeleton + 3 incident-row skeletons + tile grid shimmer; charts last.
   - **Empty:** "All systems operational" (green), no active incidents → a calm confirming state (not a blank).
   - **Success:** live data; auto-refresh every 15–60s updating **in place** (diff, flash only what changed); "updated Xs ago" ticks.
   - **Error:** a data source fails → that tile/chart shows `error`/unknown (grey) + "no data" — **not** hidden, not green. Whole-feed failure → "Monitoring data unavailable" banner + last-known state dimmed + Retry.
   - **Offline / stale:** if the feed hasn't updated past its interval → "Data stale — 90s" in `warning` at the health bar; don't render stale as current. Offline → "Reconnecting…" with the last snapshot dimmed.
8. **Accessibility** — health bar announces the summary + counts on change (**polite, throttled to ≥ every few seconds**, not per tick). Severity in text always. Active-incident rows = grouped stops with severity, duration, assignee. Ack/Resolve buttons labelled with the incident id. New-critical-alert announcement is polite and does not move focus. Auto-refresh must not disrupt a screen-reader user mid-read (announce deltas, not full re-reads). Sound alerts have a visible + haptic equivalent and a mute control. Reduced-motion: no live pulse animation → a static "live" dot + timestamp; no flash on change → a brief outline instead.
9. **Animations** — new incident row: expand + fade + slideY -8→0, 250ms; sorts to top. Changed value on refresh: 150ms crossfade + 400ms `primary`/`danger` outline fade. Health-bar count change: digit up-fade. Live pulse: 1.5s opacity loop (reduced-motion: off). Mini-charts scroll continuously (`accessibleNavigation` / reduced-motion → static latest window). **No modal, no focus steal, ever.**
10. **Dark Mode** — the default/expected mode for a NOC. Background `#020617`; severity: `#F87171` / `#FBBF24` / `#4ADE80` / `#64748B` (unknown); status tiles use these as fills with `slate-950` labels; gridlines `#1E293B`. High-contrast option for glare.
11. **Tablet** — this dashboard is **tablet/landscape-first** in practice. Landscape: persistent drawer + a 12-col grid — health bar full-width, active incidents + alert feed left (8 col), status grid + mini-charts right (4 col); tap an incident → right-side detail pane. Designed to be left open for hours: pause off-screen animation, dim on idle, keep-awake toggle.
12. **Developer Notes** — **all:** prefer a **WebSocket / SSE** stream for updates; fall back to polling (15–60s). Apply updates as **diffs** to a keyed list — never replace the whole list (preserves scroll + selection + avoids re-animation storms). Debounce UI updates (batch to ~1/sec). `connectivity_plus` + a heartbeat to detect a dead stream → "stale" state. Sound: a short asset played via `just_audio`/`SoundPool`/`expo-av`, gated by a setting + system Do-Not-Disturb awareness. Time zone: one consistent zone (UTC or the NOC's) with local on tap. **Compose:** `LazyColumn` with stable keys + `animateItemPlacement()`. **Flutter:** `AnimatedList`/`SliverAnimatedList` with keyed diffs. **RN:** `FlashList` + `LayoutAnimation` on data change.
13. **UX Best Practices** — severity by shape + label + position, not hue alone. Ack and Resolve are distinct. Grey ≠ green — unknown is not healthy. Stale data is an alarm. Never let auto-refresh yank scroll or steal focus. New criticals get attention without a modal. Keep it readable across a room.

---

## 2.4 Analytics Dashboard

**Archetype:** B (exploratory) · **Route:** `/dashboard/analytics` or `/analytics/:metric`

1. **Purpose** — deeper exploration: trends, segmentation, comparison, and export for an area or metric.
2. **User Goal** — "Understand *why* a number moved — slice it by dimension, compare periods, export."
3. **Layout** — B's skeleton, control-driven:
   - **Control bar (sticky)**: date range (segmented 7d/30d/90d + Custom), primary dimension picker, compare toggle (vs previous / vs last year), saved views.
   - **Headline**: the chosen metric big + delta + sparkline.
   - **Primary chart**: full-width ~240 tall; type follows the question; tap-hold tooltip shows all series; legend toggles.
   - **Segment breakdown**: table/list — dimension value · metric · % of total · delta · mini bar; **tap a row → filters the whole dashboard to that segment** (breadcrumb shows the drill path).
   - **Secondary charts**: 1-up phone / 2-up tablet (by channel, region, category).
   - **Cohort / funnel** block where relevant.
   - Actions: Export (CSV/PDF, respects filters) · Save view · Share · **"View as table" on every chart**.
4. **Component Hierarchy** — B's + `ControlBar(AmdsSegmented, AmdsDropdown dimension, AmdsSwitch compare, SavedViewsMenu)`, `HeadlineMetric`, `AmdsChartCard(primary)`, `SegmentBreakdownTable` (data-display compact), `AmdsChartCard(secondary) × n`, `DrillBreadcrumb`. No FAB.
5. **Information Architecture** — one primary question per screen. Default range = last 30 days. Filters are **global**, visible as removable chips, reflected in the deep link. Comparisons need an explicit baseline label. Axes honest (bars start at 0; note any truncation). Data completeness shown ("data through yesterday").
6. **User Flow** — `open → headline + primary chart → change range/dimension → everything re-queries (debounced 250ms) → tap a breakdown row → drill (dashboard filters to that segment, breadcrumb appears) → tap breadcrumb to go back up → Export → sheet (format, scope, row count, "this is a download") → confirm → (large) async "we'll notify you" → notification with a secure expiring link`.
7. **States** —
   - **Loading:** control bar real (disabled) + headline skeleton + chart-area shimmer + breakdown row skeletons; each block resolves independently with a 150ms crossfade.
   - **Empty:** "No data for this range / segment" (distinct from "0"); keep controls so the user can widen the range or clear the drill.
   - **Success:** full content; drill breadcrumb when filtered; "View as table" available everywhere.
   - **Error:** per-block "Couldn't load" + Retry; "View as table" still offered for a failed chart if the data call succeeded.
   - **Offline:** last result shown (cached per filter combo) + "Offline — showing cached data from HH:MM"; filter changes disabled; export disabled.
8. **Accessibility** — **the numeric table alternative is the primary a11y path** — "View as table" on every chart yields a real `table` with headers. Chart container labelled with the takeaway. Comparison baseline stated in text. Drill action announces "Filtered to {segment}"; breadcrumb is a `nav`. Control changes announce the new state. No hover-only info; tap-hold tooltip content also reachable via the table. Reduced-motion: no chart draw-in, no re-animation on filter change.
9. **Animations** — control change → block skeleton → new content crossfade 150ms; primary chart line draws in 300ms `decelerate` (first render / range change only). Legend toggle: series fade + y-axis rescale 200ms. Drill: breakdown row → the whole screen crossfades to the filtered view; breadcrumb slides in. Reduced-motion: instant.
10. **Dark Mode** — B's chart palette (lightened series); breakdown mini-bars `#4ADE80`; drill breadcrumb `#4ADE80` links; table alternative uses dark table tokens (data-display).
11. **Tablet** — B's. Landscape: control bar full-width; primary chart large-left, breakdown table right (taller, more columns); secondary charts 2-up below; drilling updates both panes. This screen benefits most from landscape.
12. **Developer Notes** — **all:** aggregate **server-side** (`/analytics?metric=&range=&dimension=&segment=&compare=`); never pull raw rows to the client. Debounce control changes 250ms; cancel superseded requests; cache last result per filter combo for instant back-nav. Charts: downsample (LTTB) to ≤120 points; build series off the main thread (`compute` / coroutine / worker). Export: async job → push notification → secure, expiring, permission-checked link; PDF is a formatted report; CSV is UTF-8 with BOM; **no sensitive data in URLs**. Saved views persist server-side per user. **Compose:** Vico + `remember` derived data. **Flutter:** `fl_chart` in `AmdsChartCard` + `compute`. **RN:** `victory-native` + `useMemo` + React Query.
13. **UX Best Practices** — one question per screen. Default a sensible range. Global, visible, removable filters in the URL. "View as table" everywhere (trust + a11y). Explicit comparison baselines. Honest axes. Distinguish "0" from "no data". Localize formats. Export respects filters and confirms it's a download.
