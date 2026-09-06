# Template · Operational Dashboard — `[APP_NAME]`

> Archetype **B — Dashboard** ([framework](../../docs/screen-library/00-framework.md) §4.B). Full reference: [`../../docs/screen-library/02-dashboard.md`](../../docs/screen-library/02-dashboard.md) §2.2 · worked example: [`../../docs/specs/dashboard.md`](../../docs/specs/dashboard.md).
> Replace placeholders. Keep the structure. Implement **all states** (Loading · Empty · Success · Error · Offline · No-permission), dark mode, tablet, a11y per the archetype.

---

## Objective
Give a `[ROLE_NAME]` an at-a-glance view of what needs them today across `[MODULE_NAME]`, and fast paths to act.

## Route
`[APP_NAME]://[app]/dashboard` · deep-linkable with `?period=&scope=`

## Layout (phone, 375)

```
┌──────────────────────────────────────────────┐
│ App bar (large → 56): "Good [time], [USER_NAME]"  🔔·N   [avatar] │
├──────────────────────────────────────────────┤
│ Filter bar (sticky 48): [ Period ▾ ] [ [scope] ▾ ]   Updated Nm │
├──────────────────────────────────────────────┤
│ ⚠ Alert strip (Banner) — only when alerts > 0                    │
│ KPI GRID (2-up phone / 4-up tablet)                              │
│   [ [metric 1] ] [ [metric 2] ]                                  │
│   [ [metric 3] ] [ [metric 4] ]                                  │
│ ── Needs you ──────────────  (overline)                          │
│   [ row: [DATA_NAME] · key value · age · [Action] ]  (≤5)        │
│                                     [ View all → ]               │
│ ── Trend ──────────────────                                      │
│   [ ChartCard: [metric] over time, range 7d·30d·90d ]            │
│ ── Recent activity ────────                                      │
│   [ row: actor · action · time ]  (≤5)   [ View all → ]          │
│ ── Quick actions ──────────                                      │
│   [ New ] [ Scan ] [ [action 3] ] [ [action 4] ]                 │
├──────────────────────────────────────────────┤
│ FAB: [primary create]                                            │
│ Bottom nav: [Home] [[section]] [Approvals·N] [More]              │
└──────────────────────────────────────────────┘
```

## Component hierarchy
`AmdsScaffold(bottomNav)` → `SliverAppBar(large)` + pinned `FilterBar(AmdsChip×2, freshness)` → `CustomScrollView`:
`AmdsBanner(alerts)?` · `SliverGrid(AmdsKpiCard × 4)` · `AmdsSectionHeader("Needs you") + AmdsCard > List(AmdsListTileX + inline AmdsButton.sm)` · `AmdsSectionHeader("Trend") + AmdsChartCard` · `AmdsSectionHeader("Recent activity") + AmdsCard > List` · `AmdsSectionHeader("Quick actions") + tile grid` · `AmdsFab`.

## KPIs to define
| # | Label | Source | Good direction | Threshold (→ Alert variant) |
|---|---|---|---|---|
| 1 | `[metric]` | `[endpoint]` | up / down | `[value]` |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |

Every KPI is tappable → a pre-filtered `[DATA_NAME]` list.

## Primary CTA
FAB → create `[DATA_NAME]` (or the most frequent `[ROLE_NAME]` action).

## Secondary CTAs
Filter · pull-to-refresh · "View all" per section · quick-action tiles.

## States (see archetype B §7 for detail)
- **Loading:** dashboard skeleton (KPI blocks + list rows + chart block).
- **Empty (first run):** friendly per-section empties, prominent quick actions / Extended FAB. Not zeros everywhere.
- **Success:** full content + "Updated Nm ago"; inline actions animate the row out + Undo snackbar.
- **Error:** per-block error + block-scoped Retry; total failure + no cache → full-screen error + "Try again".
- **Offline:** banner "showing data from HH:MM"; pull-to-refresh disabled; inline actions queue.
- **No-permission:** if the `[ROLE_NAME]` sees no blocks → "Your role doesn't have dashboard metrics — contact your admin."

## Data (feature: [Dashboard Analytics](../../docs/feature-library/04-analytics.md))
`GET /v1/dashboard?variant=operational&period=[period]&scope[[scope]]=[value]` → partial-tolerant `{ blocks{} }`.

## Accessibility
Greeting/name = `heading 1`; section labels = `heading 2`. Each KPI announces "`[label]`, `[value]`, `[delta]` versus `[period]`". "Needs you" rows are grouped stops; inline buttons labelled with the item id. Chart has a mandatory "View as table". Freshness/count changes announced politely, throttled.

## Animations
Blocks fade+riseY staggered 30ms on first paint (≤8). KPI count-up 300ms + sparkline draw 400ms (first load only). Inline action: label→spinner→row collapse 200ms `accelerate`. **No re-animation on silent background refresh.** Reduced-motion: no count-up/draw/stagger.

## Tablet
Portrait: KPI 4-up; "Needs you" + "Recent activity" side by side; nav rail. Landscape: persistent drawer; 12-col 8/4 split — content left, priorities + activity in a right rail; tapping a priority opens a right-side detail pane; no FAB.

## Developer notes
One controller → `DashboardUiState` with `BlockState<T>` per block, loaded independently. Cache the last successful state per `(variant, period, scope)` (encrypted); fresh 5min → stale styling → hard-expire 24h. Debounce refresh; cancel in-flight on navigate-away. **Compose:** `LazyColumn` of block composables. **Flutter:** `CustomScrollView` + slivers, `fl_chart`. **RN:** `ScrollView`/`SectionList` + React Query per block, `victory-native`.

## UX best practices
Top third answers "what needs me?". Every KPI links out. Tint deltas by **sentiment** (each metric declares its good direction). Round values with exact-on-tap. Distinguish "0" from "—". One FAB. Keep block order stable across sessions.
