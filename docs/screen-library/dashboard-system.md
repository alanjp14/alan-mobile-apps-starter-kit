# Screen Library · Dashboard System

> Design patterns for the four dashboard archetypes — Executive · Operational · Monitoring · Analytics — built from a shared block kit. Referenced by [`02-dashboard.md`](02-dashboard.md).

---

## 1. Shared dashboard anatomy

```
[ App Bar: greeting/title · global filter · notifications ]
[ Global filter bar (sticky): period · scope (site/team/region) ]      ← optional
──────────────────────────────────────────────────────────────
[ ALERTS strip ]         only when something needs attention
[ KPI GRID ]             2-up phone · 4-up tablet
[ PRIMARY VISUAL ]       one hero chart or status board
[ SECONDARY CONTENT ]    breakdowns, secondary charts
[ RECENT ACTIVITY ]      ≤5 items + "View all"
[ QUICK ACTIONS ]        3–6 tiles / FAB sheet
──────────────────────────────────────────────────────────────
[ Bottom Nav ]
```

**Block kit**

| Block | Component ([component library](../component-library/README.md)) | Notes |
|---|---|---|
| KPI | KPI Card (C2) | tappable → filtered list; declares its "good direction" |
| Chart | Chart Card (C3) | one question per card; "View as table" always |
| Activity | List item (F) | icon + who + what + when; tap → source |
| Quick action | Card / tile (icon 24 + `label`) | 3–6, the most frequent creates/jumps |
| Alert | Banner (D6) / Alert KPI | severity-tinted, always has a resolution action |
| Filter | Chip / Segmented (F) | applies to every block; visible + removable |
| Empty | Empty state (F) | per block, first-run friendly |

**Loading order** — skeleton (dashboard variant) → alerts → KPIs → primary visual → the rest. Never block the whole screen. Show "Updated HH:MM" + pull-to-refresh.

**Personalization** — greeting by name + time of day; metrics scoped to the user's role, sites, and permissions; allow reordering/hiding blocks per user where the app supports it (store server-side).

---

## 2. Executive Dashboard

**Audience** — leadership. Question: *"How are we doing overall, and what's trending?"*

**Characteristics** — highly summarized, comparison-heavy, low interactivity, calm. Weekly/monthly cadence. Big numbers, clear deltas, minimal detail.

**Layout**

1. Global filter: period (This month / QTD / YTD) + region/division.
2. **KPI grid (4–6)** — headline outcomes: Revenue, Cost, Headcount, Safety incidents (TRIFR), NPS/CSAT, Utilization. Each: big value, delta vs prior period, tiny sparkline, target indicator.
3. **Primary visual** — one trend line (the North-Star metric over 12 periods) with a target band.
4. **Breakdown** — a compact bar list: top/bottom performers by division or region.
5. **Highlights** — 2–4 auto-generated or curated callouts ("Safety incidents down 30% QoQ", "Region East missed target").
6. Recent activity: only board-level events (approvals over threshold, milestones).
7. Quick actions: "View full report", "Share snapshot", "Drill into…".

**UX guidelines** — no more than one screen of scroll. Every number has a period and a comparison. Use sentiment tint, not raw green/red. Export/share a clean snapshot (PDF/image) respecting filters. Avoid operational noise — link to the Operational dashboard for depth. Numbers rounded (1.2M, 4.3%) with exact on tap.

---

## 3. Operational Dashboard

**Audience** — managers, supervisors, coordinators. Question: *"What needs action today, and how is my team/area doing right now?"*

**Characteristics** — task-oriented, medium interactivity, daily/shift cadence, mixes status with to-dos.

**Layout**

1. Filter: shift / today / this week + team or site.
2. **Alerts strip** — overdue approvals, SLA breaches, blocked tasks, understaffing.
3. **KPI grid (4)** — throughput today, open items, overdue count, completion rate / on-time %.
4. **"Needs you" section** — actionable lists: *Pending your approval (3)* · *Overdue tasks (5)* · *Unassigned (2)* — each row actionable inline (Approve / Assign) with detail on tap.
5. **Team/area status** — list of people or sub-areas with a load/status indicator (capacity bar, open count, on-track chip).
6. **Trend** — one operational chart: tickets opened vs closed (7 days), or production vs plan.
7. Recent activity: team events, status changes, comments.
8. Quick actions / FAB: create task, log entry, assign, start inspection.

**UX guidelines** — the actionable lists are the point — put them high, keep them short (top N + "View all"). Inline actions must be safe and reversible (Undo); risky ones open detail. Counts are live; reflect changes immediately after an action. Distinguish "mine" vs "team". Make it usable one-handed on the floor (large targets, high contrast, works with gloves/outdoors → see K3 note below).

**K3 / field note** — for mining/safety/field ops: maximize contrast and target size, support offline (queue actions, sync later with clear pending state), prominent "Report hazard / incident" as the FAB, minimize typing (pickers, scan, voice-to-text), and never hide a safety-critical action behind an overflow menu.

---

## 4. Monitoring Dashboard

**Audience** — NOC / operations center / on-call. Question: *"Is everything healthy right now? What's broken and how bad?"*

