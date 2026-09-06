# Foundations Overview — Interaction, States & Responsive Behavior

> Part of the [Alan Mobile Design System](README.md).
> The individual foundation pages ([color](color-system.md) · [typography](typography.md) · [spacing](spacing.md) · [radius](radius.md) · [elevation](elevation.md) · [iconography](iconography.md) · [motion](motion.md)) define the values. This page defines **how they combine** — interaction principles, the universal component-state model, and responsive behavior.

---

## 1. Interaction principles

1. **Feedback within 100ms.** Every tap acknowledges immediately (ripple / highlight / scale). The UI is never ahead of or behind the finger.
2. **One primary action per screen.** Secondary actions are visually lighter; tertiary actions go to an overflow.
3. **Direct manipulation where natural** — swipe a row to action it, drag a sheet between detents, pull to refresh — always with a non-gesture equivalent (a button, a menu item) for accessibility.
4. **Actions on the up-event.** Dragging off a control before release cancels it (WCAG 2.5.2).
5. **Confirm the irreversible, undo the reversible.** Destructive actions get a confirmation dialog; reversible ones get an Undo snackbar (5–7s) instead of a pre-confirm where feasible.
6. **Preserve the user's work.** Never clear a form on error; autosave long forms; keep list filters / scroll / selection across navigation within a session.
7. **Optimistic UI where safe.** Apply the change locally, reconcile with the server, roll back visibly on failure.
8. **Predictable navigation.** "Back" reverses the last navigation; switching primary destinations is not "back"; modals close, they don't go back. See [navigation-patterns.md](navigation-patterns.md).
9. **Respect the platform.** iOS edge-swipe back, Android predictive back, platform haptics, platform date/time pickers.
10. **Calm motion.** Functional, short (100–400ms), few things moving at once; every animation has a reduced-motion equivalent. See [motion.md](motion.md).

## 2. Universal component-state model

Every interactive component supports this set. Individual component specs ([component-library](../component-library/README.md)) only note deviations.

| State | Visual | Tokens / spec |
|---|---|---|
| **Enabled** (default) | resting appearance | per component |
| **Hover** (pointer devices only) | 8% overlay of `onSurface` | `opacity.hover` |
| **Focus-visible** | 2px `borderFocus` ring, 2px offset, not clipped | `borderFocus`, `borderWidth.focus` |
| **Pressed** | 12% overlay **or** 0.96 scale-down, 100ms `standard` | `opacity.pressed` |
| **Selected / checked / active** | `primaryContainer` tint or filled variant + state announced | `primaryContainer` |
| **Disabled** | 38% opacity, no pointer events, **not focusable** | `opacity.disabled` |
| **Loading / busy** | spinner replaces leading content; `aria-busy`; non-interactive | — |
| **Error** | 2px `error` outline + message + ⚠ icon; announced | `error` |
| **Indeterminate** (checkbox, progress) | dash / sliding bar | — |
| **Dragged** | 16% overlay + lift (`elevation4` or scale 1.03) | `opacity.dragged` |

**Rules:** state is always conveyed by more than color (icon, text, shape, position). Disabled elements are not tab stops. `focus-visible` never hides behind sticky chrome or the keyboard (WCAG 2.4.11).

## 3. Screen-level state model

Every data screen renders exactly one of these ([screen-library/00-framework §6.1](../screen-library/00-framework.md), [starter-template/error-handling.md](../starter-template/error-handling-and-logging.md)):

| State | Presentation |
|---|---|
| **Loading** | skeleton matching the final layout (no shift), or an inline spinner for <1s waits; `aria-busy` |
| **Empty** | distinct first-use vs no-results vs no-permission; icon + title + body + primary action; never a dead end |
| **Success / Data** | content; `stale` variant shows an "as of HH:MM" marker when served from cache |
| **Error** | specific + actionable message; Retry; input/context preserved; copyable `traceId`; distinguishes user error (validation) from system error |
| **Offline** | persistent banner; cached data with "as of HH:MM"; mutations queue with a Pending marker; irreversible actions blocked with a message |

Additional utility states — **No Permission · Session Expired · Maintenance** — are specified as full screens in [screen-library/11-utility-states.md](../screen-library/11-utility-states.md).

## 4. Density

| Mode | List row | Cell padding | Text | Use |
|---|---|---|---|---|
| **Comfortable** (default) | 56 / 72 / 88 | `space.3`×`space.4` | `bodyMedium` | general use |
| **Compact** | 44 / 56 | `space.2`×`space.3` | `bodySmall` | power users, dense data apps (ERP, monitoring), large screens |

Density is a user setting ([screen-library/09-settings §9.2](../screen-library/09-settings.md)) and/or a per-view toggle; persist it.

## 5. Responsive behavior (summary)

Full breakpoints and grid: [spacing.md §4](spacing.md).

| Tier | Nav | Content | Modals |
|---|---|---|---|
| Small / Standard / Large phone (320–430) | Bottom navigation | 1 column, 16 margin | Full-screen sheet |
| Small tablet (≥600, portrait) | Navigation rail | 1 col max-640 centered; two-pane list/detail where useful; 8-col grid | Centered dialog ≤560 |
| Large tablet (≥905, landscape) | Persistent drawer | 12-col grid, 32 margin; two/three-pane; breadcrumbs | Centered dialog / inline panel |

**Adaptive rules**
- Design at 375 first; scale up.
- Navigation morphs: bottom bar → rail → drawer.
- A phone list that pushes to a detail becomes a two-pane split on large tablet; deep links open both panes.
- Forms stay single-column, max 640, centered; long forms get a section anchor-nav on landscape.
- Dashboards: KPI grid 2-up → 4-up → 6-up; a right rail holds priorities/activity on landscape.
- Respect safe areas and cutouts in every orientation; preserve state across rotation and fold.

## 6. Do / Don't

**Do** — acknowledge every tap in 100ms; implement all component + screen states; convey state with more than color; keep focus visible and unobstructed; preserve user work; morph navigation by breakpoint.
**Don't** — leave a state unhandled; disable a control without explanation; block a gesture with no alternative; clear a form on error; run text edge-to-edge on tablets; use motion as the only signal.
