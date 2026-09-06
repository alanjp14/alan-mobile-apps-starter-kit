# Navigation Patterns

> Part of the [Alan Mobile Design System](README.md). Bottom Navigation · Top App Bar · Navigation Drawer · Navigation Rail · Tabs · Breadcrumb · Back Navigation · Deep Links. Routing **architecture** is in [`../starter-template/navigation.md`](../starter-template/navigation.md).

---

## 1. Navigation model

AMDS uses a **hub-and-spoke** model with up to two levels of primary navigation:

```
App
├── Section A  (bottom nav / rail / drawer destination)
│   ├── List screen        ← spoke
│   │   └── Detail screen  ← deeper spoke (push)
│   │       └── Edit modal
│   └── Tabs (peer views of Section A)
├── Section B
├── Section C
└── (More) → overflow destinations, Settings, Profile, Help
```

Rules:

- **3–5 primary destinations.** More → group into "More".
- Primary destinations are **peers** — switching between them never means "going back".
- Going *deeper* (list → detail) uses **push** (horizontal slide); the system Back / gesture returns.
- Lateral movement within a screen's content uses **Tabs**, not primary nav.
- Never more than **2 levels** of persistent chrome (bottom nav + one app-bar tab row). Third level = in-content segmented control or filter.

## 2. Adaptive pattern

| Tier | Primary nav | Secondary |
|---|---|---|
| Phone (all) | **Bottom Navigation** (3–5 items) | App-bar tabs, segmented controls |
| Tablet Portrait (≥600) | **Navigation Rail** (left, icons + short labels, 80dp wide) | Two-pane list/detail |
| Tablet Landscape (≥905) | **Persistent Navigation Drawer** (left, 280dp, always open) | Two/three-pane, breadcrumbs |
| Foldable (unfolded) | Treat as tablet portrait/landscape by width | Preserve state across fold |

Transitions between tiers preserve the selected destination and scroll position.

---

## 3. Bottom Navigation

**Purpose** — top-level switching between 3–5 primary destinations on phones.

**Spec**

| Property | Value |
|---|---|
| Height | 64 + bottom safe area |
| Background | `surface`, `elevation2` (or 1px top `border` when flat) |
| Item | icon 24 (outline inactive / filled active) + label (`labelSmall`, always shown) |
| Active color | `primary` (icon + label), optional `primaryContainer` pill behind icon (Material 3 style) |
| Inactive color | `onSurfaceVariant` |
| Item min target | 48 tall × (screen/count) wide, ≥48 |
| Badge | dot or count, top-right of icon |

**Behavior**

- Tap active item again → scroll that section to top; second tap → pop to that section's root.
- Selection change: crossfade icon fill + label color (150ms); optional pill scale-in (200ms `standard`).
- Hide on scroll is **not** default (enterprise users value predictability); allow per-app opt-in with slide-down 200ms `accelerate`.
- Never more than 5 items. With exactly 3, center them with generous spacing.

**Accessibility** — `tablist`-like or platform bottom-nav semantics; each item exposes selected state and position ("Tab 2 of 4, Assets, selected"); labels always visible (no icon-only); 48dp targets; reachable via D-pad/switch in order.

**Usage rules** — put the most-used destination first; Dashboard/Home typically leftmost. Labels are nouns, 1 word ideally, ≤12 chars. Don't put actions (e.g. "Add") in bottom nav — that's the FAB. Keep the item set identical across the whole app session.

---

## 4. Top App Bar

**Purpose** — identify the current screen, host screen-level actions and navigation affordances.

**Variants**

| Variant | Height | Use |
|---|---|---|
| Small (default) | 56 | Most screens. Title left-aligned, up to 2 actions + overflow |
| Center-aligned | 56 | Top-level home screens, brand presence |
| Large / Medium | 112 / 96 collapsing to 56 | Section landing pages; title `headingLarge` collapses to `titleLarge` on scroll |
| Contextual (selection) | 56 | Appears over the normal bar when items are selected: close-selection `X`, "3 selected", bulk actions |
| Search bar | 56 | App bar *is* the search field (see Search Bar) |

