# Component Library · Design Specs

> Part of the [Component Library](README.md). ~40 components — the **design** side: Purpose · Anatomy · Variants · Sizes · States · Accessibility · Usage rules · Light/Dark.
> The **engineering** side (Properties, Compose/Flutter/RN/SwiftUI, Animation, Do/Don't) is in [api-reference.md](api-reference.md). Data components (tables, filters, pagination) are in [data-display.md](data-display.md).
> All dimensions in dp/sp. Colors are semantic tokens ([design foundations](../design-system/README.md)). Motion tokens from [motion](../design-system/motion.md).

**Universal state model** — every interactive component supports: `enabled` (default), `hover` (pointer devices only — 8% overlay of `onSurface`), `focus-visible` (2px `borderFocus` ring, 2px offset), `pressed` (12% overlay or 0.96 scale, 100ms), `disabled` (38% opacity, no pointer events, not focusable), plus component-specific `loading`, `error`, `selected`, `indeterminate`.

**Universal a11y baseline** — role exposed; accessible name from visible label or explicit label; state (`selected`, `disabled`, `expanded`, `checked`, `busy`) announced; min 44×44dp target; operable by keyboard, switch, D-pad, and screen-reader gestures; visible focus; respects reduced-motion and Dynamic Type.

---

## A. Actions

### A1 · Button

**Purpose** — trigger an operation. One **primary** button per screen/section maximum.

**Anatomy** — container (min-height, radius `md`, horizontal padding) · optional leading icon (18–20dp) · label (`label` type) · optional trailing icon · optional loading spinner (replaces leading icon).

**Variants**

| Variant | Container | Label | Border | Use |
|---|---|---|---|---|
| Primary | `primary` fill | `onPrimary` | none | The main action (Save, Submit, Continue) |
| Secondary | `surface` fill | `primary` | 1px `primary` | Alternative action next to primary |
| Tertiary / Text | transparent | `primary` | none | Low-emphasis (Cancel, Learn more), inline |
| Tonal | `primaryContainer` fill | `onPrimaryContainer` | none | Medium emphasis on busy screens |
| Destructive | `danger` fill | white | none | Delete, Reject, Remove — always paired with confirm |
| Destructive text | transparent | `danger` | none | Low-emphasis destructive in menus |

**Sizes**

| Size | Height | Padding X | Icon | Label | Use |
|---|---|---|---|---|---|
| Small | 36 | 12 | 16 | `labelSmall` | Dense toolbars, cards, table row actions |
| Medium | 44 | 16 | 20 | `label` | **Default** |
| Large | 52 | 20 | 24 | `titleMedium` | Primary CTA on forms/onboarding, full-width |

Full-width buttons: pin to bottom with `space.4` inset + safe area; label centered; used for the single primary action on a task screen.

**States** — universal set + `loading` (spinner replaces leading icon, label stays or → "Saving…", container non-interactive, `aria-busy`), `pressed` (0.96 scale + darken to `primaryPressed`, 100ms `standard`).

**Accessibility** — role `button`; name = label (icon-only not allowed for Button — use Icon Button); disabled state announced and not focusable; loading announces "busy"; hit area ≥44 even for Small (expand vertically). Destructive actions: the confirm dialog's default focus is the safe choice (Cancel).

**Usage rules** — verb-first labels ("Add asset", not "New"). No more than two buttons in a row on phone; third+ goes to overflow. Never disable the primary button silently — if blocked, show why (inline error or helper). Don't use a button for navigation between screens where a list row or link is the right pattern.

---

### A2 · Icon Button

**Purpose** — a single icon-only action, typically in app bars, list rows, toolbars.

**Variants** — Standard (transparent, `onSurfaceVariant` icon) · Filled (`primary` bg) · Tonal (`primaryContainer`) · Outlined (1px border) · Destructive (`danger` icon).

**Sizes** — Small 32 (icon 20), Medium 40 (icon 24), Large 48 (icon 24). Hit area always ≥44 regardless of visual size.

**States** — universal; pressed shows a circular ripple/overlay bounded to a 40dp circle; `selected` (toggle) → Filled/Tonal appearance + `aria-pressed=true`.

**Accessibility** — **required** `contentDescription` / `accessibilityLabel` describing the action ("More options", "Add attachment"), not the icon ("three dots"). Toggle icon buttons expose `aria-pressed` / `Switch`-like state. Provide a tooltip on long-press (Android) / hover (pointer).

**Usage rules** — max 2 icon actions in a phone app bar + 1 overflow. Never use for the primary action of a screen. Pair with a Tooltip for any non-obvious glyph.

---

### A3 · Floating Action Button (FAB)

**Purpose** — the single most important, most frequent constructive action on a screen (Add incident, New work order, Compose).

**Variants** — Regular (56, icon 24), Small (40, icon 24) for compact/tablet-rail, Extended (icon + label, height 56, dynamic width, radius `full` or `lg`), Lowered (on scroll — shrinks Extended → Regular).

**Placement** — bottom-right, `space.4` from edges, above bottom nav by `space.4`. RTL: bottom-left. Never covers content permanently — content list gets bottom padding = FAB height + 2×`space.4`.

**States** — resting `elevation3`; pressed 0.96 scale (not elevation change); scroll-down → hide with slide+fade (200ms `accelerate`); scroll-up → show (200ms `decelerate`); loading → spinner in place of icon.

**Accessibility** — role `button`; descriptive label; if it opens a speed-dial menu, `aria-expanded` + focus moves into the menu; Extended FAB label must be real text, not baked into an image.

**Usage rules** — **one FAB per screen.** Don't use a FAB for navigation, for destructive actions, or when the primary action is already obvious in the layout. On tablet landscape, the FAB may move into the nav rail as a prominent button.

---

## B. Inputs & selection

### B1 · Text Field

**Purpose** — single- or multi-line free text entry.

**Anatomy** — label (above, `label` type, `textSecondary`) · container (height 48 single-line, radius `sm`, 1px `border`, `surface` fill, padding X `space.4`) · optional leading icon/affix · input text (`bodyLarge`) · optional trailing icon (clear / action) · helper text OR error text (below, `caption`, `space.1` gap) · optional character counter (trailing, `caption`).

**Variants** — Outlined (**default**) · Filled (`surfaceVariant` bg, no border, 1px bottom border on focus) · Textarea (min-height 96, auto-grow to 5 lines then scroll) · Read-only (no border, `textSecondary`, copy affordance).

**States**

| State | Border | Label | Helper |
|---|---|---|---|
| Enabled | `border` | `textSecondary` | `textSecondary` |
| Focus | 2px `borderFocus` | `primary` | `textSecondary` |
| Filled (blurred) | `borderStrong` | `textSecondary` | `textSecondary` |
| Error | 2px `danger` | `danger` | `danger` + ⚠ icon |
| Disabled | `border` 38% | 38% | hidden |
| Loading (async validate) | `border` | `textSecondary` | spinner + "Checking…" |

**Accessibility** — visible `<label>` programmatically associated (`for`/`labelFor`/`accessibilityLabel`); placeholder is **not** a label; error text linked via `aria-describedby` / `accessibilityHint` and announced on blur/submit (`aria-live=polite`); `inputmode`/`keyboardType` set (email, number, tel, url); required fields marked in the label ("Email (required)") not by color/asterisk alone; 44dp min height; supports text selection, paste, autofill, and password managers.

**Usage rules** — label always visible (no float-only that disappears). One idea per field. Show format hints in helper text *before* the error ("DD/MM/YYYY"). Validate on blur, not per keystroke (except strength meters / availability). Preserve input on error. Group related fields; don't exceed ~7 fields per screen — paginate long forms.

---

### B2 · Password Field

**Purpose** — obscured credential entry.

**Anatomy** — Text Field + trailing **reveal toggle** (`visibility` / `visibility_off`, Icon Button 40dp) + optional strength meter (4-segment bar below, `caption` label: Weak/Fair/Good/Strong mapped to danger/warning/info/success).

**States** — inherits Text Field. Reveal toggle: `aria-pressed`, label "Show password" / "Hide password". Caps-lock warning (pointer platforms): inline helper "Caps Lock is on".

**Accessibility** — never expose the password to the a11y tree when hidden; toggle announces new state; strength meter conveyed as text, not only the bar color; disable "reveal" is not required but the field must still allow password-manager autofill; `autocomplete="current-password"` / `"new-password"`.

**Usage rules** — one password field for login; two (new + confirm) for set/reset, with inline match validation. Show requirements up front as a checklist that ticks live, not as post-submit errors. Never impose a max length below 64. Never block paste.

---

### B3 · Dropdown / Select

**Purpose** — choose one value from a known, medium-length list (5–25 options). Fewer than 5 → Radio or Segmented; more than ~25 → Searchable select / autocomplete.

**Anatomy** — trigger styled as Text Field with trailing `expand_more` · menu (`surface`, `elevation3`, radius `md`, max-height 320 then scroll) · option rows (44dp, leading check or icon, label, `bodyMedium`) · selected option marked with `check` + `primaryContainer` tint.

**Variants** — Single-select · Multi-select (checkbox rows, trigger shows "3 selected" or chips) · Searchable (filter input pinned at top of menu) · Grouped (section headers, `overline`).

**States** — closed (like Text Field states) · open (`aria-expanded=true`, trigger border `borderFocus`) · option hover/focus/selected/disabled · empty ("No matches") · loading (skeleton rows).

**Behavior** — phone: menu opens as a **bottom sheet** if options >6 or labels are long; tablet/pointer: anchored popover. Keyboard: type-ahead, arrow to move, Enter to select, Esc to close, focus returns to trigger.

**Accessibility** — role `combobox` + `listbox`; `aria-activedescendant` tracks highlighted option; selected state announced; the trigger's accessible name includes current value ("Priority, High"); multi-select announces count.

**Usage rules** — always show the current value in the trigger, never just the placeholder once chosen. Sort options logically (frequency, then alpha). Provide a clear/none option only when "no value" is valid. Don't nest dropdowns inside dropdowns.

---

### B4 · Checkbox

**Purpose** — toggle an independent boolean, or select multiple items from a list.

**Anatomy** — 20×20 box, radius `xs`, 2px border `borderStrong` (unchecked) / `primary` fill + white `check` (checked) / `primary` fill + `remove` dash (indeterminate) · label (`bodyMedium`, `space.2` gap) · optional helper (`caption`).

**States** — unchecked / checked / indeterminate / each × (enabled, focus, pressed, disabled, error `danger` border). Transition: box fill scales 0→1 (100ms `standard`), check draws (150ms).

**Accessibility** — role `checkbox`; `aria-checked` = `true|false|mixed`; label clickable and part of the 44dp target (row height 44, box vertically centered); group of checkboxes wrapped in a `group` with a legend; error state announced with message.

**Usage rules** — label describes the checked state positively ("Email me updates", not "Don't email me"). Parent/child lists use indeterminate on the parent. Single required consent checkbox ("I agree…") must be explicit, unchecked by default, with the terms as a real link. Don't use a checkbox for an instantly-applied setting — that's a Switch.

---

### B5 · Radio

**Purpose** — choose exactly one from 2–5 mutually exclusive options, all visible.

**Anatomy** — 20×20 circle, 2px border / `primary` ring + `primary` dot (10dp) when selected · label · optional description line.

**States** — unselected / selected × (enabled, focus, pressed, disabled). Selecting animates the dot scale 0→1 (150ms `standard`).

**Accessibility** — `radiogroup` with accessible name (the question); each `radio` with `aria-checked`; arrow keys move selection within the group; only the selected radio is a tab stop.

**Usage rules** — always have a default selection unless "no answer" is meaningful. Order options logically or by frequency. If options exceed 5 or need to be compact, use a Dropdown. If both options are opposite states of one thing and apply instantly, use a Switch or Segmented control.

---

### B6 · Switch

**Purpose** — toggle a single setting that **takes effect immediately** (no Save).

**Anatomy** — track 52×32 radius `full` (`borderStrong` off / `primary` on) · thumb 24 circle (`surface`, `elevation1`) sliding 20dp · optional leading label + description (label left, switch right-aligned, row 56dp).

**States** — off / on × (enabled, focus, pressed → thumb widens to 28, disabled 38%). Thumb slides 200ms `standard`; track color crossfades.

**Accessibility** — role `switch`; `aria-checked`; label associated; the whole row is the target; state change announced ("On"/"Off"); if the toggle triggers async work, show a brief inline spinner and revert with a message on failure.

**Usage rules** — never require a separate Save for a Switch. Don't use in forms for data entry (use Checkbox). Provide immediate, visible feedback of the effect. Avoid negative labels. For destructive/expensive toggles (e.g. "Delete after 30 days"), confirm before applying.

---

### B7 · Date Picker

**Purpose** — select a date or date range.

**Anatomy** — input trigger (Text Field + `calendar_today`) · calendar surface: month header with prev/next + month-year tappable (→ year grid), weekday row, day grid (44dp cells), Today marker (ring), selected (`primary` fill circle), range (endpoints filled, between `primaryContainer`) · footer: Clear · Cancel · Confirm.

**Variants** — Docked (popover, pointer/tablet) · Modal (dialog, phone) · Input-only (typed entry with mask, calendar optional) · Range · With min/max and disabled dates (e.g. no past dates for booking).

**States** — day cell: default / today / selected / in-range / disabled / focus. Invalid typed date → error helper.

**Accessibility** — grid is a `grid`/`table` with row/column semantics; each day button labeled with full date ("Monday, 3 March 2026"); disabled days `aria-disabled` with reason where possible; arrow keys navigate days, PageUp/Down months; announce selected date and range endpoints; typed input accepts locale format and pasting.

**Usage rules** — respect device locale for first-day-of-week and format. Default the view to the most likely month (today, or the current filter). For ranges, allow selecting end before start (auto-swap). Always offer a typed fallback for power users and accessibility. Show the resulting value in the trigger in a human format.

---

### B8 · Time Picker

**Purpose** — select a time of day.

**Anatomy** — Input trigger (`schedule` icon) · picker: hour/minute fields + AM/PM toggle (locale-aware 12/24h) · dial (clock face, draggable hand) OR stacked wheel selectors · footer Cancel/Confirm.

**Variants** — Dial (default, phone) · Input (two text fields + AM/PM, pointer/accessibility) · Wheel (iOS-style, cross-platform option) · With minute step (5/15/30).

**Accessibility** — provide the **Input** variant as an equivalent path — the dial alone is not sufficient; fields labeled "Hour"/"Minute"; AM/PM as a 2-option toggle with state; announce the composed time; respect 24-hour system setting.

**Usage rules** — default to a sensible time (next quarter hour, or shift start). Combine with Date Picker as a single "Date & time" control where both are needed, not two disconnected fields. Show timezone if the value crosses zones.

---

### B9 · Search Bar

**Purpose** — filter or find within a dataset or globally in the app.

**Anatomy** — container height 44–48, radius `full` or `md`, `surfaceVariant` fill · leading `search` icon · input (`bodyLarge`) · trailing `close` (clear) when non-empty · optional trailing filter/scope icon · optional voice/scan icon.

**Variants** — Persistent (in app bar, always visible) · Collapsible (icon expands to full-width, 200ms) · Docked with suggestions (results/recents dropdown or full-screen "search view") · Scoped (leading segmented scope chips).

**States** — empty (placeholder "Search assets…") · typing (debounced 250–300ms) · loading (trailing spinner) · results / no results (empty state with query echoed) · recent searches (on focus, before typing).

**Accessibility** — role `searchbox`; label "Search"; clear button labeled; results count announced via `aria-live` ("12 results"); suggestions list navigable by arrows; Esc clears/closes; the full-screen search view traps focus and returns it on dismiss.

**Usage rules** — search the thing the user is looking at (scope to current list). Preserve the query when navigating to a result and back. Show *why* zero results (spelling, filters active) and offer "Clear filters". Never auto-submit navigation on the first keystroke.

---

## C. Containment

### C1 · Card

**Purpose** — group related content and actions about a single subject into a tappable or static surface.

**Anatomy** — container (`surface`, radius `lg`, 1px `border` OR `elevation1`, padding `space.4`) · optional media (top, full-bleed, inherits top radius) · header (title `headingSmall` + optional overline + trailing action/menu) · body (`bodyMedium`, `textSecondary`) · footer (actions, metadata, chips).

**Variants** — Elevated (`elevation1`, no border) · Outlined (**default**, border, flat) · Filled (`surfaceVariant`, no border) · Interactive (entire card is one target → adds hover/press, trailing `chevron_right`).

**States** — static: none. Interactive: hover (`elevation2`), focus (ring), pressed (0.98 scale + `surfaceVariant` overlay), loading (skeleton), disabled.

**Accessibility** — an interactive card is **one** `button`/`link` with a name summarizing its content; nested actions inside an interactive card are an anti-pattern — if you need multiple actions, make the card static and expose each action separately, or move secondary actions to a menu with a distinct label.

**Usage rules** — one subject per card. Don't nest cards. Keep to 3 content rows on a phone; link to detail for more. Consistent card height within a carousel/grid — reserve space or clamp text. Corners, padding, and elevation must match across all cards in a view.

---

### C2 · KPI Card

**Purpose** — surface one key metric with trend and context on a dashboard.

**Anatomy** — small card (radius `lg`, padding `space.4`, min-height 96) · label/overline (`overline` or `caption`, `textSecondary`) · value (`displaySmall`/`headingLarge`, `textPrimary`, tabular figures) · delta chip (▲/▼ + % + period, `success`/`danger` tint) · optional sparkline (24–32dp tall, `primary` stroke) · optional leading status icon.

**Variants** — Compact (label + value only, 2-up grid) · Standard (+ delta) · Detailed (+ sparkline, comparison text "vs last month") · Alert (danger left border when metric breaches threshold).

**States** — loading (skeleton: label bar + value bar + chip) · empty ("No data yet") · error ("Couldn't load") with retry · stale (timestamp "as of 09:00" + subtle warning).

**Accessibility** — the card announces a single sentence: "Open incidents, 12, up 20% versus last week". Delta direction conveyed by icon + sign, not color alone. Sparkline has an `img` role with a text summary or is `aria-hidden` if the value+delta already convey it.

**Usage rules** — 2 KPI cards per row on phone, 4 on tablet. Round values for scannability (1.2k not 1,214) with exact on tap. Always state the period. Green ≠ automatically good — "Overtime hours ▲" is bad; tint by *sentiment*, and let each metric declare its "good direction".

---

### C3 · Chart Card

**Purpose** — house a single visualization with title, legend, and controls.

**Anatomy** — card · header (title `headingSmall` + range selector chips/segmented "7d · 30d · 90d" + overflow for export) · chart area (min-height 200, responsive) · legend (wrapping chips, tap to toggle series) · footer (source, timestamp, "View report" link).

**Chart rules** — max 5 series; categorical palette derived from tokens (see [dashboard system](../screen-library/dashboard-system.md) §5). Axis labels `caption`; gridlines `border` at low opacity; no 3D, no heavy drop shadows. Tooltips on tap-and-hold (touch) show all series at that x. Empty/loading/error states as KPI Card.

**Accessibility** — provide a **data table alternative** ("View as table" toggle) — this is the primary a11y path for charts. Chart container labeled with a summary. Don't encode meaning in color only; use direct labels, patterns, or markers. Respect reduced-motion (no draw-on animation, or instant).

**Usage rules** — one chart per card. Pick the chart type for the question (trend → line, composition → stacked bar/donut ≤4, comparison → bar, distribution → histogram). Keep the y-axis honest (start at 0 for bars). Localize number and date formats.

---

### C4 · Profile Card

**Purpose** — represent a person or entity with identity, key attributes, and quick actions.

**Anatomy** — Avatar (56–80) · name (`titleLarge`) · role/subtitle (`bodyMedium`, `textSecondary`) · status chip (Active / On leave / Offline) · attribute rows (icon + label + value: department, email, phone, location) · action row (Message, Call, View profile).

**Variants** — Header (large, top of profile screen, gradient/tinted background optional) · List item (compact, avatar 40 + name + subtitle + trailing action) · Contact (mid-size, in directory grid) · Mini (avatar + name inline, in comments/activity).

**States** — loading (avatar circle + text bars) · unknown user (initials or `person` fallback avatar) · self (edit affordance) · deactivated (muted, "Deactivated" chip).

**Accessibility** — name is the primary label; status and role announced; action buttons individually labeled with the person's name in context where ambiguous ("Call Priya Nair"); avatar is decorative (`aria-hidden`) when the name is already present.

**Usage rules** — never rely on the avatar alone to identify someone — always show the name. Initials fallback uses first + last initial, on a deterministic color from the user id. Don't expose PII (phone/email) in list contexts where it isn't needed.

---

## D. Feedback & status

### D1 · Dialog (Alert)

**Purpose** — interrupt for a decision or critical information that blocks progress.

**Anatomy** — scrim (`overlayScrim`) · container (`surface`, radius `lg`, `elevation5`, max-width 560, margin `space.6`, padding `space.6`) · optional hero icon (danger/warning tint) · title (`headingMedium`) · body (`bodyMedium`, ≤3 lines ideally) · actions (right-aligned, Cancel = text, Confirm = filled; destructive Confirm = `danger`).

**Variants** — Confirmation · Destructive confirmation (Confirm is `danger`, default focus on Cancel) · Acknowledge (single "OK") · Input dialog (one field — prefer a full screen for more).

**States** — enter: scrim fade 150ms + container fade + scale 0.95→1 (200ms `decelerate`); exit reverse 150ms `accelerate`. Loading: Confirm shows spinner, both actions disabled.

**Accessibility** — role `alertdialog`; focus moves to the dialog (title or first action) on open; **focus trapped**; Esc / back gesture = Cancel; on close focus returns to the trigger; scrim tap = Cancel only for non-destructive; content announced.

**Usage rules** — use sparingly; never for non-blocking info (use Snackbar). Title states the question/outcome ("Delete this asset?"). Buttons are verbs matching the title ("Delete" / "Keep"), never "Yes"/"No". Max two actions (three only with a clear tertiary like "Learn more"). Don't stack dialogs.

---

### D2 · Modal (full-screen / sheet)

**Purpose** — a focused sub-task or flow that needs the whole screen (create record, multi-step wizard, media viewer).

**Anatomy** — top bar (close `X` leading, title, primary action trailing e.g. "Save") · scrollable content · optional sticky footer actions · enters from bottom (phone) or center-scales (tablet, max 720 wide, radius `xl`).

**States** — dirty-check on dismiss (unsaved changes → confirm Dialog); loading; submitting (footer button spinner, inputs locked).

**Accessibility** — `dialog`, focus trap, Esc/back = close (with dirty guard); the close control is the first focusable and clearly labeled; title announced; returns focus on close.

**Usage rules** — use instead of a Dialog when there's a form or >1 decision. Leading `X` closes/cancels; trailing action commits — don't swap them. Provide a way out at every step. On tablet, a modal that's really a flow can become a two-pane inline experience instead.

---

### D3 · Bottom Sheet

**Purpose** — contextual actions or supplementary content anchored to the current screen, without full interruption.

**Variants** — **Standard/Modal** (scrim, dismissible, for action menus & pickers) · **Persistent** (no scrim, co-exists with content, e.g. map details) · **Expandable** (drag between peek / half / full detents).

**Anatomy** — container (`surface`, top corners `radius.xl`, `elevation4`) · drag handle (32×4, `borderStrong`, `space.3` top) · optional title row · content (list of actions with icons, or a form fragment, or scrollable detail) · safe-area bottom padding.

**States** — peek / half / expanded; dragging (follows finger, rubber-band at limits); settling (250ms `standard` to nearest detent); dismiss (slide down 200ms `accelerate` + scrim fade); over-content scroll hand-off (sheet expands first, then inner content scrolls).

**Accessibility** — modal sheet: `dialog` + focus trap + scrim tap / back / swipe-down to dismiss, focus returns; drag handle has an accessible "Dismiss" action and the sheet exposes expand/collapse as buttons for non-drag users; announce sheet open and its purpose.

**Usage rules** — prefer over a dropdown menu on phones for 3+ actions or long labels. Keep action sheets to ≤6 items + Cancel. Don't put a primary destructive action first. Persistent sheets must never hide critical content at peek height.

---

### D4 · Snackbar / Toast

**Purpose** — brief, non-blocking confirmation or low-priority error, with at most one action.

**Anatomy** — container (`inverseSurface` / dark pill, radius `md`, `elevation3`, `bodyMedium` text `onInverseSurface`, one action `label` in `primary`-tinted, optional leading status icon) · width: inset `space.4` on phone, max 480 · position: above bottom nav / FAB, respecting safe area.

**Variants** — Info (default) · Success (leading ✓) · Error (leading ✕, `danger` accent, longer timeout, action = "Retry") · With action ("Undo") · Multi-line (2 lines max).

**States** — enter slide-up + fade 200ms `decelerate`; auto-dismiss after 4s (info/success) / 6–10s (error or with action); swipe to dismiss; pause timer on hover/focus/screen-reader focus; queue (one at a time, newest waits).

**Accessibility** — `status` (polite) for info/success, `alert` (assertive) only for errors; the action is a real focusable button reachable before dismiss (extend timeout when a screen reader or switch access is active — ideally require manual dismiss); never put critical info only in a snackbar.

**Usage rules** — confirmations for actions whose result isn't visible ("Message sent"). Offer "Undo" for destructive actions instead of a pre-confirm dialog where feasible (5–7s window). One snackbar at a time. Not for form validation (use inline errors). Not for anything the user must read or act on — that's a Dialog or Banner.

---

### D5 · Tooltip

**Purpose** — reveal the name or brief description of a control on demand.

**Variants** — Plain (single line, `inverseSurface`, `labelSmall`, ≤ 4 words) · Rich (title + body + optional link, `surface` + `elevation2`, max 280 wide, dismissible).

**Trigger** — pointer: hover 500ms in / instant out; touch: long-press; keyboard: on focus. Rich tooltips also open on tap and stay until dismissed.

**Accessibility** — plain tooltip content mirrors/extends the control's accessible name (don't rely on it as the *only* name); `aria-describedby`; never trap focus; dismiss on Esc; must not obscure the triggering element; content also reachable another way (screen readers may not surface hover tooltips).

