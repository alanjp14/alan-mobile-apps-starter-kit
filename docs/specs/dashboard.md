# Screen Specification · Dashboard

> A **full worked example** — the operational Dashboard specified end to end. The reusable template is [`../screen-library/02-dashboard.md`](../screen-library/02-dashboard.md).
> **Design foundation:** Alan Mobile Design System (AMDS) v1.0
> **Archetype:** B — Dashboard ([`../screen-library/00-framework.md`](../screen-library/00-framework.md)) · **Patterns:** [`../screen-library/dashboard-system.md`](../screen-library/dashboard-system.md) · **Navigation:** [`../design-system/navigation-patterns.md`](../design-system/navigation-patterns.md)
> **Targets:** Android (Compose + Views), iOS (SwiftUI + UIKit), Tablet responsive (Portrait ≥600, Landscape ≥905), Light + Dark
> **Route:** `[app-scheme]://<app>/dashboard` · `https://<app>.[COMPANY_NAME].example/dashboard`
> **Status:** Ready for dev

This is the **operational-leaning** Dashboard (the default for HRIS / K3 / Asset / ERP / CRM / Inventory / NOC internal apps). Executive / Monitoring / Analytics variants reuse the same frame and swap the block mix — see §12.

---

## 1. User Goal

**Primary:** *"When I open the app, tell me in ~5 seconds whether anything needs me, then let me act on it or dive into detail."*

| User | Job-to-be-done | Success signal |
|---|---|---|
| Supervisor / Manager | See what's overdue, awaiting my approval, or off-track for my team/site today | Taps a priority item within 10s of open |
| Field / Ops user (K3, Inventory) | Check today's numbers, then log an entry / report a hazard fast | Reaches the create action in ≤2 taps |
| Executive (exec variant) | Glance at headline KPIs and the trend vs target | Leaves informed without scrolling past one screen |
| Any user | Confidence the data is current | Sees "Updated Xm ago"; pulls to refresh |

**Non-goals:** deep analysis (→ Analytics screen), managing full lists (→ List View), configuration (→ Settings). The Dashboard *links* to depth; it does not contain it.

**Design principles applied (governance §2):** clarity over decoration; the top third answers "what needs me?"; every KPI is a link, not a dead number; progressive load; personalization by role/scope/permission.

---

## 2. UX Flow

### 2.1 Entry points

```
App launch ─► Splash (auth/session resolve, prefetch dashboard) ─► Dashboard  [default landing]
Bottom nav "Home" tab ─────────────────────────────────────────► Dashboard
Deep link / push "…/dashboard" ────────────────────────────────► Dashboard
Back from a spoke (list/detail) ───────────────────────────────► Dashboard (state restored)
Tab re-tap while on Dashboard ─────────────────────────────────► scroll to top ► (2nd tap) refresh
```

### 2.2 Primary flow

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Dashboard opens                                              │
│    • cached data paints instantly (if any) with "Updated …"     │
│    • skeleton for blocks still loading (component-library E2)             │
│    • background refresh kicks off                               │
│                         │                                       │
│    ┌────────────────────┼───────────────────────────────┐       │
│    ▼                    ▼                               ▼       │
│ 2a. Alert strip      2b. Scan KPI grid            2c. "Needs you"│
│    present?             tap a KPI                     list row   │
│    │ tap                │                             │ tap      │
│    ▼                    ▼                             ▼          │
│ Resolve flow /       List View, pre-filtered      Approval detail│
│ filtered list        to that metric               / Task detail  │
│                                                    │ inline act? │
│                                                    ▼            │
│                                             Approve/Assign +     │
│                                             Snackbar(Undo) →     │
│                                             row removed, counts  │
│                                             update in place      │
│                         │                                       │
│                         ▼                                       │
│ 3. Scroll: primary chart ► tap ► Analytics (that metric, range) │
│           recent activity ► tap item ► its source detail        │
│           quick actions ► tap ► create/scan/jump                │
│           FAB ► primary create (New incident / work order / …)  │
│                         │                                       │
│                         ▼                                       │
│ 4. Pull-to-refresh any time ► all blocks revalidate ►          │
│    "Updated just now"; scroll position preserved               │
└─────────────────────────────────────────────────────────────────┘
```

### 2.3 Global filter flow (optional per app)

```
Filter bar chip (Period / Scope) ─► Bottom Sheet (component-library D3)
   • Period: This shift · Today · This week · This month · Custom (Date Picker range)
   • Scope: Site / Team / Region (multi-select, permission-scoped)
