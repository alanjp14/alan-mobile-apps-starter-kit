# Motion

> Part of the [Alan Mobile Design System](README.md) · Foundations. Motion is functional — it orients the user, expresses hierarchy and causality, and masks latency; never decoration. Durations: **100 · 150 · 200 · 250 · 300 · 400 ms**; nothing exceeds 400ms except ambient/looping indicators.
>
> **Making it smooth on device (60/120fps, per platform):** [`../starter-template/motion-implementation.md`](../starter-template/motion-implementation.md).

---

## 1. Motion principles

1. **Purposeful** — every animation answers "what changed, where did it come from, where did it go?"
2. **Responsive** — feedback within 100ms of input; the UI never feels ahead of or behind the finger.
3. **Calm** — subtle, short, few things moving at once. Enterprise users repeat tasks hundreds of times a day.
4. **Coherent** — related elements move together; a tapped item leads the transition it triggers.
5. **Accessible** — every animation has a reduced-motion equivalent; nothing conveys meaning through motion alone; no flashing >3×/sec.
6. **Performant** — animate `transform` and `opacity` only; 60fps floor, 120fps target on capable displays; no jank on mid-tier Android.

## 2. Duration tokens

| Token | ms | Use |
|---|---|---|
| `instant` | 100 | State changes on small elements: checkbox, switch thumb start, ripple onset, hover, button press color |
| `fast` | 150 | Icon crossfade, tab label color, small fades, snackbar/ tooltip fade, selection tint |
| `base` | 200 | **Default.** Most enter/exit, button press scale, FAB show/hide, dropdown open, dialog scale |
| `moderate` | 250 | Bottom sheet settle, drawer open, expansion panel, shared-axis page transition |
| `slow` | 300 | Large surface enter (full-screen modal), complex layout change, onboarding page |
| `slower` | 400 | Hero / shared-element transitions, first-run celebratory moments, large list reflow |

**Duration by distance/size:** small element + short distance → `instant`/`fast`. Full-screen surface → `slow`. Scale duration with the travel, don't use one value for everything.

**Asymmetry:** exits are faster than enters (enter `base` 200 → exit `fast` 150; enter `slow` 300 → exit `base` 200). Things should get out of the way quickly.

## 3. Easing tokens

| Token | Cubic-bezier | Character | Use |
|---|---|---|---|
| `standard` | `(0.2, 0, 0, 1)` | Quick start, gentle stop | Most transitions, elements moving within the screen |
| `decelerate` | `(0, 0, 0, 1)` | Enters fast, eases out | Elements **entering** the screen (from off-screen) |
| `accelerate` | `(0.3, 0, 1, 1)` | Eases in, exits fast | Elements **leaving** the screen permanently |
| `spring` | `(0.34, 1.56, 0.64, 1)` | Slight overshoot | Playful confirmations, FAB, toggle thumb, "pop" affordances — use sparingly |
| linear | — | Constant | Only looping indicators (spinners, shimmer, progress) |

Native springs (iOS `spring`, Compose `spring`, Flutter `SpringSimulation`) are preferred where the platform supports them; tune to `dampingRatio ≈ 0.8`, `stiffness ≈ 380` for the `spring` feel, critically damped (`1.0`) for `standard`-like moves.

## 4. Pattern catalog

### 4.1 Page transition (push / pop)

- **Pattern:** shared-axis X (horizontal). Incoming enters from +30% width → 0, `decelerate`, opacity 0→1. Outgoing goes 0 → −25% width, `accelerate`, opacity 1→0 (parallax — outgoing moves less).
- **Duration:** 250ms (`moderate`). Pop mirrors, 200ms.
- **iOS:** native interactive edge-swipe pop; content follows the finger, completes or springs back on release.
- **Android:** predictive back — outgoing screen scales to 0.95 + slides as the gesture progresses.
- **Reduced motion:** crossfade only, 150ms, no translation.

### 4.2 Modal / full-screen sheet transition

- Enter: slide up from +100% height → 0, `decelerate`, 300ms (`slow`); scrim opacity 0→`scrim`, 150ms.
- Exit: slide down, `accelerate`, 200ms; scrim fades 150ms.
- Tablet (centered dialog): scale 0.92→1 + opacity, `decelerate`, 200ms.
- Reduced motion: fade + 8dp translate, 150ms.

### 4.3 Bottom sheet transition

- Present: slide up to peek/half detent, `standard`, 250ms; scrim (modal) fades in 150ms.
- Drag: 1:1 with finger; rubber-band resistance past max (`translation * 0.35`).
- Release: animate to nearest detent, `spring` (damping 0.85), ~250–300ms.
- Dismiss: slide down `accelerate` 200ms; if flung, carry velocity into the exit.
- Reduced motion: fade + minimal slide, 150ms; snap to detents without spring.

### 4.4 Button interaction

- Press-in: scale 1→0.96 (`instant` 100ms, `standard`) + background → pressed color. Ripple (Android) / highlight (iOS) from touch point.
- Release: scale back to 1, `spring` subtle (damping 0.9), 150ms.
- Disabled→enabled: opacity 0.38→1, 150ms.
- Loading: label fades to spinner (150ms crossfade), width holds.
- Reduced motion: no scale; color change only.

### 4.5 Card interaction