**Anatomy** — leading (menu / back / close) · title (+ optional subtitle `caption`) · trailing actions (max 2 icon buttons on phone) · overflow `more_vert` · optional bottom row (tabs / filter chips) · optional progress line (2dp, indeterminate) at the very bottom edge.

**Scroll behavior** — resting: flat (no shadow). On scroll-under: elevate to `elevation2` (`scrolledUnderElevation`), 150ms. Large app bar: title and height interpolate with scroll offset; pin the collapsed bar.

**Accessibility** — the title is a `heading` and the screen's accessible name; back button labeled "Back" (or "Back to [previous]"); actions individually labeled; contextual selection bar announces the count on change; focus starts at the leading control or the title.

**Usage rules** — title = current screen, not the app name (except home). Leading slot: **back** on pushed screens, **menu** only on drawer-based top-level screens, **close** on modals. Don't overload — 2 actions max, rest in overflow, ordered by frequency. Keep the same actions in the same place across similar screens.

---

## 5. Navigation Drawer

**Purpose** — house many destinations, account switching, and secondary links when 5 bottom-nav slots aren't enough — or as the primary nav on tablet landscape.

**Variants** — **Modal** (phone/tablet portrait: slides over content with scrim, `elevation4`, 280–320 wide, dismiss on scrim tap / swipe / back) · **Standard/Persistent** (tablet landscape: always visible, 280 wide, part of layout, no scrim).

**Anatomy** — header (account: avatar + name + email + switcher chevron, or app/workspace name) · primary destination list (icon + label, active = `primaryContainer` pill full-width, radius `full` or `md`) · dividers grouping sections (`overline` group labels) · footer (Settings, Help, Sign out; app version).

**Behavior** — open: slide-in 250ms `decelerate` + scrim fade; close: 200ms `accelerate`. Selecting a destination closes the modal drawer and navigates. Preserve scroll within the drawer.

**Accessibility** — modal drawer = `dialog` with focus trap; first focus on the first destination or close control; Esc/back closes and returns focus to the menu button; destinations expose selected state; persistent drawer is a `navigation` landmark, not a dialog.

**Usage rules** — don't duplicate bottom-nav items in a drawer as the primary pattern; use *either* bottom nav (≤5) *or* drawer (>5), plus "More". Group logically; put destructive/rare items (Sign out) in the footer. Account switching lives in the drawer header, not scattered.

---

## 6. Tabs