**Characteristics** — real-time, high signal density, status-first, glanceable from across a room, auto-refreshing, alert-driven.

**Layout**

1. **Global health bar** — one line: overall status (Operational / Degraded / Outage) + counts (🔴 3 · 🟠 7 · 🟢 142) + "last updated Xs ago" with a live pulse.
2. **Active incidents** — list sorted by severity then age: severity chip · title · affected component/site · duration · assignee · ack/resolve quick actions.
3. **Status grid / heatmap** — services or devices as tiles colored by state (`success`/`warning`/`danger`/`textTertiary` unknown); tap → detail with recent metrics.
4. **Key metrics** — 2–4 live charts: latency, error rate, throughput, availability — short windows (1h/6h/24h), auto-scrolling.
5. **Alert feed** — reverse-chronological alert stream with filters (severity, service, acknowledged).
6. Quick actions: acknowledge all, create incident, open runbook, page on-call.

**UX guidelines**

- **Severity encoding:** color + icon + text + position (most severe pinned top). Colorblind-safe: use shape/label, not hue alone. Red = active user-impacting; amber = degraded/at-risk; green = healthy; grey = unknown/no data (never show grey as "fine").
- **Auto-refresh** every 15–60s with a subtle indicator; never yank scroll position or re-animate everything — diff and update in place, flash only what changed.
- **New critical alert:** distinct entry animation + optional sound/haptic (respect settings) + it sorts to the top; it does **not** steal focus or open a modal.
- **Acknowledge vs Resolve** are separate; ack stops paging, resolve closes. Show who ack'd and when.
- **Stale data is an alarm state** — if the feed hasn't updated past its interval, show "Data stale — Xs" in warning, don't pretend it's current.
- **Time zones:** show a consistent zone (UTC or the NOC's) with local on tap.
- Designed to be left open for hours — pause non-essential animation when backgrounded, dim on idle, keep-awake option.

---

## 5. Analytics Dashboard

**Audience** — analysts, product/ops specialists. Question: *"Why is this happening? Let me slice it."*

**Characteristics** — exploratory, high interactivity, filter/dimension-driven, comparison and segmentation, export.

**Layout**

1. **Control bar (sticky)** — date range (segmented + custom), primary dimension picker, compare toggle (vs previous / vs last year), saved views.
2. **Headline** — the chosen metric big, with delta and sparkline.
3. **Primary chart** — full-width, ~240 tall; type follows the question (trend/comparison/composition); tap-hold tooltip shows all series; legend toggles series.
4. **Segment breakdown** — table/list: dimension value · metric · % of total · delta · mini bar; tap a row → filters the whole dashboard to that segment (breadcrumb shows the drill path).
5. **Secondary charts** — 1-up phone / 2-up tablet: related cuts (by channel, by region, by category).
6. **Cohort/retention or funnel** block where relevant.
7. Actions: Export (CSV/PDF, respects filters), Save view, Share, "View as table" on every chart.

**UX guidelines**

- Filters are global, visible as removable chips, and reflected in the URL/deep link.
- Always provide a numeric table alternative (accessibility + trust).
- Comparisons need an explicit baseline label.
- Keep axes honest: bar charts start at 0; note any truncated/log axis.
- Aggregate server-side for large datasets; paginate breakdown tables ([data display](../component-library/data-display.md)); show sampling/estimation disclaimers.
- Empty/partial data: label "No data" vs "0" distinctly; show data completeness ("data through yesterday").
- Localize number, currency, percent, and date formats.

---

## 6. Chart guidance (applies to all dashboards)

| Question | Chart | Rules |
|---|---|---|
| Trend over time | Line / area | ≤4 series; time on x; markers on sparse data; area only for one series or stacked totals |
| Compare categories | Horizontal bar | sorted by value; start at 0; label values directly on mobile |
| Part-to-whole | Stacked bar (≤5 parts) or donut (≤4 slices) | donut needs a center total + direct labels; avoid pie for close values |
| Distribution | Histogram / box | |
| Correlation | Scatter | rare on mobile; provide table |
| Status counts | Segmented bar / tiles | color + label |
| Progress to goal | Bullet / progress bar | show target, current, and % |

**Palette** — derive a 6-color categorical set from tokens, ordered for max separation:
`primary green-600 · sky-600 · amber-600 · red-600 · slate-500 · green-800`.
Sequential (heatmap): green-100 → green-900. Diverging: red-600 ↔ slate-200 ↔ green-600.
Ensure adjacent series differ in **lightness**, not just hue (colorblind safety), and pair with direct labels or patterns.

**Interaction** — tap-and-hold crosshair tooltip (all series at x); legend chips toggle series; pinch-zoom on dense time series (with a "reset zoom"); no hover-only information.

**Accessibility** — chart container labeled with a one-sentence summary of the takeaway; "View as table" toggle mandatory; no meaning by color alone; reduced-motion disables draw-in; announce updated values politely on refresh (throttled).

**Performance** — cap points rendered (downsample/LTTB); virtualize long breakdown lists; debounce filter changes (250ms); cache last result for instant back-navigation; render charts off the main thread where the platform allows.