**Usage rules** — for icon buttons and truncated text, not for essential instructions. Never put an interactive element inside a plain tooltip. Don't use tooltips to hide validation or required info.

---

### D6 · Banner / Inline Alert

**Purpose** — a prominent, persistent, in-context message about the state of a screen or the system (offline, permission needed, sync failed, maintenance).

**Anatomy** — full-width strip or inset card, `*.container` bg + `on*Container` text, leading status icon, message (`bodyMedium`), optional 1–2 text actions, optional dismiss `X`.

**Variants** — Info · Success · Warning · Danger/Error · Neutral (system). Placement: below app bar (screen-level) or inline within a section (contextual).

**States** — static; dismissible ones remember dismissal per session/context; can host a progress state (e.g. "Syncing 3 of 10").

**Accessibility** — `region` with a label; error/warning banners `role=alert` when they appear in response to an action; actions labeled; color + icon + text always together.

**Usage rules** — use for conditions that persist (unlike Snackbar). Max one screen-level banner at a time; stack contextually if truly needed. Always offer a resolution action ("Turn on location", "Retry sync"). Don't use for marketing.

---

### D7 · Badge

**Purpose** — annotate an element with a count or status.

**Variants** — Dot (6–8dp, unread/attention, no number) · Count (pill, `labelSmall`, "9", "99+", max 3 chars) · Status label (text pill: "Draft", "Overdue", "Live") · Standalone tag/chip-badge.

