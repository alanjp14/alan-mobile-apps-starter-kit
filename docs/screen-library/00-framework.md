# Mobile Screen Library · 00 · Framework

> **Foundation:** Alan Mobile Design System (AMDS) v1.0
> **Standard:** Android-first · iOS-compatible · Tablet-responsive · Light + Dark · WCAG 2.2 AA · Enterprise-grade
> **Applies to:** HRIS · ERP · CRM · Asset Management · Inventory · Mining K3 · Monitoring · Internal Apps · SaaS

This document defines the **shared skeleton, 8 reusable screen archetypes, and cross-platform implementation** that every screen in files `01`–`10` inherits. Each per-screen spec documents only its **deltas** from its archetype.

---

## 1. How to use this library

1. Pick the screen you need from `01`–`10`.
2. Read its **Archetype** line → read that archetype in §4 here (that is 80% of the spec).
3. Read the screen's own entry for the screen-specific 20% (purpose, IA, fields/columns/actions, edge cases).
4. Implement using §5 (Compose / Flutter / React Native recommendations) + the AMDS token/component files.
5. Verify against §6 (universal checklists).

Every screen entry provides all 13 required dimensions: Purpose · User Goal · Layout Structure · Component Hierarchy · Information Architecture · User Flow · States (Loading/Empty/Success/Error/Offline) · Accessibility · Animations · Dark Mode · Tablet Adaptation · Developer Notes · UX Best Practices — inheriting from the archetype where unchanged.

---

## 2. Universal screen skeleton

```
┌───────────────────────────────┐  safe-area top (status bar / notch)
│  System status bar (themed)   │
├───────────────────────────────┤
│  Top App Bar            56dp   │  AMDS navigation-patterns §4 — leading (back/menu/close) · title · ≤2 actions · overflow
├───────────────────────────────┤
│  [ Contextual bar ]            │  optional: tabs · filter chips · search · stepper · selection bar
├───────────────────────────────┤
│  [ Screen-level Banner ]       │  optional: offline · permission · sync · maintenance (component-library D6)
│                               │
│  ┌─────────────────────────┐  │  CONTENT REGION
│  │  scroll container        │  │  margins: 16 phone · 24 tablet-portrait · 32 tablet-landscape
│  │  content column          │  │  max content width: 640 (tablet portrait) · 1040 (landscape)
│  │  …                       │  │
│  └─────────────────────────┘  │
│                               │
├───────────────────────────────┤
│  [ Sticky footer / CTA ]      │  optional: primary action · form submit · decision bar
├───────────────────────────────┤
│  [ Bottom Navigation ] 64dp   │  top-level destinations only (navigation-patterns §3)
├───────────────────────────────┤
│  Home indicator / nav bar     │  safe-area bottom
└───────────────────────────────┘
```

**Layering (z, design-foundations §5):** content (flat + 1px border) → sticky bars on scroll (`elevation2`) → FAB (`elevation3`) → bottom sheet/drawer (`elevation4` + scrim) → dialog (`elevation5` + scrim) → snackbar (toast) → tooltip.

**Spacing rhythm:** section gap `space.8` (32) · header→content `space.3` (12) · between fields `space.5` (20) · card padding `space.4` (16) · list row min-height 56/72/88.

**Motion budget:** 100–400 ms; `standard`/`decelerate`/`accelerate`/`spring` easings; reduced-motion path mandatory (motion).

---

## 3. Adaptive rules (all screens)

| Tier | Width | Nav | Content | Modals |
|---|---|---|---|---|
| Phone S/M/L | 320–430 | Bottom nav | 1 column, 16 margin | Full-screen sheet |
| Tablet Portrait | ≥600 | Nav rail (80) | 1 col max-640 centered; **2-pane list/detail** where applicable; 8-col grid | Centered dialog ≤560 |
| Tablet Landscape | ≥905 | Persistent drawer (280) | 12-col grid, 32 margin; **2–3 pane**; breadcrumbs | Centered dialog / inline panel |

- Design at **375** first; scale up.
- List screens → **list-detail two-pane** on landscape (selection shows detail in the right pane; deep links still work).
- Forms → single column, max 640, centered on tablet; long forms get a left anchor-nav on landscape.
- Dashboards → KPI grid 2-up → 4-up → 6-up; charts grow; right rail for activity/priorities on landscape.
- Never place interactive elements under a notch or home indicator; honor `SafeArea`/`WindowInsets`.

---

## 4. The 8 archetypes

Each archetype below is a complete 13-dimension spec. Screen files reference these by letter.

---

### Archetype A — Focused Task (auth & single-purpose)

**Used by:** Splash, Onboarding, Login, Register, Forgot Password, Reset Password, OTP Verification, Change Password, Export, Contact Support.

**A1 · Purpose** — accomplish one discrete task with zero distraction; no bottom nav, minimal chrome.

**A2 · User Goal** — "Complete this one thing (sign in / verify / reset / send) quickly and get to where I'm going."

**A3 · Layout Structure**
```
[ status bar ]
[ App Bar: back/close only (none on Splash) ]
[ scroll, 16 margin, content centered vertically on short forms ]
   logo / illustration / icon        (top, space.12 from bar)
   title            displaySmall/headingLarge, centered
   subtitle/instruction  bodyMedium textSecondary, centered, ≤2 lines
   ── form fields (single column, space.5 apart) ──
   inline helper / error per field
   [ Banner: form-level error ]      (on submit failure)
   Primary button (Large, full-width, space.8 above)
   secondary / tertiary link(s)      (Forgot password? · Resend · Use another method)
   footer link                       (Register ↔ Sign in)
[ safe-area bottom ]
```

**A4 · Component Hierarchy**
```
AmdsScaffold(showBottomNav: false)
└─ AppBar(leading: Back|Close|none)
└─ SingleChildScroll > Center > ConstrainedBox(maxWidth 400)
   ├─ Brand/Illustration
   ├─ Text(title) · Text(subtitle)
   ├─ Column(fields)
   │  ├─ AmdsTextField / AmdsPasswordField / AmdsOtpInput
   │  └─ … (helper/error slot each)
   ├─ AmdsBanner(error)?            [conditional]
   ├─ AmdsButton(primary, large, fullWidth, loading)
   ├─ AmdsButton(tertiary) / TextLink   [Forgot / Resend / Switch method]
   └─ Row(footer link)
```

**A5 · Information Architecture** — one task = one screen. Progressive: identity → credential/verification → success. Never combine login+register on one screen. OTP/reset are steps reached only from their initiator (with resend + change-destination). Requirements shown **before** errors.

**A6 · User Flow**
```
Entry (deep link / prior screen)
  → fill field(s)  → validate on blur
  → tap Primary   → validate all → submit (button → loading)
      ├─ success → route to target (resume pending deep link) [+ success animation for reset/verify]
      ├─ field error → focus first error, keep input
      ├─ system error → Banner + Retry, keep input
      └─ offline → Banner "You're offline", disable submit, auto-retry on reconnect
  → secondary link → sibling task screen (Forgot / Resend / Register)
Back/close → previous screen or exit flow (dirty guard on multi-field forms)
```

**A7 · States**
| State | Presentation |
|---|---|
| Loading | Splash: brand + subtle spinner, ≤3s hard cap. Forms: button spinner on submit; async field checks → helper spinner. Initial screen has no skeleton (no data to load). |
| Empty | N/A for most; Onboarding "no content configured" → skip straight to app. |
| Success | Route forward. Reset/Verify/Change Password: inline ✓ animation (motion §4.7) + confirmation text + auto-advance or explicit "Continue". |
| Error | **Validation:** inline under field, specific + actionable, announced on blur/submit; focus first error. **Auth failure:** generic Banner ("Email or password is incorrect" — no account-existence leak); lockout → wait-time message. **System:** Banner + Retry + trace id; input preserved. |
| Offline | Persistent Banner "You're offline"; primary disabled with helper "Connect to continue"; queued submit + auto-retry where safe (not for login). |