─► Apply ─► every block re-queries with the new context ─► active filter chips shown, removable
─► filter state persisted for the session + reflected in deep link (?period=week&site=EAST)
```

### 2.4 Exit points

- Bottom nav → other section (peer switch, not "back").
- KPI / list row / chart / activity → spoke screen (push; back returns here with state).
- FAB → create modal (screen-library §10); on success returns here, affected counts update.
- Notifications icon → Notifications screen. Avatar → Profile.

---

## 3. Wireframe Structure

### 3.1 Phone — portrait (375 × 812 reference)

```
┌───────────────────────────────────────────────┐  ← safe-area top (status bar)
│  Large App Bar (112 → collapses to 56)         │
│  ┌─────────────────────────────────────────┐   │
│  │ Good morning,                    [🔔·3] │   │  greeting: bodyMedium textSecondary
│  │ Priya Nair                       [ 🧑 ] │   │  name: headingLarge  · bell w/ Badge · Avatar sm
│  └─────────────────────────────────────────┘   │
├───────────────────────────────────────────────┤
│  Filter bar (sticky, 48)                       │
│  [ This week ▾ ]  [ Site: East ▾ ]   Updated 2m│  Chips (component-library F) + freshness caption
├───────────────────────────────────────────────┤  ← scroll region, 16dp margins
│                                                │
│  ⚠ Alert strip (Banner, warning)               │  only if alerts > 0
│  3 approvals breach SLA in 4h        [ View ]   │
│                                                │
│  KPI GRID  (2 columns, gap 12)                  │
│  ┌───────────────────┐ ┌───────────────────┐   │
│  │ OPEN INCIDENTS    │ │ AWAITING APPROVAL │   │  KPI Card (component-library C2)
│  │ 12          ▲ 20% │ │ 3           ▼ 1   │   │  value displaySmall (tnum) · delta chip
│  │ vs last week      │ │ ▁▂▃▂▅  sparkline  │   │
│  └───────────────────┘ └───────────────────┘   │
│  ┌───────────────────┐ ┌───────────────────┐   │
│  │ OVERDUE TASKS     │ │ ON-TIME RATE      │   │
│  │ 5           ▲ 2   │ │ 94%         ▲ 3pp │   │
│  └───────────────────┘ └───────────────────┘   │
│                                                │
│  ── Needs you ─────────────────  (overline)     │
│  ┌───────────────────────────────────────────┐ │
│  │ 🧾  PR-88120 · Rp 4.2M       2d   [Approve]│ │  List item (component-library F) + inline Button sm
│  │     S. Adeyemi · Procurement              │ │  swipe: →Approve  ←Open
│  ├───────────────────────────────────────────┤ │
│  │ 🔧  WO-1043 overdue 1d       ●   [Assign ]│ │
│  │     Compressor A-12 · East               │ │
│  ├───────────────────────────────────────────┤ │
│  │ … (max 5)                    [ View all → ]│ │
│  └───────────────────────────────────────────┘ │
│                                                │
│  ── Trend ─────────────────────                 │
│  ┌───────────────────────────────────────────┐ │  Chart Card (component-library C3)
│  │ Incidents: opened vs closed   [7d·30d·90d]│ │  segmented range
│  │                                           │ │
│  │      ╱╲      ╱╲___                         │ │  line, ≤2 series, min-height 200
│  │  ___╱  ╲__╱       ╲___                     │ │
│  │  M  T  W  T  F  S  S                       │ │
│  │  ● Opened   ● Closed        View report → │ │  legend chips (toggle) + link
│  └───────────────────────────────────────────┘ │
│                                                │
│  ── Recent activity ───────────                 │
│  ┌───────────────────────────────────────────┐ │
│  │ 🟢 P. Nair approved PR-88090      9:12 AM  │ │  List item, 2-line, icon leading
│  │ 📝 New incident INC-2025-0442     8:40 AM  │ │
│  │ 🔧 WO-1039 closed by S. Lee       Yesterday│ │
│  │                              [ View all → ]│ │  (max 5)
│  └───────────────────────────────────────────┘ │
│                                                │
│  ── Quick actions ─────────────                 │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐           │  tile grid: icon 24 + label
│  │ ➕   │ │ 📷   │ │ 📋   │ │ 🔍   │           │  New · Scan · Inspection · Find asset
│  │ New  │ │ Scan │ │Inspect│ │ Find │           │
│  └──────┘ └──────┘ └──────┘ └──────┘           │
│                                                │
│  (bottom padding = FAB 56 + space.4×2 = 88)     │
├───────────────────────────────────────────────┤
│                              ╭─────╮           │
│                              │  ➕ │  FAB      │  component-library A3 · elevation3 · bottom-right
│                              ╰─────╯           │
├───────────────────────────────────────────────┤
│  Bottom Navigation (64)                         │  navigation-patterns §3
│  [ ⌂ Home ] [ ▤ Records ] [ ✔ Approvals·3 ] [ ☰ More ] │
└───────────────────────────────────────────────┘  ← safe-area bottom (home indicator)
```

**Vertical rhythm:** app bar → filter bar → `space.4` → alert → `space.6` → KPI grid → `space.8` → "Needs you" → `space.8` → Trend → `space.8` → Activity → `space.8` → Quick actions → `space.10` bottom.
Section headers: `overline`, `textSecondary`, `space.3` below.
Content margin: 16 (phone).

### 3.2 Tablet — portrait (768 × 1024)

- Content max-width **640**, centered; margins 24.
- App bar: center-aligned or large; Navigation **Rail** replaces bottom nav (navigation-patterns §2) on the leading edge (80dp).
- KPI grid → **4 across**.
- "Needs you" and "Recent activity" sit **side by side** (2-col, gap 24) below the KPIs.
- Trend chart full content width.
- Quick actions → single row of up to 6 tiles.
- FAB: bottom-right of the content area, or a prominent "New" button at the top of the rail.

### 3.3 Tablet — landscape (1024 × 768 / 1280 × 800)

- Persistent **Navigation Drawer** (280dp, navigation-patterns §5), always open.
- Content region uses a **12-col grid**, margins 32, gutter 24. Two-zone layout:

```
┌────────────┬───────────────────────────────────────────────────────┐
│  Drawer    │  App bar (56)  · filter bar · Updated 2m               │
│  280       ├───────────────────────────────────────────────────────┤
│  ⌂ Home    │  ⚠ Alert strip (full width)                            │
│  ▤ Records │  ┌──────────────────────────┐ ┌────────────────────┐   │
│  ✔ Approv. │  │ KPI  KPI  KPI  KPI (4-up)│ │ Needs you (list)   │   │  left 8 col / right 4 col
│  🔔 Notif. │  ├──────────────────────────┤ │  PR-88120 [Approve]│   │
│  ⚙ Settings│  │ Trend chart (large)      │ │  WO-1043  [Assign ]│   │
│            │  ├──────────────────────────┤ │  …                 │   │
│  [+ New]   │  │ Secondary chart · table  │ │ Recent activity    │   │
│            │  └──────────────────────────┘ └────────────────────┘   │
└────────────┴───────────────────────────────────────────────────────┘
```

- KPI grid 4-up (optionally 6-up on 1280+).
- Primary chart larger (~280 tall); room for a **secondary** chart or a compact breakdown table (data-display) beneath.
- "Needs you" + "Recent activity" pinned in the right rail, independently scrollable.
- No FAB — the drawer's "New" button is the create affordance; quick actions become a row above the charts or a drawer section.
- Optional: tapping a "Needs you" row opens the item in a **right-side detail pane** (list-detail, navigation-patterns §2) instead of a full push.

### 3.4 Z-order / layering (component-library, design-foundations §5)

| Layer | z | Elevation |
|---|---|---|
| Content, cards (rest) | base | flat + 1px `border` |
| App bar / filter bar on scroll-under | sticky/appBar | `elevation2` |
| FAB | raised | `elevation3` |
| Bottom sheet (filter) | bottomSheet | `elevation4` + scrim |
| Snackbar (undo) | toast | `elevation3`, above FAB/bottom nav |

---

## 4. Component Mapping

| # | Region | AMDS component (component-library) | Variant / config | Key tokens |
|---|---|---|---|---|
| 1 | Header | **Top App Bar** (navigation-patterns §4) | Large → collapses to Small (56) on scroll; leading = none (top-level), trailing = notifications Icon Button + Avatar | bg `surface`; `scrolledUnderElevation` → `elevation2`; title `headingLarge`→`titleLarge` |
| 2 | Greeting | Text | `bodyMedium` `textSecondary` + `headingLarge` `textPrimary` | — |
| 3 | Notifications | **Icon Button** (A2) + **Badge** (D7) | Standard icon `notifications`; Badge = count (dot if unread-only) | badge `danger` bg, `onDanger` text, 1.5px `surface` ring |
| 4 | Profile | **Avatar** (D8) | size `sm` (32); photo → initials → `person` | ring in dark: 1px `border` |
| 5 | Filter bar | **Chip** (F) ×N, assist/filter style | trailing `expand_more`; opens **Bottom Sheet** (D3) picker | `surfaceVariant` bg, `label` text; selected → `primaryContainer` |
| 6 | Freshness | Text (`caption` `textSecondary`) + optional live dot | "Updated 2m ago" / "Updating…" | dot `success` (fresh) / `warning` (stale) |
| 7 | Alert strip | **Banner** (D6) | severity: `warning` (SLA risk) / `danger` (breach/incident) / `info`; 1–2 text actions | `warningContainer` / `dangerContainer` bg, `on*Container` text, leading status icon |
| 8 | KPI grid | **KPI Card** (C2) | Standard / Detailed (sparkline); "Alert" variant (left `danger` 2px bar) when metric breaches threshold; 2-up phone / 4-up tablet | card radius `lg`, padding `space.4`, min-height 96; value `displaySmall` tnum; delta chip `success`/`danger` by *sentiment* |
| 9 | KPI sparkline | Mini line (in Chart Card family) | 24–32dp tall, `primary` stroke 1.5dp, no axes | `aria-hidden` (value+delta already announced) |
| 10 | Section headers | Text | `overline`, `textSecondary` | letter-spacing `0.08em` |
| 11 | "Needs you" container | **Card** (C1) Outlined, holding **List items** (F) | rows 72 (2-line); leading category icon 24; trailing inline **Button** (A1) `size=sm` `variant=tonal` (Approve) or `secondary` (Assign) | row divider `divider`; pressed `surfaceVariant` |
| 12 | Row swipe actions | Swipe actions (component-library F, data-display §9) | leading = positive (Approve) `success`; trailing = Open `info` / secondary | equivalents in row overflow for a11y |
| 13 | "View all" | **Button** (A1) `variant=tertiary` `size=sm` + trailing `arrow_forward` | right-aligned in card footer | `textLink` |
| 14 | Trend | **Chart Card** (C3) | line, ≤2 series (Opened/Closed); header range = **Segmented control** (F) "7d·30d·90d"; legend chips toggle series; footer "View report" link + overflow (Export) | chart min-height 200; gridlines `border` @ low opacity; axis `caption`; palette from dashboard-system §6 |
| 15 | Recent activity | **Card** (C1) + **List items** (F) | 2-line rows 72; leading small icon or **Avatar** `xs`; title `titleMedium`, meta `caption`; timestamp trailing `caption` | max 5 + "View all" |
| 16 | Quick actions | **Card**/tile grid (F, "Empty state"-style tiles) | 3–6 tiles; icon `iconMd` in `primaryContainer` circle + `label`; whole tile = one target | tile radius `md`, `surface` + 1px `border`; press 0.98 scale |
| 17 | Create | **FAB** (A3) | Regular (56) phone; Extended on first-run/empty; hidden on tablet (drawer button) | `primary` bg, `onPrimary` icon, `elevation3` |
| 18 | Primary nav | **Bottom Navigation** (navigation-patterns §3) phone / **Nav Rail** tablet-portrait / **Nav Drawer** tablet-landscape | 3–5 items; "Approvals" carries a **Badge** count | active `primary` + `primaryContainer` pill; inactive `onSurfaceVariant` |
| 19 | Refresh | **Pull-to-refresh** (F) | trigger ~64dp pull; announces "Refreshing"/"Updated" | spinner `primary` |
| 20 | Loading | **Skeleton Loader** (E2), dashboard variant | KPI grid blocks + list rows + chart block; shimmer 1200ms | `skeletonBase` / `skeletonSheen` |
| 21 | Empty / error (per block) | **Empty state** (F) | first-run friendly per section; error = "Couldn't load" + Retry | icon 40, `headingSmall` + `bodyMedium` |
| 22 | Undo | **Snackbar** (D4) | "Approved · Undo" (5–7s); error variant for failed inline action + Retry | `inverseSurface` pill |
| 23 | Offline | **Banner** (D6) `info`/`neutral` | "You're offline — showing data from 09:04" | persistent until reconnect |

**Not used here:** Dialog (no blocking decisions on the dashboard), Modal (create opens its own screen), Tabs (dashboard is not a tabbed object), Table (breakdown table only on tablet-landscape secondary zone).

---

## 5. States

### 5.1 Screen-level states

| State | Trigger | Presentation |
|---|---|---|
| **Cold load (no cache)** | First ever open / cache cleared | Full dashboard **skeleton** (E2): app bar real, filter bar real (disabled), KPI ×4 shimmer, "Needs you" 3 shimmer rows, chart block shimmer, activity 3 shimmer rows. No FAB action until interactive. `aria-busy=true`. |
| **Warm load (cache present)** | Normal open | Cached content paints instantly with **"Updated 9:04 AM"** (stale styling if > staleThreshold). Per-block subtle top progress or shimmer only on blocks being revalidated. Content is interactive immediately. |
| **Loaded / idle** | Data resolved | Full content; "Updated just now" → relative time ticks. |
| **Refreshing** | Pull-to-refresh / tab re-tap ×2 / returned to foreground after > N min | Pull spinner (`primary`); freshness → "Updating…"; blocks update **in place** (diff, no full reflow, no re-animation of KPIs); on done: "Updated just now" + optional single light haptic. Scroll position kept. |
| **Partial failure** | Some blocks OK, some failed | Healthy blocks render normally; failed block shows its inline error state with **Retry** (retries just that block). Screen is not "broken". |
| **Total failure (no cache)** | All requests fail, nothing cached | Full-screen Empty/Error state: `cloud_off`/`error` icon 40, "Couldn't load your dashboard", `bodyMedium` cause hint, **"Try again"** primary button. App bar + bottom nav remain. |
| **Offline (cache present)** | No connectivity | Persistent **Banner**: "You're offline — showing data from 9:04 AM". Pull-to-refresh shows "Can't refresh while offline". Inline actions queue (see 5.3). |
| **Empty (first-run / brand-new user)** | Authenticated, but no data in scope yet | Friendly per-section empties, **not zeros everywhere**: KPI cards show "—" + "No data yet"; "Needs you" → "Nothing needs you right now 🎉"; chart → "Data will appear once activity starts"; Quick actions prominent; **Extended FAB** "Report first incident" / "Add first asset". |
| **Restricted scope** | User's role sees a subset | Blocks the user can't see are hidden entirely (not shown disabled). If nothing is visible → "Your role doesn't have dashboard metrics yet — contact your admin." |

### 5.2 Block-level states (each independently)

| Block | loading | empty | error | stale | special |
|---|---|---|---|---|---|
| KPI Card | label+value+chip skeleton | "—" + "No data yet" | "Couldn't load" + retry icon | value + "as of 9:04" + `warning` dot | **Alert** variant: `danger` left bar + value in `danger` when threshold breached |
| Alert strip | (not shown while loading) | **hidden** when 0 alerts | if alert count fails, omit silently (log) | — | count badge; if > 3, "3 approvals + 2 more" → View all |
| Needs you | 3 shimmer rows | "Nothing needs you right now" + subtle ✓ | "Couldn't load your queue" + Retry | rows + "as of…" chip | row-level: inline action `loading` (spinner in button), then row collapse-out |
| Trend chart | chart-area shimmer + header real | "Not enough data to chart yet" | "Couldn't load chart" + Retry; "View as table" still offered | chart + timestamp | range change → re-query that block only |
| Recent activity | 3 shimmer rows | "No recent activity" | "Couldn't load activity" + Retry | — | new items since last view get a `primaryContainer` tint for 2s on appear |
| Quick actions | render immediately (static) | n/a | n/a | n/a | an action the user lacks permission for is hidden |

### 5.3 Interactive element states (universal model, component-library)

- **KPI Card (interactive):** enabled → focus (2px `borderFocus` ring, 2px offset) → pressed (0.98 scale + `surfaceVariant` overlay, 100ms `standard`) → navigates to pre-filtered List View.
- **"Needs you" row:** whole row is the target → detail; the trailing **inline button** is a nested target (allowed here because the row is a container, not itself a button — see component-library C1 caveat: this list is *static rows with one explicit action*, not an "interactive card"). Button: enabled → pressed → `loading` (spinner replaces label) → success (row animates out) → Snackbar with Undo.
  - **Inline action failure:** button returns to enabled; Snackbar (error) "Couldn't approve PR-88120 · Retry"; row stays.
  - **Offline:** button → "Queued" pill state; row gets a `schedule` "Pending" chip; syncs on reconnect; Snackbar "Will approve when you're back online".
  - **Race (already actioned by peer):** on tap, server returns 409 → row replaces its action with a `info` "Already approved by S. Lee" chip, then fades out after 3s.
- **Segmented range control:** selected segment `surface` + `elevation1` on `surfaceVariant` track; switch = indicator slide 200ms `standard`; triggers chart-block reload (skeleton just in the chart area).
- **Filter chip:** default → pressed → active (`primaryContainer` + value shown) → removable ("This week ✕"); "Clear all" appears with ≥1 active.
- **FAB:** rest `elevation3` → pressed 0.96 scale → (scroll down) hide via scale+fade 200ms `accelerate` → (scroll up) show 200ms `decelerate`.
- **Pull-to-refresh:** idle → pulling (spinner scales with drag) → armed (past 64dp, light haptic) → refreshing → done.
- **Disabled:** filter bar during cold load (38% opacity, not focusable). No other elements are ever "disabled" on this screen — if a block can't be shown, hide it.

---

## 6. Edge Cases

| # | Case | Handling |
|---|---|---|
| E1 | **No cache + offline on launch** | Full-screen offline-error state; "We'll load your dashboard when you're back online"; auto-retry on connectivity regained; bottom nav still lets them reach cached sections. |
| E2 | **Stale cache (hours/days old)** | Show it, but freshness caption in `warning` ("Updated yesterday 5:12 PM"); banner "Data may be out of date — pull to refresh"; auto-refresh on foreground if last-sync > threshold. |
| E3 | **Very large "Needs you" count (e.g. 240 pending)** | Show top 5 by priority/age; header "Needs you · 240"; card footer "View all 240 →"; never render 240 rows. |
| E4 | **Zero alerts / zero priorities** | Alert strip hidden; "Needs you" → positive empty ("You're all caught up"). Don't show an empty card frame. |
| E5 | **KPI value huge / tiny / negative** | Abbreviate (1.2M, 12.4k) with exact on tap/long-press; negative in `danger` with a minus sign (not just red); zero shown as "0", missing as "—" — never conflate. |
| E6 | **Delta undefined (no prior period)** | Hide the delta chip; show "New" or "No prior data" in `caption`. Never show "▲ ∞%" or "▲ 100%" from a zero base. |
| E7 | **"Good direction" ambiguity** (e.g. Overtime hours ▲) | Each metric declares `goodDirection`; delta chip tinted by **sentiment**, not raw sign. Overtime up = `danger` tint + ▲. On-time rate up = `success` + ▲. |
| E8 | **Threshold breach mid-session** (metric crosses red line while screen open) | On next refresh, KPI switches to **Alert** variant with a brief `dangerContainer` flash (150ms, reduced-motion: no flash); if severe, a new row appears in the Alert strip with an entry animation. Never a modal. |
| E9 | **Chart: single data point / all-zero series** | "Not enough data to chart yet" empty state; keep the range selector so they can widen it. |
| E10 | **Chart: one series hidden via legend, then both** | Hiding the last visible series is blocked (min 1) OR shows "Select a series to display"; toggling is per-session, resets on screen leave. |
| E11 | **Filter yields no data** ("Site: North" has nothing) | Blocks show their empty states scoped to the filter ("No incidents for North this week"); prominent "Clear filters" in the filter bar. |
| E12 | **Permission change while open** (role downgraded server-side) | Next refresh removes now-forbidden blocks gracefully; if the whole dashboard becomes empty → restricted-scope state (5.1). |
| E13 | **Timezone / clock skew** | All timestamps rendered in the user's device timezone with a consistent format; "2m ago" computed from server time, not device clock; if skew > 5min, silently use server time. |
| E14 | **Push arrives while on Dashboard** (e.g. "New approval assigned") | No interruption. On next auto-refresh (or immediately via silent data push), the "Needs you" count/rows update in place with a subtle highlight; Notifications badge increments. |
| E15 | **Rapid tab switching / re-entry** | Debounce refresh (don't refetch if last refresh < 30s ago unless pull-to-refresh); cancel in-flight requests on navigate-away; restore scroll + filter + chart-range on return. |
| E16 | **Deep link `…/dashboard?site=EAST&period=week`** | Apply the filter on load; show active filter chips; back stack = just Dashboard (it's a top-level destination). Unknown/forbidden param → ignore it, load default, don't error. |
| E17 | **Extremely long name / greeting** ("Dr. Maria-Fernanda de la Cruz-Hernández") | Name truncates to 1 line with ellipsis in the app bar; full name available in Profile. Greeting never pushes actions off-screen. |
| E18 | **Dynamic Type at 200% / small phone (320w)** | KPI grid drops to **1 column**; delta chips wrap below the value; "Needs you" rows grow to 3 lines; quick-action tiles → 2 columns; nothing clipped, no horizontal scroll. |
| E19 | **RTL locale (Arabic)** | Full mirror: app bar actions swap sides, FAB → bottom-left, chevrons/`arrow_forward` flip, sparkline time axis flips, delta triangles keep semantic (up=up), numbers stay LTR within RTL text. |
| E20 | **User has multiple sites/roles** | Scope filter defaults to "All my sites" or the primary; selection persists per user server-side so it's consistent across devices. |
| E21 | **Inline approve on an item that got recalled by requester** | 409/"recalled" → row shows `info` "Recalled by requester", fades after 3s, count decrements. |
| E22 | **Slow network (data trickles in over 8s)** | Each block resolves independently and swaps its skeleton for content with a 150ms crossfade; no "all or nothing"; a global timeout (e.g. 20s) flips still-loading blocks to their error state. |
| E23 | **Backgrounded for days, reopened** | Treat as cold-ish: show cache instantly if within retention, else skeleton; force refresh; re-check auth/session first (may route to Login, then back). |
| E24 | **Reduced data / low-power mode** | Pause sparkline/'count-up' animation, skip chart draw-in, lower auto-refresh frequency, don't prefetch secondary charts. |

---

## 7. Accessibility (accessibility · WCAG 2.2 AA)

### 7.1 Structure & screen reader

- **Reading order** matches visual: app bar (greeting → name → notifications → avatar) → filter bar → alert → KPI grid (row-major) → Needs you → Trend → Activity → Quick actions → FAB. RTL mirrored.
- **Headings:** "Priya Nair" (app bar) = `heading level 1` and the screen's accessible name; each section label ("Needs you", "Trend", "Recent activity", "Quick actions") = `heading level 2`. Users can navigate by heading.
- **Landmarks:** app bar = `banner`/navigation region; scroll content = `main`; bottom nav = `navigation` labeled "Primary".
- **KPI Card** announces one sentence: *"Open incidents, 12, up 20 percent versus last week. Button."* Sparkline is `aria-hidden`. Delta direction is in the words ("up"/"down") and the icon, never color alone.
- **Alert strip:** `role=alert` when it appears in response to a refresh that surfaced a new breach; otherwise a labeled `region`. Text carries the meaning; icon + `warning`/`danger` color are secondary.
- **"Needs you" row:** grouped into one SR stop — *"PR-88120, 4.2 million rupiah, submitted by S. Adeyemi, Procurement, 2 days old."* The inline **Approve** button is a separate focusable control with an unambiguous name: *"Approve PR-88120"* (not just "Approve"). Swipe actions are exposed as **custom actions** (TalkBack) / **actions rotor** (VoiceOver): "Approve", "Open".
- **Chart:** container labeled *"Incidents opened versus closed, last 7 days. 42 opened, 38 closed."* Mandatory **"View as table"** toggle → a real `table` (data-display §12) with columns Day / Opened / Closed. Legend toggles are `toggle button`s with state.
- **Recent activity:** each row one stop — *"Priya Nair approved PR-88090, 9:12 AM."*
- **Quick action tile:** `button`, name = the label + purpose ("New incident", "Scan asset barcode").
- **Freshness:** exposed as text; when it changes to "Updating…"/"Updated just now", announce **politely** (`aria-live=polite`), throttled — not on every tick.
- **Counts changing** after an inline action: polite announcement — *"Awaiting approval, now 2."*

### 7.2 Contrast (verified against design-foundations §1.6)

| Element | Light | Dark |
|---|---|---|
| KPI value `textPrimary` on `surface` | 17.9:1 ✓ | 15.9:1 ✓ |
| KPI label / section header `textSecondary`/overline on `surface` | 4.76:1 ✓ (do **not** place on `surfaceVariant`) | 6.4:1 ✓ |
| Delta chip text on `successContainer` / `dangerContainer` | `on*Container` ≥ 4.5:1 ✓ | ≥ 7:1 ✓ (translucent container + -100 text) |
| Inline **Approve** button (tonal): `onPrimaryContainer` on `primaryContainer` | ≥ 4.5:1 ✓ | ≥ 7:1 ✓ |
| FAB icon `onPrimary` on `primary` | white on `#16A34A` 3.31:1 → **large icon (24) / UI component**, meets 3:1 ✓ | `#052E16` on `#4ADE80` 9.1:1 ✓ |
| Focus ring `borderFocus` vs adjacent surface | green-600 on white 3.31:1 ✓ | green-400 on slate-900 8.9:1 ✓ |
| Chart series 1/2 (green-600 / sky-600) — differ in **lightness**, plus direct legend labels + markers | ✓ | lightened palette ✓ |
| Card border `border` vs `surface` | decorative (1.24:1) — separation also carried by padding + elevation on scroll | slate-700 1.6:1 |