**Colors** — semantic: `danger` for errors/overdue, `warning` for pending/expiring, `success` for done/active, `info` for new, `neutral` (`surfaceVariant`/`textSecondary`) for counts and generic labels.

**Placement** — top-right of the host icon/avatar, overlapping ~40%; or inline trailing a label. Min contrast 3:1 against whatever is behind it — add a 1.5px `surface` outline when overlapping imagery.

**Accessibility** — the badge value is appended to the host's accessible name ("Notifications, 5 unread"). A dot announces "new" / "unread". Status badges' text is the source of truth, color is secondary.

**Usage rules** — dot for "something changed", count for "how many". Cap at "99+". Don't badge more than a couple of elements in one view. Status badges use a controlled vocabulary per app (document it).

---

### D8 · Avatar

**Purpose** — visual identity for a person or entity.

**Sizes** — xs 24, sm 32, md 40 (default in lists), lg 56, xl 80 (profile header). Shape: circle (people), `radius.sm` square (organizations/assets/projects).

**Content priority** — photo → initials on deterministic color → `person`/entity icon fallback. Initials: 1–2 chars, `label`/`titleMedium` weight 600, always ≥3:1 on the generated background (backgrounds are chosen from a curated set of sufficiently dark tints).

**Variants** — Single · With status dot (bottom-right, `success` online / `warning` away / `textTertiary` offline, 1.5px `surface` ring) · Group/stack (up to 3 overlapping + "+4" counter chip) · With badge.