**A8 · Accessibility** — single `heading` (title) = screen name; every field visibly labelled + associated; `inputmode`/`keyboardType` per field; errors via `aria-describedby`/live region, announced; required stated in label text; focus order top→bottom; button ≥44dp; paste + password managers + autofill **never blocked**; biometrics offered where enrolled; OTP field accepts paste of the full code and one-time-code autofill; reduced-motion: no shake, border+text+`dangerContainer` flash instead; 200% text: fields/buttons grow, no clip; RTL mirrored.

**A9 · Animations** — screen enter: content fade + riseY 8→0, 200ms `decelerate`. Field focus: border color crossfade 150ms; error message slide-down+fade 150ms `decelerate`. Submit: label→spinner crossfade 150ms. Success: check-draw 250ms `spring` + 200ms path. Failed submit: shake ±6dp ×3 / 300ms (reduced-motion: flash). Route forward: shared-axis X 250ms.

**A10 · Dark Mode** — background `#020617`, surface `#0F172A`, fields `surfaceVariant` `#1E293B`, border `#334155`, focus green-400, primary button green-400 fill + green-950 label. Illustrations use dark variants (never white-bg art on dark). Splash honors theme from the first frame. Contrast re-verified (dark-mode §3).

**A11 · Tablet Adaptation** — content stays `maxWidth 400–480`, centered. Landscape/large: **two-pane** — brand/illustration + value prop on the leading half, the form on the trailing half. Onboarding: illustration left, text right. No bottom nav ever. OTP keypad-friendly spacing.

**A12 · Developer Notes** — no bottom-nav shell route; own `GoRoute`s outside the `ShellRoute`. `sessionController` holds pending deep link → resume after auth. Secure token storage (`flutter_secure_storage` / Keychain / EncryptedSharedPreferences). Rate-limit resend with a visible countdown. Field state via form controller; debounce async validators 400–600ms. Splash = native splash API (`flutter_native_splash` / Android 12 SplashScreen / iOS launch storyboard) then a Dart splash only if you must resolve session.

**A13 · UX Best Practices** — one primary action; verb labels; show password reveal (avoid confirm-password when reveal exists); requirements as a live checklist not post-submit errors; preserve input on every failure; same confirmation whether or not an account exists (forgot password); resend cooldown; never a dead end — always a way forward and back; autofocus the first empty field unless biometrics is the faster path.

---

### Archetype B — Dashboard (overview & orientation)

**Used by:** Executive, Operational, Monitoring, Analytics dashboards, Reports Dashboard.

**B1 · Purpose** — at-a-glance status + the user's priorities + fast paths to depth. Dashboards *link* to detail; they don't contain it.

**B2 · User Goal** — "In ~5s tell me if anything needs me / how we're doing, then let me act or drill in."

**B3 · Layout Structure**
```
[ App Bar: greeting/title · notifications · avatar ]         (Large, collapses to 56)
[ Filter bar (sticky 48): period · scope · "Updated 2m ago" ]
[ scroll, 16 margin ]
   ⚠ Alert strip (Banner)                     only when alerts > 0
   KPI GRID  2-up phone / 4-up tablet          AmdsKpiCard
   ── Priorities / "Needs you" ──              list, ≤5, inline actions, "View all"
   ── Primary visual ──                        AmdsChartCard (1) — trend / status board
   ── Secondary content ──                     breakdown list/table, secondary charts
   ── Recent activity ──                       list, ≤5, "View all"
   ── Quick actions ──                         3–6 tiles / FAB sheet
[ FAB: primary create ]                        phone only
[ Bottom Nav ]
```

**B4 · Component Hierarchy**
```
AmdsScaffold(bottomNav)
└─ SliverAppBar(large) + pinned FilterBar(Chips + freshness)
└─ CustomScrollView slivers:
   ├─ AmdsBanner(alerts)?
   ├─ SliverGrid(AmdsKpiCard × n)
   ├─ AmdsSectionHeader("Needs you") + AmdsCard > List(AmdsListTileX + inline AmdsButton.sm)
   ├─ AmdsSectionHeader("Trend") + AmdsChartCard(segmented range, legend, "View as table")
   ├─ AmdsSectionHeader("Recent activity") + AmdsCard > List(activity rows)
   └─ AmdsSectionHeader("Quick actions") + tile grid
   └─ AmdsFab
```

**B5 · Information Architecture** — top third = "what needs me / is anything wrong". Order by urgency then recency. Every KPI is a link to a pre-filtered list. Global filter applies to **every** block and is visible/removable. Data freshness always shown. Personalized by role, scope, permissions — blocks the user can't see are **hidden**, not disabled.

**B6 · User Flow**
```
Open → cache paints instantly ("Updated …") + skeleton for pending blocks → background refresh
  → tap KPI → filtered List View
  → tap priority row → Detail / Approval Detail  (or inline Approve/Assign → Snackbar+Undo → counts update in place)
  → tap chart → Analytics (that metric, range)
  → tap activity item → its source
  → tap quick action / FAB → create / scan / jump
  → change filter → all blocks re-query → active chips
  → pull-to-refresh → revalidate, keep scroll
```

**B7 · States** — see the dedicated Dashboard spec ([`../specs/dashboard.md`](../specs/dashboard.md) §5) for the full screen-level + per-block matrix. Summary:
| State | Presentation |
|---|---|
| Loading | Cold: full dashboard skeleton (`AmdsSkeletonDashboard`). Warm: cached content + per-block shimmer on revalidating blocks. |
| Empty | First-run: friendly per-section empties ("Nothing needs you 🎉", KPI "—/No data yet"), prominent quick actions / Extended FAB — **not zeros everywhere**. |
| Success | Full content; "Updated just now" relative-time ticks; inline-action success animates the row out + Snackbar. |
| Error | Per-block error + Retry (block-scoped). Total failure + no cache → full-screen error + "Try again". Partial failure = healthy blocks still render. |
| Offline | Banner "showing data from HH:MM"; pull-to-refresh disabled with message; inline actions queue. Stale cache → `warning` freshness + "may be out of date". |

**B8 · Accessibility** — greeting/title = `heading 1` + screen name; section labels = `heading 2` (navigate by heading). KPI announces one sentence ("Open incidents, 12, up 20% vs last week. Button."); sparkline `aria-hidden`; direction in words + icon, never color alone. Alert strip `role=alert` on new breach. Priority row = one grouped stop; inline button separately labelled ("Approve PR-88120"); swipe actions as custom actions. Chart: labelled summary + **mandatory "View as table"**. Freshness/count changes announced **politely, throttled**. Focus-not-obscured: scroll padding = sticky bar heights + FAB/bottom-nav. Reduced-motion: no count-up, no draw-in, no stagger, breach flash → icon/label change.

**B9 · Animations** — enter: blocks fade+riseY staggered 30ms (≤8). KPI count-up 300ms + sparkline draw 400ms (first load only). Skeleton→content 150ms crossfade, zero layout shift. Refresh: only changed values crossfade + 1px `primary` outline fade (400ms). Threshold breach: `dangerContainer` flash 150ms + `danger` bar wipe. Inline approve: label→spinner→row collapse+slide-out 200ms `accelerate`. Segmented range: indicator slide 200ms + chart draw 300ms. FAB hide/show on scroll 200ms. **No re-animation on silent background refresh.**

**B10 · Dark Mode** — surfaces per dark-mode step model; charts: gridlines `#1E293B`, axis text `#94A3B8`, lightened series palette (green-400, sky-400, amber-400, red-400, slate-400, green-300); KPI delta chips use translucent containers + -100 text; skeleton `#1E293B`/`#334155`.