No status is conveyed by color alone anywhere (icon + label + color together).

### 7.3 Targets, motion, input

- All interactive elements ≥ **44×44dp**; inline row button ≥ 44 tall (visually `size=sm` 36 → hit area padded); ≥ 8dp between the row-tap and the button.
- FAB not under the home indicator; bottom nav items ≥ 48dp; ≥ 8dp between filter chips.
- **Keyboard / switch / D-pad:** logical focus order; KPI cards, rows, buttons, chips, tiles, FAB all reachable; Esc/back closes the filter sheet and returns focus to the chip; no focus trap on the scroll view.
- **Focus not obscured** (2.4.11): sticky app bar + filter bar height added as scroll padding so a focused element below never hides under them; same for the FAB/bottom nav at the bottom.
- **Reduced motion:** no KPI count-up (snap to value), no sparkline draw, no chart draw-in, no staggered card entrance (all appear together), threshold-breach flash replaced by an icon/label change, FAB hide/show becomes instant, skeleton shimmer → static blocks. Pull-to-refresh spinner kept (functional).
- **Dynamic Type / font scale to 200%** + Bold Text: layout reflows per E18; no clipping; line heights from the type scale.
- **Dragging alternative** (2.5.7): pull-to-refresh has a manual "Refresh" action in the app bar overflow; filter is a sheet (no drag); chart range is buttons.
- **Touch cancellation** (2.5.2): all actions fire on up-event; dragging off cancels.
- **No timeout** on the screen; session-expiry handled by re-auth + return, nothing lost.

