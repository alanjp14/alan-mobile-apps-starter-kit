# Elevation & Shadow

> Part of the [Alan Mobile Design System](README.md) · Foundations.
> Tokens: [`design-tokens/shadows.json`](../../design-tokens/shadows.json).

---

Elevation communicates **z-order and interactivity**, not decoration. Five levels. Shadows are subtle — no heavy drop shadows anywhere.

## 1. Levels

| Level | Token | Light shadow | Android dp | Use |
|---|---|---|---|---|
| 1 | `elevation1` | `0 1px 2px rgba(15,23,42,.06)` | 1 | Resting card, list item raised on scroll, text field |
| 2 | `elevation2` | `0 2px 4px -1px rgba(15,23,42,.08), 0 1px 2px rgba(15,23,42,.04)` | 3 | App bar on scroll-under, bottom nav, hovered/pressed card, chip |
| 3 | `elevation3` | `0 4px 8px -2px rgba(15,23,42,.10), 0 2px 4px -1px rgba(15,23,42,.05)` | 6 | FAB resting, dropdown menu, popover, snackbar |
| 4 | `elevation4` | `0 12px 20px -4px rgba(15,23,42,.12), 0 4px 8px -2px rgba(15,23,42,.06)` | 12 | Bottom sheet, navigation drawer, FAB pressed |
| 5 | `elevation5` | `0 24px 40px -8px rgba(15,23,42,.16), 0 8px 16px -4px rgba(15,23,42,.08)` | 24 | Modal dialog, full-screen overlay panel |

## 2. Rules

- **Default surface state is flat with a 1px `border`**, not a shadow. Shadows appear on **raise** (scroll-under, hover, drag) and on **overlays**.
- Never stack more than two elevation levels in one visual context.
- **Dark mode** replaces most shadows with **surface lightening** (slate-900 → slate-800) plus a stronger near-black shadow for true overlays. See [dark-mode.md](dark-mode.md).
- Shadow color is always the neutral-900 hue at low alpha — never a colored shadow.
- **Pressed state lowers** perceived elevation: AMDS uses a `0.96` scale-down (not a raise) for buttons/FAB; cards drop from `elevation1` to flat.

## 3. Do / Don't

**Do** — keep resting surfaces flat + bordered; reserve elevation for overlays and interaction; lighten surfaces in dark mode.
**Don't** — use elevation as decoration; stack 3+ levels; use colored or oversized shadows; raise elements on press.