**B11 · Tablet Adaptation** — Portrait: KPI 4-up; "Needs you" + "Recent activity" side by side; nav rail; FAB → rail button or top of content. Landscape: persistent drawer; 12-col with an **8/4 split** — content left (KPIs, charts, secondary table), priorities + activity pinned in a scrollable right rail; tap priority → right-side **detail pane** (list-detail); no FAB (drawer "New").

**B12 · Developer Notes** — one controller exposing `DashboardUiState` with `BlockState<T>` per block; blocks load **independently** (parallel queries or a BFF `/dashboard?period=&scope=` returning partials + per-section status). Cache last successful state per filter combo (encrypted), fresh 5min → stale styling → hard-expire 24h. Refresh: cold start, foreground if >5min, pull, tab-double-tap; debounce so back-within-30s doesn't refetch; cancel in-flight on navigate-away. Charts: downsample ≤120 pts (LTTB), build data off main thread. Optional realtime: silent push updates priorities/alerts in place.

**B13 · UX Best Practices** — glanceable, link to depth. Every number has a period + comparison. Tint deltas by **sentiment** ("Overtime ▲" = bad), each metric declares its good direction. Round values (1.2k) with exact on tap. Distinguish "0" from "—" (missing). Don't interrupt for background changes. One FAB. Keep block order stable across sessions.

---

### Archetype C — List / Collection

**Used by:** User List, Data List, Approval Queue, Notification List, Approval History, plus the "browse" mode of Reports Dashboard.

**C1 · Purpose** — browse, search, filter, sort, and act on a collection of records.

**C2 · User Goal** — "Find the record(s) I need and act, or scan what's new."

**C3 · Layout Structure**
```
[ App Bar: title · search icon · filter icon · (sort) · overflow ]
[ Search field ]                          persistent or expandable
[ Active filter chips + result count + sort control ]
[ scroll: list ]
   [ Section header ]                      optional grouping (Today / Pending / A–Z)
   ┌──────────────────────────────────────┐
   │ [leading]  Title            [trailing]│  AmdsListTileX — icon/avatar/checkbox · title · 1–2 meta lines · value/status/chevron/action
   │            subtitle · meta            │
   └──────────────────────────────────────┘
   … (infinite scroll / Load more / paged)
[ FAB: create ]                            where creation applies
[ Bottom Nav ]
Pull-to-refresh · swipe row actions · long-press → selection mode (contextual app bar)
```

**C4 · Component Hierarchy**
```
AmdsScaffold(bottomNav)
└─ AppBar(actions: Search, Filter, Overflow) + (Contextual selection bar when selecting)
└─ AmdsSearchField?
└─ FilterChipRow(active filters, count, Sort)
└─ AmdsPullToRefresh > ListView.builder / PagedListView
   ├─ SectionHeader?
   ├─ AmdsListTileX (Dismissible for swipe actions; Checkbox in selection mode)
   └─ Footer: AmdsSpinner (next page) | "Load more" | Pagination | "You've reached the end"
└─ AmdsFab
Empty/Error/Offline → AmdsEmptyState / AmdsErrorState / AmdsOfflineBanner
Sort/Filter → AmdsBottomSheet
```

**C5 · Information Architecture** — show total + what's filtered. Row: 1 title + ≤2 metadata + 1 trailing (value/status/chevron/action). Sort options: sensible default (Updated ▼ or domain priority) then date/name/status. Filters grouped in a sheet; active ones as removable chips. Selection mode scopes to the visible/loaded set unless "select all N matching" is offered. Deep-linkable with `?q=&filter=&sort=`.

**C6 · User Flow**
```
Open → skeleton rows → data
  → search (debounce 250–300ms) → results (term highlighted) / no-results empty
  → filter icon → sheet → Apply → chips + count update → deep link updated
  → sort → sheet/menu → re-query, scroll to top
  → tap row → Detail (push) / right pane (tablet landscape)
  → swipe row → primary positive (leading) / destructive|secondary (trailing) → Snackbar Undo
  → long-press → selection mode → contextual bar (count + bulk actions) → confirm destructive with exact count → progress → result summary
  → scroll end → next page
  → FAB → Create form
Back → previous screen; list state (filters/sort/scroll/selection) restored within session
```

**C7 · States**
| State | Presentation |
|---|---|
| Loading | Initial: `AmdsSkeletonList` — 6–8 shimmer rows at real row height. Next page: footer spinner, existing rows interactive. Refresh: pull spinner + subtle top progress. |
| Empty | **No data yet:** icon 40 + "No {entity} yet" + primary "Add {entity}". **No results:** "Nothing matches your search/filters" + echo query + "Clear filters". Distinct copy for each. |
| Success | Rows render; count shown; term highlighted on search; new items (queue/notifications) get a `primaryContainer` tint fade on appear. |
| Error | "Couldn't load {entity}" + "Retry"; keep any already-loaded rows; trace id. |
| Offline | Banner + last cached data + "as of HH:MM"; pull-to-refresh → "Can't refresh offline"; row actions queue with a "Pending" chip. |

**C8 · Accessibility** — each row = one grouped stop whose name summarizes key fields ("Compressor A-12, Active, updated 2 hours ago, 12,400"). Trailing control (switch/button) is a separate labelled node. Swipe actions exposed as custom actions / actions rotor + present in a row overflow. Sort state, filter count, pagination position, and result-count changes announced **politely** ("Showing 24 of 210"). Selection checkboxes labelled with the row identifier ("Select Compressor A-12"). Real list semantics; no keyboard/switch trap on scroll. 44dp rows; ≥8dp between row-tap and trailing action.

**C9 · Animations** — rows fade+riseY staggered 30ms on first paint (≤8, then batch). Row press: `surfaceVariant` overlay. Swipe: follows finger, action reveal, snap on release; row removal = collapse height + fade + slide toward swipe direction, 200ms `accelerate`, list closes gap 200ms `standard`. Selection mode: checkboxes fade in 150ms; app bar crossfades to contextual. New item insert: expand + fade + 2s tint fade. Sort/filter change: list crossfades, scroll to top. Reduced-motion: no stagger, no slide — fade only.

**C10 · Dark Mode** — surface `#0F172A`, row divider `#1E293B`, selected row `primaryContainer` tint + 2px `primary` left bar, status dots use -400 hue + icon/label, skeleton `#1E293B`/`#334155`. Swipe action backgrounds: `success`/`danger`/`info` at readable weight.

**C11 · Tablet Adaptation** — Portrait: wider rows, comfortable density, optional 2-column card grid for card-style lists. Landscape: **list-detail two-pane** — list left (≤420), detail right; selected row highlighted; deep link to a row opens both panes; "Table view" toggle for comparison-heavy lists (data-display §3.3). Density setting (Comfortable/Compact) honored.

**C12 · Developer Notes** — a generic `RecordListConfig` (data source, row builder, filter defs, sort options, empty/error copy, FAB action, selection actions) powers every list. Server-side search/sort/filter/pagination; prefer **keyset/cursor** over offset. Page size 25 phone / 50 tablet. `PagedListView` (`infinite_scroll_pagination`) / Paging 3 (Compose) / FlatList `onEndReached`. Preserve state via a `keepAlive` provider / saved state. Optimistic row updates with Undo. Debounce search 250–300ms; cancel superseded queries.

**C13 · UX Best Practices** — whole row is the target unless it has a trailing control. Common actions on swipe **and** in overflow. Show why zero results + offer "Clear filters". Persist filters/sort/scroll within a session. Undo beats pre-confirm for reversible destructive actions. Never lose selection silently across pages — say "scoped to this page" or offer select-all-matching. Loading skeleton must match real row height (no layout shift).

---

### Archetype D — Detail / Record

**Used by:** User Detail, Data Detail, Approval Detail, Notification Detail, Report Detail.