### 7.4 Platform a11y APIs

- **Android:** `contentDescription` on icon button/FAB/tiles; `Modifier.semantics { heading() }` on section labels; `LiveRegionMode.Polite` for freshness/counts; custom actions via `customActions`; `stateDescription` for the segmented control; test with **TalkBack** + Accessibility Scanner + `AccessibilityChecks` in instrumentation tests.
- **iOS:** `.accessibilityElement(children: .combine)` for rows/KPIs; `.accessibilityAddTraits(.isHeader)`; `.accessibilityCustomActions` for swipe actions; `.accessibilityLabel/Value/Hint`; `UIAccessibility.post(.announcement …)` throttled for refresh; test with **VoiceOver** + Accessibility Inspector + `XCTest performAccessibilityAudit()`.
- **Flutter:** `Semantics(header: true, …)`, `MergeSemantics` for rows, `liveRegion: true` for freshness, `CustomSemanticsAction` for swipes; `meetsGuideline(textContrastGuideline / androidTapTargetGuideline / iOSTapTargetGuideline / labeledTapTargetGuideline)`.
- **React Native:** `accessibilityRole` (`header`, `button`, `image`), `accessibilityLabel`, `accessibilityLiveRegion="polite"` (Android) + `AccessibilityInfo.announceForAccessibility` (iOS) throttled, `accessibilityActions` for swipes; lint with `eslint-plugin-react-native-a11y`.