- Tap (interactive card): scale 1→0.98 + `surfaceVariant` overlay, `instant`.
- Hover (pointer): elevation 1→2, translateY 0→−2, `fast`.
- Enter in a list (staggered): opacity 0→1 + translateY 8→0, `decelerate` 200ms, **stagger 30ms** per item, cap the stagger at ~8 items then batch.
- Drag-reorder: lift = scale 1.03 + `elevation4` + 150ms; others reflow with `standard` 200ms; drop settles with `spring`.
- Reduced motion: opacity only, no translate, no stagger (all at once).

### 4.6 Loading animation

- Circular spinner: 360°/900ms, linear, indeterminate arc sweeps 25%→75% length.
- Linear indeterminate: segment travels full width /1000ms, `standard` in-out, gap then repeat.
- Skeleton shimmer: gradient sweep left→right, 1200ms, linear, infinite; 400ms gap between sweeps.
- Reduced motion: spinner → slow opacity pulse (0.4↔1, 1000ms); shimmer → static block.

### 4.7 Success animation

- Inline (e.g. after save): checkmark draws in a circle — circle scales 0→1 (`spring`, 250ms), check strokes on (`standard`, 200ms, path-length). Optional single haptic (light).
- Full-screen (rare — completed submission/onboarding): same, larger, + subtle radial fade behind; auto-advance or "Done" after ~1.2s.
- Never loop. Never longer than ~1.5s. No confetti in enterprise contexts (opt-in only for consumer/startup apps, one-time milestones).
- Reduced motion: static filled check + text, brief opacity fade-in.

### 4.8 Error animation

- Field error: the message slides down + fades in (`fast` 150ms, `decelerate`); the field border color crossfades to `danger`.
- Shake (form-level rejection, e.g. wrong password): horizontal translate ±6dp, 3 cycles, 300ms total, `standard`. Use rarely — once per failed submit, not per field.
- Optional haptic: single "error" pattern (notification-error).
- Reduced motion: **no shake**; border + message + a brief background flash of `dangerContainer` (150ms) instead.

### 4.9 Skeleton loading

See [component library](../component-library/README.md) E2. Shimmer 1200ms linear infinite; content swap = 150ms crossfade with **zero layout shift** (skeleton must be pixel-accurate to final layout).

### 4.10 Micro-interactions

| Element | Motion |
|---|---|
| Checkbox check | box fill scale 0→1 (`instant`), check path draws (`fast`) |
| Switch toggle | thumb slides (`base`, `standard`), track crossfades; thumb widens on press |
| Radio select | dot scale 0→1 (`fast`, `spring`) |
| Accordion expand | height auto + content fade, `moderate` 250ms `standard`; chevron rotates 180° same duration |
| Tab indicator | slides + width-morphs between tabs, `base` `standard` |
| FAB show/hide on scroll | scale + fade, `base`; direction-aware |
| Pull-to-refresh | spinner scales/rotates with pull distance; release → `standard` |
| Badge count change | old digit up-fades out, new digit up-fades in, `fast` |
| List item removal | collapse height + fade + slide-out toward the swipe direction, `base` `accelerate` |
| Number counter (KPI) | count up from 0 (or previous) to value, `slow`, `standard`, only on first load, respect reduced motion (snap) |

## 5. Choreography rules

- **One focal point.** The user's eye should have one thing to follow per transition.
- **Lead with the trigger.** The tapped row/card owns the transition into the detail (shared element or origin-anchored scale).
- **Enter and exit together, not sequentially,** unless one *causes* the other (dialog scrim fades before the dialog scales in — 50ms offset max).
- **Stagger sparingly** (lists on first paint only, ≤8 items, 30ms).
- **Never animate on every data update** — only on user-initiated change or first appearance. A dashboard that refreshes silently doesn't re-animate its KPIs.
- **Interruptible.** If the user acts mid-animation, honor the new input immediately (animate from the current state, don't queue).
- **Consistent direction.** Forward = new content from the trailing edge; back = from the leading edge. Down = deeper/expand; up = dismiss/collapse.

## 6. Haptics (guidance)

| Event | Haptic (iOS / Android) |
|---|---|
| Toggle, selection commit | light / `CLOCK_TICK` or effect tick |
| Primary action success | success notification / medium |
| Destructive confirm executed | medium |
| Error / rejected | error notification / double tick |
| Long-press activate | medium impact |
| Reaching a scroll boundary (pull-to-refresh trigger) | light |

Haptics are **additive confirmation**, never the only feedback. Respect the system "haptics off" setting. Don't buzz on every scroll or keystroke.

## 7. Accessibility & performance requirements

- **Respect reduced motion** (`prefers-reduced-motion`, iOS "Reduce Motion", Android "Remove animations"): replace slides/scales/parallax with cross-fades ≤150ms or instant; disable auto-playing/looping decorative motion; keep essential feedback (focus, error) as non-motion cues.
- **No seizure risk:** nothing flashes more than 3 times per second; no large-area high-contrast strobing.
- **Motion is never the sole signal** for state, error, or navigation direction — pair with color, text, icon, or position change.
- **Performance budget:** transitions animate compositor-friendly properties only (`transform`, `opacity`); no animating `width`/`height`/`top`/`layout` on lists; pre-rasterize complex layers; target <8ms/frame on a 3-year-old mid-range Android.
- **Battery/thermal:** pause ambient animation when the app is backgrounded or the view is off-screen; cap frame rate on low-power mode.
- **Testing:** verify each pattern at 1× and 0.5× (slow animations, dev setting), with reduced motion on, on the lowest-tier supported device, and with a screen reader active.