**D1 · Purpose** — everything about one record + its permitted actions + related data.

**D2 · User Goal** — "Confirm this is the right record, understand its state, and act on it or navigate its related data."

**D3 · Layout Structure**
```
[ App Bar: back · title = record name/ID · edit/overflow actions ]
[ scroll ]
   ── Header block ──
      title headingLarge · status Chip · key metadata row · (image/map/avatar)
   ── Primary actions ── 2–3 buttons (state- & permission-aware)   [or sticky decision bar]
   ── Tabs OR stacked sections ──  Overview · History · Documents · Comments
      field groups: label (textSecondary) + value (textPrimary), in AmdsCard
      related items (mini lists) · activity / audit trail
   ── Destructive action ── bottom or overflow, always confirmed
[ Bottom Nav hidden on pushed detail; back returns to list ]
```

**D4 · Component Hierarchy**
```
AmdsScaffold(showBottomNav: false)
└─ SliverAppBar (medium/large collapsing) + actions
└─ Slivers:
   ├─ HeaderBlock(Text, AmdsChip status, metadata Row, AmdsAvatar/Image)
   ├─ Row(AmdsButton primary actions)  |  sticky AmdsDecisionBar (approval)
   ├─ AmdsTabBar? → TabBarView
   │   └─ per tab: AmdsCard > List(field rows) · related AmdsListTileX · AmdsStepper (chain) · comments
   └─ AmdsButton(destructive, tertiary) / overflow item
Confirm → AmdsDialog.destructive
```

**D5 · Information Architecture** — header answers "right record?" in 1s (name, ID, status, one key attribute). Group fields logically; consistent "—" for empty; hide truly irrelevant fields. Actions reflect record state + user permission (disable with a reason, or hide). Tabs are peer views of the same record — never change what "back" means. Deep-linkable with `?tab=`.

**D6 · User Flow**
```
Enter (from list row / deep link — synthesize back stack: Dashboard → List → Detail)
  → scan header → confirm identity
  → primary action (Approve / Check out / Assign / Mark read) → optimistic + Snackbar
  → switch tab → History / Documents / Comments (state retained per tab)
  → tap related item → its detail
  → Edit → CRUD form (modal/push) → save → return, changed fields highlighted
  → Delete → confirm dialog (typed confirm for high-value) → soft-delete + Undo → back to list
Back → list (state restored)
```

**D7 · States**
| State | Presentation |
|---|---|
| Loading | `AmdsSkeletonDetail` — header bars + 2–3 field-group card skeletons; tabs shown but disabled. |
| Empty | Individual empty fields → "—". A tab with no content → "No documents" / "No comments yet" + add affordance. |
| Success | Full record; actions enabled per state/permission; audit trail visible. |
| Error | Full-screen "Couldn't load this {entity}" + Retry. Deleted/invalid id → "This item no longer exists" + "Back to list". Action failure → Snackbar error + Retry, record unchanged. |
| Offline | Banner; cached record shown "as of HH:MM"; actions that mutate → queued with "Pending" chip; edits autosave locally. Conflict on reconnect → resolution UI (form-design-system §4.3). |

**D8 · Accessibility** — title = `heading 1` + screen name; section/tab labels = headings; each field row = one stop ("Department, Procurement"); status announced with meaning ("Status: Active"); action buttons name the record where ambiguous ("Approve request PR-88120"); tabs = `tab`/`tabpanel` with position + count, arrow-key nav; destructive dialog default focus = safe choice; copyable values (IDs) exposed. Sensitive fields gated + access logged; masked with reveal where permitted.

**D9 · Animations** — enter from list: shared-axis X 250ms (or shared-element on the title/avatar). Header collapse on scroll tied to offset. Tab switch: indicator slide 200ms + panel crossfade/slide. Field value change after edit: brief `primaryContainer` highlight 400ms fade. Action → optimistic state change animates (chip color crossfade, button → done). Reduced-motion: crossfades only.

**D10 · Dark Mode** — header may use a subtle `surfaceVariant` or tinted band (not a bright gradient); status chips translucent container + -100 text; field cards `#0F172A` + `#1E293B` border; audit trail timeline line `#334155`.

**D11 · Tablet Adaptation** — Portrait: max-640 centered; two-column field groups where labels are short. Landscape: **two-pane** — the list stays visible left, this detail fills the right pane; or a three-pane (list · detail · related/comments). Header actions may move to a right-aligned toolbar. Breadcrumb shows hierarchy for tree data.

**D12 · Developer Notes** — a generic `RecordDetailConfig` (header fields, action set with permission predicates, tab/section defs, related lists, destructive action) drives it. Optimistic concurrency: capture a version/etag on load; on save conflict → 409 → resolution dialog, never silent overwrite. Field-level history for audited entities. Route: `/{type}/{id}?tab=`. Prefetch the record from the list row's data for instant header paint, then hydrate.

**D13 · UX Best Practices** — identity confirmable instantly. Group fields; consistent empty treatment. Actions match state + permissions (explain disabled). Keep back predictable (→ list, preserved). Show who changed what, when. Edits go through the form engine, not inline (except low-risk status/assignee with immediate save + Undo). Confirm + prefer soft-delete.

---

### Archetype E — Form / CRUD

**Used by:** User Create, User Edit, Create Form, Edit Form, Edit Profile, Change Password (also Archetype A styling), Contact Support.

**E1 · Purpose** — create or edit a record accurately, quickly, and without losing work.

**E2 · User Goal** — "Enter/change this data correctly and submit with confidence."

**E3 · Layout Structure**
```
[ Top bar: X (cancel, dirty-guard) · "New {entity}" / "Edit {entity}" · Save (trailing, primary) ]
[ Stepper ]                               multi-step only
[ scroll, single column, 16 margin ]
   ── Section: {group} ──                 overline header + optional one-line description
   [ field ]  label / input / helper|error   (space.5 between fields, space.8 between sections)
   [ field ]
   [ Attachments ]
   [ Banner: submit error summary ]        on failed submit
[ sticky footer (long forms): Secondary "Save draft" · Primary "Submit" ]
```

**E4 · Component Hierarchy**
```
AmdsScaffold(showBottomNav: false, stickyFooter?)
└─ AppBar(leading: Close, trailing: AmdsButton "Save")
└─ AmdsStepper?
└─ Form > SingleChildScroll > Column
   ├─ AmdsSectionHeader
   ├─ AmdsTextField / AmdsPasswordField / AmdsDropdown / AmdsRadioGroup / AmdsCheckbox
   │  / AmdsSwitchTile / AmdsDatePickerField / AmdsTimePickerField / AmdsEntityPicker / AmdsAttachmentField
   ├─ AmdsBanner(errorSummary)?
   └─ …
└─ StickyFooter(AmdsButton secondary "Save draft", AmdsButton primary "Submit", loading)
Discard → AmdsDialog.confirm ("Discard changes?")
Success → pop + AmdsSnackbar
```

**E5 · Information Architecture** — one column, one idea per field; ≤7 fields per section; most-known/important first; dependent fields after their trigger; destructive last. Labels always visible. Requirements in helper text **before** errors. Group with `overline` headers + Cards/dividers, consistently.

**E6 · User Flow**
```
Open (Create: prefilled context — reporter=me, date=now, site=my site) / (Edit: populated)
  → fill / change fields → validate on blur (format, required-if-touched)
  → attach files (per-file progress + remove)
  → autosave draft on pause (debounce 2–3s) + on background
  → tap Save/Submit → validate all + cross-field + server rules
      ├─ success → pop → land on new/updated record (or list with row highlighted) + Snackbar; clear draft
      ├─ validation error → scroll to + focus first error + top summary Banner; keep all input
      ├─ system/network error → keep form, Banner + Retry, preserve input
      └─ conflict (edit) → resolution dialog
  → multi-step: validate per step, Back never loses data, Review step before submit
Cancel/back on dirty → "Discard changes?" (Discard danger / Keep editing)
```