---

## 8. Animations (motion — tokens: 100/150/200/250/300/400ms; easings `standard`/`decelerate`/`accelerate`/`spring`)

| # | Moment | Animation | Duration · Easing | Reduced-motion |
|---|---|---|---|---|
| A1 | **Screen enter** (from Splash) | Content crossfade in; app bar title settles from large; blocks fade+riseY 8→0, **staggered 30ms**, cap 8 | fade 200 `decelerate`; stagger 30ms | crossfade 150, no rise, no stagger |
| A2 | **Skeleton → content** (per block) | Shimmer stops; skeleton crossfades to real content, **zero layout shift** | 150 crossfade `standard` | same (crossfade only) |
| A3 | **KPI count-up** (first load only) | Value counts 0 → target with tabular figures; sparkline draws L→R | 300 `standard` (count), 400 `decelerate` (spark) | snap to value, spark drawn instantly |
| A4 | **Delta chip** | Fades/scales in after the value settles (+80ms offset) | 150 `spring` (subtle) | fade only |
| A5 | **App bar collapse on scroll** | Large title height + size interpolate to Small; elevate to `elevation2` on scroll-under | tied to scroll offset; elevation 150 `standard` | no motion tie is fine; elevation still appears |
| A6 | **Filter bar sticky** | Sticks under the app bar; subtle shadow on overlap | 150 `standard` | instant |
| A7 | **Pull-to-refresh** | Spinner scales/rotates with drag; release → settle; content nudges down then back | drag-linked; release 250 `standard` | spinner kept (functional), no content nudge |
| A8 | **Block refresh (in place)** | Only changed values crossfade; changed KPI briefly outlines in `primary` (1px, fades) | 150 crossfade; outline 400 fade-out | crossfade only, no outline pulse |
| A9 | **Threshold breach** | KPI → Alert variant: `dangerContainer` background flash then settle; left `danger` bar wipes in | flash 150 `standard`; bar wipe 200 `decelerate` | no flash; bar appears instantly; icon+label change |
| A10 | **New alert-strip row** | Height expand + fade + slideY -8→0 | 250 `standard` | fade only, no slide |
| A11 | **Inline Approve** | Button label → spinner (crossfade) → on success row **collapses** (height→0) + fades + slides toward trailing edge; list closes the gap | label 150; row exit 200 `accelerate`; gap close 200 `standard` | row disappears with 150 fade, no slide |
| A12 | **Snackbar (Undo)** | Slide up + fade from above bottom nav | in 200 `decelerate`, out 150 `accelerate`; auto-dismiss 6s (extended when SR/switch active) | slide replaced by fade |
| A13 | **Undo tapped** | Row re-expands back into place | 200 `decelerate` | fade in |
| A14 | **Segmented range change** | Indicator slides between segments; chart area skeleton → new line draws in | indicator 200 `standard`; line draw 300 `decelerate` | indicator instant; line appears without draw |
| A15 | **Legend series toggle** | Series line/area fades out/in; y-axis rescales | 200 `standard` | instant |
| A16 | **Chart tooltip** (tap-hold) | Crosshair + tooltip fade in at touch x; follows drag | 100 `standard` | fade only, no follow easing |
| A17 | **KPI / row / tile press** | Scale to 0.98 (cards/tiles) / 0.96 (FAB) + `surfaceVariant` overlay; release `spring` back | press 100 `standard`; release 150 `spring` | overlay color change only, no scale |
| A18 | **Navigate to spoke** | Shared-axis X: outgoing → -25% + fade, incoming from +30% + fade (parallax) | 250 `moderate` (`decelerate` in / `accelerate` out); pop 200 | crossfade 150, no translation |
| A19 | **FAB scroll hide/show** | Scroll down → scale 0→ + fade out; scroll up → scale + fade in | 200 (`accelerate` hide / `decelerate` show) | instant show/hide (or keep always visible) |
| A20 | **Recent-activity new item** | Row inserts with height expand + `primaryContainer` tint that fades over 2s | insert 200 `standard`; tint fade 2000 linear | insert instant; brief static tint then remove |
| A21 | **Theme switch (light⇄dark)** | Root crossfade | 200 | instant |
| A22 | **Empty→populated** (first data arrives) | Empty state fades out, real block fades/rises in | 200 crossfade | crossfade 150 |

