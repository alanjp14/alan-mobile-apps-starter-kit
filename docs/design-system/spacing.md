# Spacing, Grid & Layout

> Part of the [Alan Mobile Design System](README.md) · Foundations.
> Tokens: [`design-tokens/spacing.json`](../../design-tokens/spacing.json).

---

## 1. Spacing scale (4 pt base)

| Token | Value | Typical use |
|---|---|---|
| `space.0` | 0 | Reset |
| `space.1` | 4 | Icon↔label gap, chip inner, hairline inset |
| `space.2` | 8 | Tight stack, between related controls, badge padding |
| `space.3` | 12 | Compact list row padding, field inner vertical |
| `space.4` | 16 | **Default.** Screen edge margin, card padding, list row padding |
| `space.5` | 20 | Between form fields |
| `space.6` | 24 | Section spacing, card↔card gap, dialog padding |
| `space.8` | 32 | Between major sections, above a primary CTA |
| `space.10` | 40 | Empty-state vertical padding |
| `space.12` | 48 | Large section break, generous top inset under an app bar |
| `space.16` | 64 | Splash / onboarding rhythm, oversized hero spacing |

Scale values: **4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64**.

## 2. Rules

- **Everything is a multiple of 4.** No 5, 6, 10, 15, 18 — ever.
- **Screen horizontal margin:** 16 on phones · 24 on tablet portrait · 32 on tablet landscape.
- **Vertical rhythm:** stack spacing follows an 8-based sub-scale (8 / 16 / 24 / 32); 4 and 12 are for intra-component detail only.
- **Touch spacing:** ≥8 between adjacent independent targets; if targets are <44dp visually, pad the hit area so centers are ≥44dp apart (see [accessibility.md](accessibility.md)).
- **Optical adjustments** are allowed at the icon/glyph level (−1/−2 nudge) but **never** at the layout level.
- **Nesting:** each container level reduces padding by one step, min `space.3`. Screen 16 → card 16 → inner list 12.

## 3. Layout regions (phone)

```
┌─────────────────────────────┐  ← status bar (safe-area top)
│  App bar               56dp │
├─────────────────────────────┤
│  [ contextual bar ]         │  optional: tabs · filter chips · search · stepper
├─────────────────────────────┤
│ 16 ┌───────────────────┐ 16 │  ← content margin 16
│    │  content column   │    │
│    │  (scrolls)        │    │
│    └───────────────────┘    │
├─────────────────────────────┤
│  [ sticky footer / CTA ]    │  optional
├─────────────────────────────┤
│  Bottom nav            64dp  │
└─────────────────────────────┘  ← home indicator (safe-area bottom)
```

Section gap `space.8` · header→content `space.3` · between fields `space.5` · card padding `space.4` · list row min-height 56 / 72 / 88.

## 4. Responsive grid & breakpoints

| Tier | Min width | Columns | Margin | Gutter | Notes |
|---|---|---|---|---|---|
| **Phone Small** | 320 | 4 | 16 | 16 | iPhone SE, small Android. Single column always. |
| **Phone Medium** | 375 | 4 | 16 | 16 | Baseline design target |
| **Phone Large** | 430 | 4 | 16 | 16 | Pro Max / large Android; larger tap zones, same layout |
| **Small Tablet** (portrait) | 600 | 8 | 24 | 24 | Two-pane where useful; max content width 640 |
| **Large Tablet** (landscape) | 905 | 12 | 32 | 24 | Persistent nav rail/drawer, two/three-pane; max content width 1040 |
| Desktop (webview, rare) | 1240 | 12 | 32 | 24 | Centered max-width 1200 |

### Adaptive rules

- **Design at 375 first.** Scale up, not down.
- Content column max width: 640 on small tablet, 720 for reading views — text lines never run edge to edge on tablets.
- **Navigation adapts:** bottom nav (phone) → nav rail (small tablet) → persistent drawer (large tablet). See [navigation-patterns.md](navigation-patterns.md).
- **List → list/detail:** a phone list that pushes to a detail screen becomes a two-pane split on large tablet.
- **Modals:** full-screen sheet on phone → centered dialog (max 560, or 720 for a form flow) on tablet.
- Respect **safe areas** and **display cutouts** on every tier; never place interactive elements under a notch or home indicator.
- **Orientation:** phones lock portrait by default unless content benefits (charts, scanner, media). Tablets support both; preserve state across rotation and fold.

## 5. Do / Don't

**Do** — use the scale tokens; keep screen margins per tier; give text rows `min-height`; collapse two-pane layouts gracefully.
**Don't** — use off-scale values; run text edge-to-edge on tablets; place controls under cutouts; hard-code phone dimensions.