**E7 · States**
| State | Presentation |
|---|---|
| Loading | Edit: field skeletons while the record loads. Async field validation: helper spinner + "Checking…". Submit: footer/AppBar button spinner, inputs locked. |
| Empty | Create: empty fields with helpful defaults + placeholders; optional "Load from template". |
| Success | Pop + Snackbar "Saved"/"Created" with "View"/"Undo"; significant submits (sent for approval) → success screen/Banner with next steps. |
| Error | Inline per field (specific, actionable, announced, clears on fix). Failed submit → focus first error + navigable summary. System error → non-destructive, Retry, trace id. Attachment fail → per-file retry, don't fail the form. |
| Offline | Banner "changes will be saved when you reconnect"; queue the submit; record shows "Pending". Draft always saved locally. |

**E8 · Accessibility** — every input visibly labelled + associated; required in label text not asterisk/color alone; correct `keyboardType`/`inputmode`; errors anchored + announced (polite on blur, assertive summary on failed submit) + clear-on-fix; radio/checkbox groups have a legend; focus moves to first error on submit; Submit reachable without dismissing the keyboard (sticky footer / "Done"); autofill + password managers not blocked; 200% text no clip; reduced-motion: no shake; RTL mirrored; ≥44dp targets, ≥8dp apart.

**E9 · Animations** — section/field enter: subtle fade. Error: message slide-down+fade 150ms `decelerate` + border crossfade. Field with async check: inline spinner. Submit: button label→spinner. Success: pop with shared-axis + Snackbar slide-up. Stepper advance: content shared-axis X 250ms, step indicator fills. Reduced-motion: crossfade + no shake (border + text + `dangerContainer` flash 150ms).

**E10 · Dark Mode** — field fill `surfaceVariant` `#1E293B`, border `#334155`, focus green-400 2px, error red-400; section cards `#0F172A`; helper `#94A3B8`; disabled `#334155` text; date/time pickers use the dark calendar/dial.

**E11 · Tablet Adaptation** — single column, `maxWidth 640`, centered. Landscape: optional left **anchor nav** listing sections (jump-to). Naturally-paired short fields (city/postcode, start/end) may sit side by side. Modal create → centered dialog ≤720 on tablet; multi-step flow can become an inline two-pane (steps left, form right).

**E12 · Developer Notes** — a **schema-driven form engine**: `FormSchema = List<FormFieldSpec{ key, type, label, helper, validators, visibleWhen, options, async }>` (+ `List<FormStep>` for multi-step with a review step). Validation timing per form-design-system §6 (live only for password strength / availability / counters / masking; blur for the field; submit for all + server). Autosave draft: encrypted local + server sync so it survives device loss; "Resume draft?" on return; expire per policy. Optimistic concurrency on edit (etag). Never clear the form on error.

**E13 · UX Best Practices** — ask only what's needed now; defer optional. Smart defaults + prefill from context. Requirements as a live checklist. Validate on blur not per keystroke. Preserve input on every failure. Confirm discard on dirty cancel. `X` = cancel, trailing = commit — never swap. Success is never a dead end (offer next actions). Multi-step: review before submit, back without loss.

---

### Archetype F — Confirmation / Decision

**Used by:** Delete Confirmation, logout, destructive bulk actions, Approval Approve/Reject/Return, "Discard changes?", session-expiry, irreversible toggles.

**F1 · Purpose** — force a deliberate decision on an action that is hard to reverse or has real consequences.

**F2 · User Goal** — "Understand what will happen and choose safely."

**F3 · Layout Structure** — `AmdsDialog` (centered, `elevation5`, scrim, max-width 560, padding `space.6`): optional hero icon (danger/warning tint) · title (states the outcome) · body (states consequence + reversibility) · optional required input (comment / typed name) · actions right-aligned: Cancel (text, **default focus** for destructive) · Confirm (filled; `danger` for destructive). For approvals: a **sticky decision bar** on the detail screen (Reject `danger` outline · Return secondary · Approve primary) opening a confirm dialog that embeds the required comment.

**F4 · Component Hierarchy**
```
showAmdsDialog(
  DialogHeroIcon?,
  Text(title, headingMedium),
  Text(body, bodyMedium),
  AmdsTextField(comment)?  |  AmdsTextField(typeToConfirm)?,
  actions: [ AmdsButton.text("Cancel"), AmdsButton.filled("Delete", danger, loading) ],
)
// or AmdsDecisionBar(onApprove, onReturn, onReject) pinned bottom of Detail
```

**F5 · Information Architecture** — title = the question/outcome ("Delete work order WO-1043?"). Body = consequence + reversibility + side effects ("This can't be undone. 3 linked tasks will be unassigned."). Buttons = verbs matching the title ("Delete"/"Keep"), never "Yes"/"No". Max 2 actions (3 only with a clear tertiary like "Learn more"). High-value objects: require typing the name/ID.

**F6 · User Flow**
```
Trigger (row swipe / detail overflow / bulk bar / decision bar)
  → dialog opens, focus moves in (Cancel focused for destructive), focus trapped
  → Cancel / scrim tap (non-destructive only) / back / Esc → dismiss, focus returns to trigger
  → Confirm → (if required) validate comment/typed-name → button → loading → both actions disabled
      ├─ success → dismiss → soft-delete + Undo Snackbar (5–7s) / navigate / update
      ├─ conflict (already actioned) → replace dialog with an info state, then dismiss
      └─ error → keep dialog, inline error + Retry
Bulk: confirm shows exact count → progress → result summary (successes/failures + retry failures)
```

**F7 · States**
| State | Presentation |
|---|---|
| Loading | Confirm button spinner; both actions disabled; scrim stays. |
| Empty | N/A. |
| Success | Dismiss + Undo Snackbar (soft-delete) / navigate / in-place update + count change. |
| Error | Keep dialog open; inline error under the content; "Try again"; trace id. Bulk partial → result list with per-item status. |
| Offline | Action queues; dialog dismisses with "Will {action} when you're back online"; item gets a "Pending" chip. Destructive irreversible actions blocked offline with a message. |

**F8 · Accessibility** — `role=alertdialog`; focus moves to the dialog (title or safe action) on open; **focus trapped**; Esc / system back = Cancel; scrim tap = Cancel for non-destructive only; on close focus returns to the trigger; content fully announced; destructive default focus = Cancel; required comment field labelled + errors announced; button names are explicit verbs. Never stack dialogs.

**F9 · Animations** — scrim fade 150ms, then container fade + scale 0.95→1, 200ms `decelerate` (50ms offset after scrim). Exit reverse, `accelerate` 150ms. Confirm loading: label→spinner. Undo Snackbar: slide-up. Reduced-motion: fade + 8dp translate only, 150ms.

**F10 · Dark Mode** — dialog surface `#1E293B` (raised) + strong near-black shadow + scrim `rgba(2,6,23,0.64)`; hero icon uses -400 hue; destructive Confirm red-400 fill + slate-950 label.

**F11 · Tablet Adaptation** — stays a centered dialog (≤560), never full-screen. On landscape it appears over the two-pane layout. Decision bar for approvals spans the detail pane only.

**F12 · Developer Notes** — `AmdsDialog.destructive(title, body, confirmLabel, requireTypedConfirm?, requireComment?)`. Prefer **soft delete / archive + Undo Snackbar** over hard delete + pre-confirm where the domain allows. Bulk: idempotent per-item calls, atomic where the backend supports it, else ordered with a result summary. Re-check permission + record state server-side (handle 403/409). Undo window 5–7s (extend when a screen reader / switch access is active — or require manual dismiss).