**Choreography rules honored:** one focal point per transition; the tapped element leads the navigation (origin-anchored); enter/exit paired; stagger only on first paint (≤8, 30ms); **no re-animation on silent background refresh** — only changed values move (A8); everything interruptible (acting mid-animation snaps to current state). Nothing exceeds 400ms except the 2s activity tint (ambient, non-blocking) and looping indicators. No flashing > 3×/sec. Optional haptics: single light tick on refresh-armed and on inline-action success (respect system setting).

---

## 9. Developer Notes

### 9.1 Architecture (project-structure)

- **One `DashboardViewModel` / `DashboardModel` / `useDashboard` hook** exposing a single `DashboardUiState`:
  ```
  DashboardUiState {
    header: { greeting, name, avatarUrl, unreadCount }
    filter: { period, scope, isDefault }
    freshness: { lastSyncedAt, isStale, isRefreshing }
    connectivity: Online | Offline
    blocks: {
      alerts:   BlockState<List<AlertItem>>
      kpis:     BlockState<List<Kpi>>           // Kpi { id, label, value, formattedValue, delta, goodDirection, sentiment, sparkline?, threshold?, breached, targetRoute }
      needsYou: BlockState<NeedsYou>            // { items: List<ActionItem>, totalCount }
      trend:    BlockState<TrendData>          // { range, series: [Opened, Closed], asOf }
      activity: BlockState<List<ActivityItem>>
      quickActions: List<QuickAction>          // static, permission-filtered
    }
  }
  BlockState<T> = Loading | Empty(reason) | Error(retryable, traceId) | Data(T, stale?)
  ```