**Purpose** — switch between **peer views of the same subject** (e.g. an asset's Overview / History / Documents / Comments).

**Variants** — **Fixed** (2–4 tabs, equal width, fill the bar) · **Scrollable** (5+ tabs or long labels, left-aligned, scroll horizontally, next tab peeks) · **Primary** (under app bar, `titleMedium`, 2dp `primary` indicator) · **Secondary** (nested, within content, lighter weight).

**Spec** — height 48; label `titleMedium`; active `primary` + indicator; inactive `onSurfaceVariant`; indicator slides between tabs 200ms `standard`; optional leading icon (top or inline); optional count badge.

**Behavior** — swipe horizontally between tab panels (with the indicator tracking the drag); tapping a scrollable tab scrolls it toward center; state (scroll position, filters) is retained per tab.

**Accessibility** — `tablist` / `tab` / `tabpanel`; `aria-selected`; arrow keys move between tabs, Tab key moves into the panel; each tab labeled with position and count if present; swipe gestures have a non-gesture equivalent (tapping the tab).

**Usage rules** — tabs never change what "back" means. Don't nest more than one level of tabs. Don't use tabs for sequential steps (use a Stepper) or for filtering a list (use Chips/Segmented). Keep tab labels parallel in form (all nouns). Preserve the selected tab when returning to the screen within a session.

---

## 7. Breadcrumb

**Purpose** — show location within a deep hierarchy and allow jumping to an ancestor. **Tablet/large screens and hierarchical data (asset trees, org units, folders) only** — not standard on phones.

**Spec** — horizontal, `bodySmall`, items separated by `chevron_right` (`textTertiary`); ancestors are links (`textLink`), current is plain (`textPrimary`, not a link); overflow: collapse middle to `…` menu when width-constrained ("Root / … / Parent / Current").

**Accessibility** — wrap in `nav` labeled "Breadcrumb"; ordered list; current item `aria-current="page"`; the `…` is a real menu button listing collapsed ancestors.

**Usage rules** — max ~4 visible levels; always keep first (root) and last (current). On phones, replace with a single "← Parent name" back affordance in the app bar. Don't use breadcrumbs as the primary nav.

---

## 8. Back Navigation

**Principles**

- **Back always means "reverse the last navigation."** It is temporal, not hierarchical — except when arriving via deep link (see below).
- Every pushed screen has a visible **back** affordance (app bar leading `arrow_back`, RTL-mirrored) *and* honors the Android system back button/gesture and the iOS swipe-from-edge / back button.
- **Modals** use `close` (`X`), not back-arrow, and dismiss on system back / swipe-down — with an unsaved-changes guard.
- **Up vs Back:** AMDS collapses them. When a deep link lands the user mid-hierarchy, back should first walk *up* the logical hierarchy to the section root, then exit — synthesize the back stack on deep-link entry.

**Unsaved changes** — system back / close on a dirty form → confirmation Dialog ("Discard changes?" / "Discard" `danger` / "Keep editing"). Never lose data silently.

**Exit** — back from a top-level (bottom-nav root) screen: Android → move task to background (double-back-to-exit toast is discouraged; only for full-screen immersive contexts). iOS has no app-exit gesture; the leftmost tab is the "home base".

**Accessibility** — back control labeled; predictive-back (Android 14+) supported; focus returns to the element that triggered the forward navigation.

---

## 9. Deep Link Structure

### 9.1 URI scheme

```
[app-scheme]://<app>/<section>/<resource>/<id>?<params>
https://<app>.[COMPANY_NAME].example/<section>/<resource>/<id>   (App Links / Universal Links)
```

- `<app>` — product slug: `hris`, `k3`, `assets`, `erp`, `crm`, `inventory`, `noc`.
- `<section>` — a primary destination: `dashboard`, `list`, `approvals`, `profile`, `settings`.
- `<resource>` / `<id>` — the entity: `asset/AST-10293`, `incident/INC-2025-0442`, `request/PR-88120`.
- Query params — filters, tab, source: `?tab=history&from=notification`.

### 9.2 Canonical routes (template)

| Route | Screen | Notes |
|---|---|---|
| `/<app>` | Splash → resolve auth → Dashboard | |
| `/<app>/dashboard` | Dashboard | |
| `/<app>/<resource>` | List View | supports `?filter=`, `?q=`, `?sort=` |
| `/<app>/<resource>/<id>` | Detail View | synthesize back stack → List → Dashboard |
| `/<app>/<resource>/<id>?tab=<t>` | Detail, specific tab | |
| `/<app>/<resource>/new` | CRUD Form (create) | requires auth + permission |
| `/<app>/<resource>/<id>/edit` | CRUD Form (edit) | |
| `/<app>/approvals` | Approval queue | |
| `/<app>/approvals/<id>` | Approval detail | may deep-link from email/push |
| `/<app>/notifications` | Notifications | |
| `/<app>/profile` · `/settings` · `/help` | respective screens | |

### 9.3 Rules

- **Auth gate:** unauthenticated deep link → Login, then continue to the target (store the pending intent). Session expiry mid-flow → re-auth → resume.
- **Permission gate:** no access to the resource → a clear "You don't have access" screen with a request-access / contact action, not a generic error.
- **Not found / stale:** deleted or invalid `id` → "This item no longer exists" empty state with a link to the list.
- **Back stack synthesis:** entering at `/asset/123` builds `[Dashboard, Assets list, Asset 123]` so Back is sensible.
- **Attribution:** carry `?from=push|email|share|qr` for analytics and to tailor the entry (e.g. highlight the relevant section).
- **State in URL, not secrets:** filters and tabs yes; tokens, PII, or IDs that are sensitive → never in query strings (see security rules).
- **Every list and detail screen is addressable.** New features must define their routes at design time (part of the screen template spec).
- **Web ↔ app parity:** the `https://` form opens the app when installed (App Links / Universal Links verified) and a functional web page otherwise.