**F13 · UX Best Practices** — never one-tap destructive. Title states the object + outcome. Explain reversibility + side effects. Verb buttons. Cancel is the safe default. Prefer Undo to friction. Confirm bulk with the exact count. Don't block on a dialog for non-critical info (use a Snackbar/Banner).

---

### Archetype G — Settings List

**Used by:** General Settings, Theme Settings, Notification Settings, Security Settings (and the Settings hub, Help Center hub).

**G1 · Purpose** — configure app/account behavior via grouped rows; changes apply immediately.

**G2 · User Goal** — "Find the setting and change it, seeing the effect right away."

**G3 · Layout Structure**
```
[ App Bar: title · back · (search for large settings) ]
[ scroll, grouped list ]
   ── {Group} ──                          overline section header
   ┌────────────────────────────────────┐
   │ Label                    [ Switch ] │  toggle row — applies instantly
   │ description (caption)               │
   ├────────────────────────────────────┤
   │ Label            Current value  ›   │  value row → picker (sheet/dialog)
   ├────────────────────────────────────┤
   │ Label                           ›   │  navigation row → sub-screen
   ├────────────────────────────────────┤
   │ Danger action                       │  destructive row (last), danger-styled
   └────────────────────────────────────┘
   [ App version · build (copyable) ]     (About/General footer)
```

**G4 · Component Hierarchy**
```
AmdsScaffold
└─ AppBar
└─ ListView > [ AmdsSectionHeader, AmdsSettingRow(...) ... ]
   AmdsSettingRow variants: .toggle(AmdsSwitch) | .value(text + chevron → AmdsBottomSheet/Dialog picker)
                           | .navigation(chevron → route) | .action(danger?)
Theme Settings: AmdsSegmented(System/Light/Dark) + text-size slider + density Segmented (live preview)
```

**G5 · Information Architecture** — group logically, most-used groups first; show current values inline; toggles = instant, no global Save; dangerous actions last, `danger`-styled, double-confirmed, consequences explained. Reflect OS-level settings (Dynamic Type, reduce motion) rather than fighting them. Large settings → in-screen search.

**G6 · User Flow**
```
Open → list renders instantly (state from persisted prefs / providers)
  → toggle → applies immediately, visible effect, async ones show inline spinner + revert-on-fail
  → value row → picker sheet/dialog → choose → row updates → applied
  → navigation row → sub-settings screen (e.g. Notification Settings) → back
  → Theme row → System/Light/Dark → root crossfade 200ms
  → danger action (Sign out / Clear data / Delete account) → confirm dialog (typed confirm for account deletion) → execute
Back → Settings hub / previous
```

**G7 · States**
| State | Presentation |
|---|---|
| Loading | Rows render immediately from local state; a remote-backed setting shows a brief inline spinner while syncing. |
| Empty | N/A (settings always exist). A section gated by capability is hidden. |
| Success | Toggle/value reflects new state; optional Snackbar for non-visible effects ("Notifications updated"). |
| Error | Async setting fails → revert the control + Snackbar "Couldn't update — try again". Never leave the UI showing a state that didn't persist. |
| Offline | Local settings (theme, text size) work fully. Server-backed settings (notification channels) → disabled with "Reconnect to change" or queued with a pending indicator. |

**G8 · Accessibility** — each row's whole area is the target (≥48dp); toggle rows expose `role=switch` + state + the label; value rows announce label + current value ("Language, English"); section headers = headings; destructive rows clearly labelled; picker sheets trap focus + return it; theme/text-size changes announced; respect and surface OS accessibility settings.

**G9 · Animations** — switch thumb slide 200ms `standard` + track crossfade; value picker = bottom sheet slide-up 250ms; theme change = root crossfade 200ms (instant under reduced-motion); row press `surfaceVariant`. Sub-screen navigation: shared-axis X.

**G10 · Dark Mode** — this is where the Theme setting lives; the toggle previews live. Rows `#0F172A` surface, divider `#1E293B`, switch on-track green-400. Text-size and density preview components re-render on change.

**G11 · Tablet Adaptation** — Landscape: **two-pane** — settings groups list on the left (≤320), the selected group's detail on the right (master-detail settings). Portrait: single list, max-640 centered. The Theme preview can show a live component sample panel on tablet.

**G12 · Developer Notes** — `themeControllerProvider { ThemeMode, textScale (clamped 0.85–2.0), density }` persisted (`shared_preferences`/DataStore/UserDefaults); `notificationSettingsController` (server-backed, optimistic + revert). One `AmdsSettingRow` widget with a `type` enum. Clamp `MediaQuery.textScaler` app-wide. Sign-out clears secure storage + biometric + caches then routes to Login. Account deletion = a guarded flow, not a single dialog.

**G13 · UX Best Practices** — instant apply, no Save button for toggles. Show current values. Group logically. Positive labels ("Email me updates"). Dangerous actions last + explained + double-confirmed. Live theme preview. Don't duplicate an OS setting — defer to it. Searchable when long.

---

### Archetype H — Content / Article

**Used by:** FAQ, About Application, Contact Support (info portion), Approval History (timeline), Report Detail (narrative portion), onboarding article content, licenses.

**H1 · Purpose** — present readable information (help articles, legal, changelog, a chronological history) clearly, with clear next actions.

**H2 · User Goal** — "Read/scan this and, if needed, do the follow-up action (contact, acknowledge, navigate)."

**H3 · Layout Structure**
```
[ App Bar: back · title · (share for articles) ]
[ Search field ]                          FAQ / Help only
[ scroll, reading column max 640, 16 margin ]
   [ category tiles / topic list ]         hub level
   ── Accordions (FAQ) ──                  header 56 + expand_more; body bodyLarge, 60–70 char lines
   OR article body: heading / paragraph / list / code / callout / image
   OR timeline: vertical AmdsStepper — event · actor · timestamp · note   (Approval History)
   [ "Was this helpful?" 👍👎 ]              articles
   [ "Still need help?" card → Contact Support ]
   [ About: app icon · name · version/build (copyable) · legal links · licenses · acknowledgements ]
```

**H4 · Component Hierarchy**
```
AmdsScaffold
└─ AppBar(actions: Share?)
└─ AmdsSearchField?                        (FAQ)
└─ ListView / Column:
   ├─ topic AmdsListTileX / tiles         (hub)
   ├─ AmdsAccordion × n                    (FAQ)
   ├─ RichText body blocks                 (article)
   ├─ AmdsStepper(vertical, read-only)     (history / approval chain)
   ├─ FeedbackRow(👍 / 👎)
   └─ AmdsCard("Still need help?" → Contact) / AboutBlock
```

**H5 · Information Architecture** — search first, browse second (FAQ). Articles: one topic, scannable headings, short lines, steps as ordered lists. History: reverse-chronological (or chronological chain), each entry = actor + action + timestamp + optional note/comment. About: version/build always visible + copyable (support needs it); legal links consistent.

**H6 · User Flow**
```
Open hub → search or pick a topic → article/accordion expands
  → "Was this helpful?" → thumbs (optional short comment on 👎)
  → "Still need help?" → Contact Support (form: category, message, attach; sends app version + device + [consent] logs)
  → About → tap a legal link → readable in-app view / browser (consistent)
  → History → scroll the timeline; tap an entry → the related record/version
Back → previous
```

**H7 · States**
| State | Presentation |
|---|---|
| Loading | Article/FAQ: text-line skeletons. History: 3–4 timeline row skeletons. |
| Empty | FAQ no results → echo query + "Contact support". History: "No activity yet". |
| Success | Content rendered; expanded accordion state kept for the session. |
| Error | "Couldn't load help content" + Retry; offline → cached top articles. Contact Support send failure → keep the draft, Retry, trace id. |
| Offline | Show cached articles + "Offline — showing saved help". Contact Support → queue the message, send on reconnect, tell the user. |