**Accessibility** — decorative when name is adjacent (`aria-hidden`); otherwise labeled with the name; status dot's meaning included in the label ("Priya Nair, online"); group stack labeled "Priya, Sam, and 4 others".

**Usage rules** — never the sole identifier. Consistent size within a list. Don't stretch non-square photos — center-crop. Respect user's choice to have no photo without visual penalty.

---

## E. Progress

### E1 · Loading Indicators

**Variants**

| Type | Use | Spec |
|---|---|---|
| Circular indeterminate | In-button, inline, small waits (<10s), unknown duration | 20–24dp, `primary` stroke 2–3dp, 360° / 900ms linear, no reduced-motion exemption but slow to a pulse if reduced-motion |
| Circular determinate | Known progress, uploads | arc fills 0→100%, % label center optional |
| Linear indeterminate | Top-of-screen / top-of-list background load | 3dp bar, `primaryContainer` track + `primary` sliding segment |
| Linear determinate | Multi-step, file transfer, form completion | 3–6dp, `primary` fill, label "3 of 5" or "45%" |
| Full-screen loader | Initial app/route load only | centered logo + subtle circular; ≤ a few seconds then → skeleton or content |
| Dots / pulse | Chat "typing", very light waits | 3 dots, staggered opacity |

**Accessibility** — `progressbar` role; determinate exposes `aria-valuenow/min/max`; indeterminate announces "Loading" once via `aria-live` (don't spam); when done, move focus or announce completion; never block the whole screen without an indicator for >400ms.

**Usage rules** — <400ms: no indicator (feels instant). 400ms–1s: inline spinner. >1s: skeleton (for content) or progress (for tasks). Always pair long waits with context ("Uploading photo 2 of 4"). Provide cancel for anything >3s that's user-initiated. Prefer optimistic UI where safe.

---

### E2 · Skeleton Loader

**Purpose** — communicate layout and reduce perceived wait while first content loads.

**Anatomy** — grey blocks (`skeletonBase`) matching the real content's shape/size: text lines (height = line-height, width varied 40–90%, last line short), avatars (circle), media (rect), buttons (pill). A subtle sheen (`skeletonSheen`) sweeps left→right, 1200ms, `standard`, infinite.

**Variants** — List skeleton (repeat row ×6–8) · Card skeleton · Detail skeleton (header + paragraphs) · Dashboard skeleton (KPI grid + chart block) · Table skeleton (header + N rows).

**States** — animating (shimmer) → content swap with a 150ms crossfade (no layout shift — skeleton must occupy the exact final dimensions). Reduced-motion: static grey blocks, no shimmer.

**Accessibility** — the skeleton container is `aria-busy=true` / announces "Loading [content type]"; individual shapes are `aria-hidden`; on load, `aria-busy=false` and, if the user was waiting, a polite "Loaded" or focus placement.

**Usage rules** — use for predictable layouts (feeds, lists, dashboards, profiles). Don't use for actions or unknown layouts (use a spinner). Never show a skeleton longer than ~3s — fall through to an error/empty state. Match the count to a typical result, not the max.

---

## F. Supplementary (in the library, briefly specced)

| Component | Purpose | Key rules |
|---|---|---|
| **Chip** | Compact entity: filter, choice, input (removable), assist, suggestion | 32dp, radius `full`/`sm`, `label` text; selected = `primaryContainer` + `check`; removable has trailing `X` (own 44dp target); groups scroll horizontally with edge fade |
| **Segmented control** | 2–5 exclusive options, all visible, instant switch | equal-width segments, selected = `surface` + `elevation1` on `surfaceVariant` track, radius `md`; `radiogroup` semantics; not for >5 or long labels |
| **Tab bar** | Switch between peer views of the same object | see [navigation patterns](../design-system/navigation-patterns.md) §Tabs |
| **List item / Row** | The atomic unit of most enterprise screens | leading (icon/avatar/checkbox) · content (overline? / title / subtitle / caption) · trailing (value / chevron / action / switch); heights 56 (1-line), 72 (2-line), 88 (3-line); entire row is one target unless it has a trailing control |
| **Accordion / Expansion panel** | Progressive disclosure of grouped content | header 56dp + `expand_more` rotates 180° (200ms); `aria-expanded`; content animates height (250ms `standard`), reduced-motion = instant; only one open at a time optional |
| **Stepper** | Show progress through a linear multi-step flow | horizontal (≤4 steps) or vertical (with content); states: complete ✓ / active (filled) / upcoming (outline) / error; current step announced ("Step 2 of 4, Details") |
| **Pagination** | Navigate paged lists/tables | see [data display](../component-library/data-display.md) §Pagination |
| **Empty state** | Communicate "nothing here" and the next step | centered: illustration/icon 40–64 · title `headingSmall` · body `bodyMedium` `textSecondary` · primary action; distinguish first-use / no-results / error / no-permission; never a dead end |
| **Divider** | Separate content groups | 1px `divider`, full-bleed or inset to content; use spacing before a divider; don't stack dividers with card borders |
| **Progressive image** | Media that loads gracefully | blur-up / dominant-color placeholder → fade in 200ms; explicit width/height to prevent shift; `alt` text or decorative |
| **Pull-to-refresh** | Manual reload of a list | spinner appears at 40dp pull, triggers at ~64dp; `standard` release; announce "Refreshing" / "Updated"; don't remove other refresh paths |
| **Scrollbar / scroll affordance** | Indicate more content | fade-in on scroll, fade-out after 1s idle; horizontal scrollers show a partial next item (peek) as the affordance |
| **Menu (overflow / context)** | Secondary actions list | anchored popover (pointer) / bottom sheet (phone, 3+ items); 44dp items, icon + label, destructive item `danger` + separated; `menu`/`menuitem` roles; Esc closes, focus returns |
| **Tooltip vs Popover vs Coachmark** | Popover = rich transient content on tap; Coachmark = one-time feature education with scrim + spotlight + "Got it" | coachmarks: max 1 per screen visit, dismissible, never block a task |

---

## G. Component checklist (use for every new component)

```
[ ] Purpose is one sentence; not a variant of an existing component
[ ] Anatomy diagram with token-named parts
[ ] Variants table (visual emphasis / context)
[ ] Sizes table (height, padding, icon, type)
[ ] States: enabled, hover, focus-visible, pressed, disabled, loading, error, selected/checked/expanded as applicable
[ ] Light + dark token mapping
[ ] Contrast: text ≥4.5:1, large/UI ≥3:1, focus ring ≥3:1
[ ] Touch target ≥44dp; ≥8dp to neighbors
[ ] Screen reader: role + name + state + value verified on iOS VoiceOver and Android TalkBack
[ ] Keyboard / switch / D-pad operable; visible focus; logical order
[ ] Reduced-motion variant defined
[ ] RTL mirrored
[ ] Dynamic Type to 200% without clipping or overlap
[ ] Motion uses tokens (100–400ms) and named easings
[ ] Implemented: Compose, SwiftUI, Flutter, RN (or platform-partial noted)
[ ] Snapshot + a11y tests
[ ] Figma component published, props match code API
[ ] Doc page in this file
```