- **Each block loads independently** (separate requests / query keys) so one slow/failing block never blocks the screen. Aggregate a `/dashboard` endpoint **or** parallel calls behind a coordinator — prefer a single backend-for-frontend `/dashboard?period=&scope=` that returns partials with per-section status.
- **Screen is stateless UI** fed the `UiState`; ViewModel owns fetching, caching, refresh policy, optimistic updates.
- **Caching:** persist the last successful `DashboardUiState` (per filter combo) encrypted; TTL for "fresh" = 5 min, "stale" styling after that, hard-expire (skeleton) after retention (e.g. 24h). Use react-query / a repository with `staleTime`/`cacheTime` equivalents.
- **Refresh policy:** on cold start; on foreground if `now - lastSync > 5min`; on pull-to-refresh (always); on tab re-tap ×2; **debounced** so navigate-back within 30s doesn't refetch. Cancel in-flight on navigate-away.
- **Real-time (optional):** silent data push / websocket updates `needsYou` count + `alerts` in place; no full refetch, no re-animation (A8/A14 semantics).

### 9.2 Per-platform

| Concern | Android (Compose) | iOS (SwiftUI) | Flutter | React Native |
|---|---|---|---|---|
| Theme | `AmdsTheme { }`, `AmdsTheme.colors/spacing` | asset-catalog `Color("amds/…")` (auto dark) + `.amds*` text styles | `Theme.of(context).extension<AmdsTokens>()` | `useTheme()` → `amdsLight/amdsDark` |
| Scroll container | `LazyColumn` with `item {}`/`items {}` per block; `contentPadding` = safe area + FAB space | `ScrollView` + `LazyVStack`, or `List` with `.listStyle(.plain)`; `.safeAreaInset` | `CustomScrollView` + slivers (`SliverAppBar` large→pinned) | `FlatList`/`ScrollView`; `Animated` header via `useAnimatedScrollHandler` (Reanimated) |
| Large collapsing app bar | `TopAppBar` + `enterAlwaysScrollBehavior` / `exitUntilCollapsed` | `.navigationBarTitleDisplayMode(.large)` (auto-collapse) | `SliverAppBar(expandedHeight: 112, pinned: true)` | custom animated header (Reanimated) |
| Pull-to-refresh | `PullToRefreshBox` (M3) | `.refreshable { }` | `RefreshIndicator` | `RefreshControl` on the list |
| KPI grid | `FlowRow` / `LazyVerticalGrid(GridCells.Fixed(2))` non-scrolling inside the column | `LazyVGrid(columns: adaptive)` | `GridView` shrink-wrapped / `Wrap` | `FlatList numColumns` or flex wrap |
| Sparkline / chart | Vico or Compose canvas; **off main thread** data prep | Swift Charts | `fl_chart` | `victory-native` / `react-native-svg` |
| Adaptive nav | `WindowSizeClass` → BottomBar / NavigationRail / PermanentNavigationDrawer | `NavigationSplitView` (landscape) / `TabView` (phone) | `LayoutBuilder` / `adaptive_navigation` | `useWindowDimensions` + conditional navigator |
| FAB hide on scroll | track `scrollOffset` delta → `AnimatedVisibility` scale+fade | `.offset`/`.opacity` on `scrollPosition` | `AnimatedSlide`/`AnimatedScale` on scroll notification | Reanimated shared value from scroll handler |
| Inline action | ViewModel `approve(id)` → optimistic remove + `UndoState` + timer | same | same | react-query `useMutation` with `onMutate` optimistic + rollback |
| Snackbar/undo | `SnackbarHostState` (host above bottom bar/FAB) | custom overlay or `.toast` lib; ensure above tab bar | `ScaffoldMessenger` `SnackBar(behavior: floating)` | a themed toast component, `zIndex: toast` |
| Deep link | nav-graph `deepLinks` for `dashboard?period=&scope=` | `onOpenURL` → parse `AppRoute.dashboard(period,scope)` | GoRouter route + query params | `linking` config |
| Freshness ticker | `LaunchedEffect` 30s tick recomputing relative time | `TimelineView(.periodic)` | `Timer.periodic` in the controller | `setInterval` in the hook |
| A11y announce (throttled) | `LiveRegionMode.Polite` on the freshness/count text | `UIAccessibility.post(.announcement:)` ≥ 2s apart | `SemanticsService.announce` | `AccessibilityInfo.announceForAccessibility` throttled |
| Status/nav bar | `enableEdgeToEdge`, set bar icon contrast per theme | `.toolbarColorScheme` / `preferredColorScheme` | `SystemUiOverlayStyle` | `react-native-edge-to-edge` / `StatusBar` |