**H8 · Accessibility** — headings marked so users navigate by heading; accordions = `button` + `aria-expanded`, content region associated; reading order logical; links descriptive (not "click here"); "Was this helpful?" buttons labelled with context; timeline entries = grouped stops ("S. Lee approved, 9:12 AM, note: verified PO"); version/build copyable and announced; article text respects Dynamic Type; adequate line height + length.

**H9 · Animations** — accordion expand: height + content fade 250ms `standard`, chevron rotates 180°. Article enter: fade. Timeline: entries fade+riseY staggered on first paint. "Helpful" tap: subtle check. Reduced-motion: instant expand, no stagger.

**H10 · Dark Mode** — reading surface `#0F172A`; code blocks `#1E293B`; callouts use translucent semantic containers + -100 text; timeline line `#334155`, node fills by state (-400 hues); illustrations/diagrams use dark variants.

**H11 · Tablet Adaptation** — reading column stays ≤640–720 (don't run lines edge to edge). Landscape FAQ: **two-pane** — topic/search list left, article right. About: centered card. History: wider timeline with the note column expanded.

**H12 · Developer Notes** — articles from a CMS/markdown store, cached for offline; render via a sanitized markdown widget (`flutter_markdown` / equivalent) with AMDS text styles. `showLicensePage()` (Flutter) / `OSSLicensesMenuActivity` / `PackagesLicense` for licenses. Contact Support bundles `AppConfig.version`, build, device model, OS — and, only with an explicit consent toggle, recent logs; state exactly what's sent. `share_plus` for article share (deep link).

**H13 · UX Best Practices** — search-first help. Scannable articles, short lines, real steps. "Was this helpful?" feedback loop. Contact options show expected response time. Say exactly what diagnostic data is sent, gate logs behind consent. Version/build copyable. Legal links open consistently. No marketing in About.

---

## 5. Cross-platform implementation recommendations

One authoritative section. Per-screen "Developer Notes" only add specifics.

### 5.1 Foundational mapping

| Concern | Jetpack Compose | Flutter | React Native |
|---|---|---|---|
| Theme entry | `AmdsTheme { }` (Theme.kt) — `MaterialTheme` + `AmdsTheme.colors/spacing/radius/elevation` via CompositionLocals | `MaterialApp.router(theme: AmdsTheme.light, darkTheme: AmdsTheme.dark, themeMode)` + `AmdsThemeExt` ThemeExtension; `context.amds.colors.*` | `<ThemeProvider>` context wrapping `amdsLight`/`amdsDark` (theme.ts); `useTheme()` |
| Semantic tokens | `AmdsTheme.colors.primary`, `AmdsSpacing`, `AmdsRadius` | `context.amds.colors.primary`, `AmdsSpacing.md` | `theme.colors.primary`, `theme.spacing[4]` |
| Dark mode | `isSystemInDarkTheme()` + manual override store; status/nav bar icon contrast per theme | `themeMode` from `themeControllerProvider`; `SystemUiOverlayStyle`; `flutter/services` | `useColorScheme()` + override store; `react-native-edge-to-edge`, `StatusBar` |
| Screen scaffold | `Scaffold(topBar, bottomBar, floatingActionButton, content)` + `WindowInsets`, `enableEdgeToEdge()` | `AmdsScaffold` wrapping `Scaffold` + `SafeArea` + `MediaQuery` insets | `SafeAreaView` + a `Screen` component; `react-native-safe-area-context` |
| Collapsing app bar | `TopAppBar` + `TopAppBarScrollBehavior` (`enterAlways` / `exitUntilCollapsed`) | `SliverAppBar(pinned, expandedHeight)` in `CustomScrollView` | Reanimated animated header from scroll offset |
| Lists (virtualized) | `LazyColumn` + Paging 3 (`collectAsLazyPagingItems`) | `ListView.builder` / `infinite_scroll_pagination` `PagedListView` | `FlatList` / `FlashList` + `onEndReached` |
| Grid (KPIs) | `LazyVerticalGrid(GridCells.Fixed/Adaptive)` | `SliverGrid` / `GridView` / `Wrap` | `FlatList numColumns` / flex-wrap |
| Pull to refresh | `PullToRefreshBox` (M3) | `RefreshIndicator` | `RefreshControl` |
| Forms | Compose state hoisting + a form holder; `TextField` + `supportingText`/`isError` | `Form` + `TextFormField` or the schema-driven `FormEngine` | `react-hook-form` / Formik + controlled inputs |
| Navigation | `androidx.navigation:navigation-compose` (typed routes, `navDeepLink`) + `NavigationSuiteScaffold` for adaptive | `go_router` (`ShellRoute` for adaptive nav, `redirect` guards, deep links) | `@react-navigation/native` (stack + tabs/drawer) + `linking` config |
| Adaptive nav | `NavigationSuiteScaffold` / `WindowSizeClass` → BottomBar / Rail / PermanentDrawer | `LayoutBuilder` + `AmdsAdaptiveNavigation` (bottom bar ↔ `NavigationRail` ↔ `NavigationDrawer`) | `useWindowDimensions` → conditional `BottomTabs` / custom rail / `Drawer` |
| State mgmt | ViewModel + `StateFlow` (`collectAsStateWithLifecycle`) | Riverpod 2 (`@riverpod` AsyncNotifier) | Zustand / Redux Toolkit + React Query for server state |
| Server cache | Repository + `Store`/room + `Flow` | Repository + `dio` + a cache; or `riverpod` + manual `staleTime` | **React Query** (`staleTime`, optimistic `onMutate`, rollback) |
| Models | `data class` + kotlinx.serialization | `freezed` + `json_serializable` | `zod` schemas / TS types + `superjson` |
| Charts | Vico / Compose canvas | `fl_chart` (wrapped by `AmdsChartCard`) | `victory-native` / `react-native-svg` |
| Icons | Material Symbols (font) + custom `ImageVector` | `material_symbols_icons` + `flutter_svg` | `react-native-vector-icons` (MaterialSymbols) + `react-native-svg` |
| Animations | `AnimatedVisibility`, `animate*AsState`, `updateTransition`, `AnimatedContent`; `MaterialMotion` (shared axis) | implicit `Animated*` widgets, `AnimatedSwitcher`, `Hero`, `flutter_animate`; `animations` pkg for shared axis | `react-native-reanimated` 3 + `Layout` animations; `react-native-shared-element` |
| Reduced motion | `LocalAccessibilityManager` / check `Settings.Global.ANIMATOR_DURATION_SCALE` | `MediaQuery.disableAnimations` / `MediaQuery.of(context).accessibleNavigation` | `AccessibilityInfo.isReduceMotionEnabled()` |
| A11y | `Modifier.semantics { }`, `contentDescription`, `stateDescription`, `heading()`, `liveRegion`, `customActions` | `Semantics`, `MergeSemantics`, `ExcludeSemantics`, `SemanticsService.announce`, `CustomSemanticsAction` | `accessibilityRole/Label/State/Hint`, `accessibilityLiveRegion`, `AccessibilityInfo.announceForAccessibility`, `accessibilityActions` |
| Dynamic Type | `sp` units; test font scale | `MediaQuery.textScaler`; `Text` auto-scales; clamp globally | `allowFontScaling` (default true); test scales |
| Golden/snapshot | Paparazzi / Roborazzi | `alchemist` / `golden_toolkit` | `@storybook` + Chromatic / `react-native-snapshot` |
| Deep links | `navDeepLink { uriPattern = ... }` | `go_router` route paths + `GoRouter.optionURLReflectsImperativeAPIs` | `linking: { prefixes, config }` |
| Secure storage | `EncryptedSharedPreferences` / DataStore + Keystore | `flutter_secure_storage` | `react-native-keychain` / `expo-secure-store` |

### 5.2 Archetype → implementation notes

| Archetype | Compose | Flutter | React Native |
|---|---|---|---|
| **A Focused Task** | Own `composable` routes outside the nav-suite scaffold; `Scaffold` no bottom bar; `imePadding()` + `verticalScroll`; autofill via `Modifier.semantics { }` + `AutofillNode` | `GoRoute`s outside `ShellRoute`; `AmdsScaffold(showBottomNav:false)`; `resizeToAvoidBottomInset`; `AutofillGroup` + `autofillHints` | screens in the `AuthStack` (no tabs); `KeyboardAvoidingView`; `textContentType` (iOS) / `autoComplete` (Android) |
| **B Dashboard** | `LazyColumn` of block composables; each block a `collectAsState` slice; Paging not needed | `CustomScrollView` slivers; one controller, `BlockState<T>` per block; `fl_chart` off-thread data via `compute` | `ScrollView` (blocks are cheap) or `SectionList`; React Query per block; memoize chart data |
| **C List** | `LazyColumn` + `items(pagingItems)`; `SwipeToDismissBox`; selection via a `Set<Id>` in VM; `NavigationSuiteScaffold` detail pane on expanded | `PagedListView` + `Dismissible`; `RecordListConfig`; two-pane via `Row` on `>=905`; keep-alive provider | `FlashList` + `estimatedItemSize`; `Swipeable` (gesture-handler); selection in store; `useWindowDimensions` for split view |
| **D Detail** | `SliverAppBar` collapsing + `HorizontalPager` for tabs; shared-element via `MaterialContainerTransform` | `NestedScrollView`/slivers + `TabBar`/`TabBarView`; `RecordDetailConfig`; `Hero` on title/avatar | animated header + `react-native-tab-view`; `shared-element` transition; config object |
| **E Form** | Hoisted state holder; `TextField(isError, supportingText)`; `bringIntoViewRequester` to scroll to first error; `rememberSaveable` for draft | `FormEngine(FormSchema)`; `Form` + `GlobalKey`; `Scrollable.ensureVisible` for first error; autosave via a debounced provider | `react-hook-form` resolver (zod); `scrollTo` first error via refs; draft in `AsyncStorage` debounced |
| **F Confirmation** | `AlertDialog` (M3) / `BasicAlertDialog`; `DisposableEffect` to move focus; trap via `Dialog` | `showDialog` → `AmdsDialog`; `autofocus` on Cancel; `WillPopScope`/`PopScope` for back = cancel | a themed `Modal` (`transparent`, `animationType`); `AccessibilityInfo.setAccessibilityFocus`; hardware back handler |
| **G Settings** | `LazyColumn` of `ListItem` rows; `Switch`; `ModalBottomSheet` pickers; DataStore-backed VM | `ListView` of `AmdsSettingRow`; `showModalBottomSheet` pickers; `shared_preferences`/Isar; master-detail via `Row` on landscape | `SectionList`; `Switch`; `@gorhom/bottom-sheet` pickers; `MMKV`/`AsyncStorage` |
| **H Content** | `LazyColumn` + rich text / `AnnotatedString`; `AnimatedVisibility` accordions | `flutter_markdown` + AMDS styles; `ExpansionPanelList`/custom `AmdsAccordion`; `showLicensePage()` | `react-native-render-html` / markdown lib; `LayoutAnimation` accordions; `expo-application` for version |

### 5.3 Shared engineering standards

- **Feature-first folders** (project-structure); screens are stateless, a ViewModel/Notifier/hook owns state; repositories behind interfaces; mock impls ship by default.
- **No hardcoded** colors, dimensions, or user-facing strings in feature code (lint-enforced). Tokens + i18n only.
- **i18n from day one**: `stringResource` / ARB + `intl` / `i18next`; ICU plurals; templated messages, no concatenation; ~+35% expansion headroom; RTL.
- **Formatters** central and locale + timezone aware (relative time from server clock).
- **`Result`/`Either` + typed `Failure`** union → UI maps to the standard state widgets.
- **Deep links** for every list & detail; synthesize back stacks.
- **Analytics**: one module, events defined with the feature.
- **Testing**: golden (component × variant × state × light/dark × 1.0/2.0 text), widget/unit per feature, integration for the top 3 flows, automated a11y guideline checks in CI.

---

## 6. Universal checklists (apply to every screen)

### 6.1 States checklist
- [ ] **Loading** — skeleton matching final layout (no shift) OR inline spinner for <1s waits; `aria-busy`
- [ ] **Empty** — distinct first-use vs no-results vs no-permission; icon + title + body + primary action; never a dead end
- [ ] **Success** — result visible; confirmation proportional (inline check / Snackbar / success screen)
- [ ] **Error** — specific + actionable message; Retry; input/context preserved; trace id for support; distinguishes "your fault" (validation) from "our fault" (system)
- [ ] **Offline** — persistent Banner; cached data with "as of HH:MM"; mutations queue with a Pending indicator; irreversible actions blocked with a message

### 6.2 Accessibility checklist (WCAG 2.2 AA — accessibility)
- [ ] Text contrast ≥4.5:1 (large/UI ≥3:1); focus ring ≥3:1, ≥2px, not obscured by sticky chrome or keyboard
- [ ] Every interactive element ≥44×44dp, ≥8dp apart
- [ ] Every control exposes role + name + state + value; icons labelled by action not glyph
- [ ] Reading order = visual order; headings marked; landmarks labelled
- [ ] Errors identified in text + suggested fix + announced; focus moves to first error
- [ ] Forms: visible associated labels; required in text; correct keyboard; paste/password-managers/autofill not blocked
- [ ] No color-only meaning; no keyboard/switch traps (except intentional modal traps, Esc-able)
- [ ] Reduced-motion path; nothing flashes >3×/sec
- [ ] Works at 200% text + Bold Text; RTL mirrored
- [ ] Verified with TalkBack + VoiceOver on the primary task

### 6.3 Dark mode checklist (dark-mode)
- [ ] No pure black bg / no pure white large surface; surfaces use the step model
- [ ] All text pairs re-verified on their actual dark surface
- [ ] Focus ring visible (green-400); status colors meaning-preserving (icon + label + color)
- [ ] Overlays read as raised (surface step + strong shadow)
- [ ] Images/avatars/logos/illustrations have dark treatment (ring/scrim/variant)
- [ ] Charts legible (gridlines, axes, lightened series, tooltips); skeletons use dark tokens
- [ ] Splash + first frame honor theme; system bars match

### 6.4 Tablet checklist
- [ ] Nav adapts: bottom bar → rail (portrait) → persistent drawer (landscape)
- [ ] Content max-width enforced (640/1040); not edge-to-edge text
- [ ] List → list-detail two-pane on landscape where applicable; deep links open both panes
- [ ] Forms single-column max-640 centered; long forms get section anchor-nav on landscape
- [ ] Dashboards: KPI grid 2→4→6-up; right rail for priorities/activity on landscape
- [ ] Modals: full-screen sheet (phone) → centered dialog ≤560/720 (tablet)
- [ ] Safe areas / cutouts respected in both orientations

### 6.5 Definition of done (per screen)
- [ ] Matches the archetype + this screen's deltas; all 13 dimensions addressed
- [ ] All 5 states implemented; all listed edge cases handled or ticketed
- [ ] Light + dark verified; contrast holds
- [ ] Motion uses tokens; reduced-motion verified
- [ ] a11y: automated checks pass + manual SR walkthrough completes the task
- [ ] 200% text + RTL pass
- [ ] Adaptive at phone / tablet-portrait / tablet-landscape
- [ ] Deep link resolves with correct back stack
- [ ] Implemented on the target platform(s); golden + widget tests; analytics events fire
- [ ] No hardcoded colors / dimensions / strings