### 9.3 Formatting & i18n

- **Numbers:** central formatter; abbreviate ≥ 10,000 (`12.4k`, `1.2M`) with `tnum`; exact value on tap/long-press (Tooltip/Snackbar). Locale-aware grouping/decimal. Percentages: "pp" for point-differences ("▲ 3pp"), "%" for ratios.
- **Currency:** locale + currency code; store minor units; right-align in comparisons.
- **Dates/times:** relative for < 24h ("2m ago", "9:12 AM"), absolute + day for older ("Yesterday", "3 Mar"); user timezone; server time as source for "ago".
- **Strings:** 100% externalized; templated with placeholders ("{count} approvals breach SLA"), no concatenation; support ~+35% expansion; plural rules (ICU).
- **RTL:** logical-start/end paddings; mirror per E19; keep numerals/charts LTR within RTL.

### 9.4 Performance budget (scalability §5)

- Warm-start dashboard **first meaningful paint < 400ms** from cache; interactive < 800ms.
- 60fps scroll on min-spec device (e.g. 3-yr-old mid Android): virtualize the outer scroll; KPI grid and chart must not re-layout on scroll; pre-rasterize the chart; images/avatars lazy + sized to prevent shift.
- Chart: downsample series to ≤ ~120 points (LTTB); build data off the main thread.
- Debounce filter changes 250ms; cancel superseded requests.
- Don't prefetch secondary/tablet-only charts on phones or in low-power mode.
- Memory: cap cached dashboard snapshots (last 3 filter combos).

### 9.5 Analytics (tracking plan)

| Event | Properties |
|---|---|
| `dashboard_viewed` | `source` (launch/tab/deeplink/back), `is_cold_load`, `cache_age_s`, `filter_period`, `filter_scope`, `blocks_shown` |
| `dashboard_refreshed` | `method` (pull/tab_double/foreground), `duration_ms`, `blocks_failed` |
| `kpi_tapped` | `kpi_id`, `value`, `delta`, `breached` |
| `needs_you_action` | `item_type`, `action` (approve/assign/open), `inline` (bool), `outcome` (success/undo/fail/queued/race), `latency_ms` |
| `dashboard_filter_changed` | `period`, `scope`, `from_default` |
| `chart_range_changed` / `chart_series_toggled` / `chart_view_as_table` | `range`, `series`, — |
| `quick_action_tapped` | `action_id` |
| `dashboard_block_error` | `block`, `retryable`, `trace_id` |
| `fab_tapped` | `entity` |

### 9.6 Security / permissions (navigation-patterns §9, form-design-system §7)

- Every block request is scoped server-side to the user's roles/sites — **never** trust client filters for authorization; the scope filter only narrows within what's allowed.
- Hide (don't disable) blocks/actions the user can't access; don't leak counts for out-of-scope data.
- No PII or IDs that are sensitive in deep-link query strings or analytics.
- Inline actions re-check permission + record state server-side (handle 403/409 per E12/E21).
- Offline action queue stored encrypted; replays with idempotency keys.
- Trace id surfaced in block error states for support (copyable), not raw stack traces.

### 9.7 Definition of done (this screen)

- [ ] Matches Figma at 375 and 905; all tokens bound (Dev Mode shows token names)
- [ ] All screen-level + block-level states implemented (§5) incl. cold/warm/offline/empty/restricted/partial-failure
- [ ] All edge cases §6 covered or explicitly ticketed
- [ ] Light + dark verified (dark-mode checklist); contrast table §7.2 holds
- [ ] Motion §8 uses tokens; reduced-motion path verified; no re-animation on silent refresh
- [ ] TalkBack + VoiceOver walkthrough completes "find and action a priority" without confusion
- [ ] 200% Dynamic Type + Bold Text: reflow per E18, no clipping
- [ ] RTL mirrored
- [ ] Deep link `dashboard?period=&scope=` applies filter, ignores unknown params, back stack correct
- [ ] Adaptive: BottomNav (phone) / Rail (tablet-portrait) / Drawer (tablet-landscape); list-detail pane on landscape optional
- [ ] Perf budget met on min-spec device (FMP, 60fps scroll)
- [ ] Analytics events fire with correct properties
- [ ] Offline: cache shown, actions queued, banner present
- [ ] Snapshot tests: KPI/row/chart/empty/error × light/dark
- [ ] No hardcoded colors/dimens/strings (lint passes)

---

## 10. Layout reference tokens (quick pull)

| Property | Token / value |
|---|---|
| Screen H-margin | `space.4` (16) phone · `space.6` (24) tablet-portrait · `space.8` (32) tablet-landscape |
| App bar height | 112 large → 56 collapsed (`size.appBarHeight`) |
| Filter bar height | 48 |
| Section header → content gap | `space.3` (12) |
| Between sections | `space.8` (32) |
| KPI grid gap | `space.3` (12) |
| KPI card | radius `lg` (16), padding `space.4` (16), min-height 96 |
| List row (Needs you / activity) | min-height 72 (2-line), padding `space.4` |
| Card (containers) | radius `lg`, 1px `border`, flat at rest → `elevation2` on press/hover |
| Chart card chart area | min-height 200 (phone) / 240 (tablet-portrait) / 280 (tablet-landscape) |
| Quick action tile | radius `md` (12), 1px `border`, icon `iconMd` (24) in `primaryContainer` circle |
| FAB | `size.fabSize` 56, `elevation3`, `space.4` from edges, `space.4` above bottom nav |
| List bottom padding | FAB (56) + `space.4`×2 = 88 |
| Bottom nav | 64 + safe area |
| Focus ring | 2px `borderFocus`, 2px offset |
| Press scale | 0.98 cards/tiles · 0.96 FAB · 100ms `standard` in, 150ms `spring` out |
