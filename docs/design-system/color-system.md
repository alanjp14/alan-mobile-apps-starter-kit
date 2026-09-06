# Color System

> Part of the [Alan Mobile Design System](README.md) · Foundations.
> All values are defined once in [`design-tokens/tokens.json`](../../design-tokens/tokens.json) and split into [`design-tokens/colors.json`](../../design-tokens/colors.json).
> Green + white visual direction — but **never hard-coded**: components reference semantic aliases so `[COMPANY_NAME]`'s brand can be swapped via [theme architecture](theme-architecture.md).

---

## 1. Approach — three tiers

```
primitive ramps  →  semantic aliases  →  component tokens
(raw values)        (intent, theme-aware)  (scoped overrides)
green.600           color.primary           button.primary.bg
```

Product UI references **semantic aliases only**, so the same component recolors correctly in light, dark, and future brand themes without change. Ramps are 11-step (50–950), tuned for perceptual evenness. The brand ramp is green; neutrals are a cool slate; four semantic hues (amber / red / sky, plus the green as success) cover status.

## 2. Brand ramp — Green

| Step | Hex | Primary use |
|---|---|---|
| 50 | `#F0FDF4` | Success container bg (light), subtle tint |
| 100 | `#DCFCE7` | Primary container, selected row bg (light) |
| 200 | `#BBF7D0` | Hover tint, chart fill |
| 300 | `#86EFAC` | Chart, decorative |
| 400 | `#4ADE80` | **Primary (dark theme)**, chart |
| 500 | `#22C55E` | **Secondary**, success accent |
| 600 | `#16A34A` | **Primary (light theme)** |
| 700 | `#15803D` | **Primary Dark** / primary hover / link text on white |
| 800 | `#166534` | Primary pressed |
| 900 | `#14532D` | On-primary-container text (light) |
| 950 | `#052E16` | On-primary text (dark), deepest tint |

## 3. Neutral ramp — Slate

| Step | Hex | Light role | Dark role |
|---|---|---|---|
| 0 | `#FFFFFF` | Surface | On-primary text |
| 50 | `#F8FAFC` | **Background** | Text primary |
| 100 | `#F1F5F9` | Surface variant / skeleton sheen | — |
| 200 | `#E2E8F0` | **Border** / divider | — |
| 300 | `#CBD5E1` | Border strong / disabled text | — |
| 400 | `#94A3B8` | Text tertiary / icon disabled | Text secondary |
| 500 | `#64748B` | **Text secondary** | Text tertiary |
| 600 | `#475569` | — | Border strong |
| 700 | `#334155` | — | Border / divider (dark) |
| 800 | `#1E293B` | — | Surface variant (dark) |
| 900 | `#0F172A` | **Text primary** / scrim base | Surface (dark) |
| 950 | `#020617` | — | **Background (dark)** |

## 4. Semantic hues

| Role | Light base | Light container | Dark base | Meaning |
|---|---|---|---|---|
| Success | `#16A34A` green-600 | `#F0FDF4` | `#4ADE80` | Completed, approved, healthy, online |
| Warning | `#D97706` amber-600¹ | `#FFFBEB` | `#FBBF24` | Needs attention, expiring, degraded |
| Error / Danger | `#DC2626` red-600¹ | `#FEF2F2` | `#F87171` | Error, rejected, offline, destructive |
| Info | `#0284C7` sky-600¹ | `#F0F9FF` | `#38BDF8` | Neutral notice, tip, in-progress |

¹ The `-500` steps (`#F59E0B / #EF4444 / #0EA5E9`) are retained as **accent / icon / badge fills and chart colors**, where a large filled area carries the meaning. For **text and small glyphs on white**, AMDS uses the `-600` step to clear 4.5:1. Both are in the token file (`amber.500` vs `amber.600` etc.).

## 5. Semantic aliases — the tokens you use

| Alias | Light | Dark |
|---|---|---|
| `brand` | green-600 | green-500 |
| `primary` | green-600 | green-400 |
| `primaryHover` / `primaryPressed` | green-700 / green-800 | green-300 / green-200 |
| `primaryContainer` / `onPrimaryContainer` | green-100 / green-900 | green-900 / green-100 |
| `onPrimary` | white | green-950 |
| `secondary` | green-500 | green-500 |
| `accent` | sky-600 | sky-400 |
| `background` / `onBackground` | slate-50 / slate-900 | slate-950 / slate-50 |
| `surface` / `onSurface` | white / slate-900 | slate-900 / slate-50 |
| `surfaceVariant` / `onSurfaceVariant` | slate-100 / slate-500 | slate-800 / slate-400 |
| `textPrimary` / `textSecondary` / `textTertiary` (a.k.a. Muted) | slate-900 / slate-500 / slate-400 | slate-50 / slate-400 / slate-500 |
| `textDisabled` / `disabled` | slate-300 | slate-700 |
| `textLink` | green-700 | green-400 |
| `border` / `borderStrong` / `borderFocus` | slate-200 / slate-300 / green-600 | slate-700 / slate-600 / green-400 |
| `divider` | slate-200 | slate-800 |
| `success` / `warning` / `danger` / `info` | green-600 / amber-600 / red-600 / sky-600 | green-400 / amber-400 / red-400 / sky-400 |
| `overlayScrim` | `rgba(15,23,42,0.48)` | `rgba(2,6,23,0.64)` |

> **Naming rule:** aliases are named for **intent** (`primary`, `error`, `surfaceVariant`), never for value (`green`, `blue600`, `card-shadow`); AMDS uses `danger` (Material 3 calls this `error`) and `textTertiary` (the brief's "Text Muted"). A rebrand changes values, not names.

## 6. Accessibility — contrast ratios

Measured with the WCAG 2.x relative-luminance formula. **AA** = 4.5:1 normal text / 3:1 large text (≥18.66px bold or ≥24px) and UI components. **AAA** = 7:1 normal. Full guidance: [accessibility.md](accessibility.md).

### Light theme

| Foreground | Background | Ratio | Verdict |
|---|---|---|---|
| Text primary `#0F172A` | Background `#F8FAFC` | **16.1 : 1** | AAA |
| Text primary `#0F172A` | Surface `#FFFFFF` | **17.9 : 1** | AAA |
| Text secondary `#64748B` | Surface `#FFFFFF` | **4.76 : 1** | AA (normal), not AAA |
| Text secondary `#64748B` | Background `#F8FAFC` | **4.535 : 1** | AA — borderline; do not place on `surfaceVariant` |
| Text muted `#94A3B8` | Surface `#FFFFFF` | **2.72 : 1** | Large text / decorative / disabled only |
| Link `#15803D` | Surface `#FFFFFF` | **5.01 : 1** | AA normal |
| Primary `#16A34A` | Surface `#FFFFFF` | **3.31 : 1** | UI components & large text only — **not** body text |
| White `#FFFFFF` | Primary `#16A34A` | **3.31 : 1** | AA large / UI. For button labels <18.66px use `primaryHover` `#15803D` fill → **5.01 : 1** |
| White `#FFFFFF` | Primary hover `#15803D` | **5.01 : 1** | AA normal — preferred button fill for max compliance |
| Danger text `#DC2626` | Surface `#FFFFFF` | **4.53 : 1** | AA normal |
| Warning text `#D97706` | Surface `#FFFFFF` | **4.53 : 1** | AA normal |
| Info text `#0284C7` | Surface `#FFFFFF` | **4.55 : 1** | AA normal |
| Border `#E2E8F0` | Surface `#FFFFFF` | 1.24 : 1 | Non-text; decorative dividers only |

> **Rule:** an input's resting outline may be low-contrast, but its **focus** outline must be ≥3:1 against the adjacent surface. `borderFocus` green-600 on white = 3.31:1 ✓.

### Dark theme

| Foreground | Background | Ratio | Verdict |
|---|---|---|---|
| Text primary `#F8FAFC` | Background `#020617` | **18.6 : 1** | AAA |
| Text primary `#F8FAFC` | Surface `#0F172A` | **15.9 : 1** | AAA |
| Text secondary `#94A3B8` | Surface `#0F172A` | **6.4 : 1** | AA (near AAA) |
| Text muted `#64748B` | Surface `#0F172A` | **3.5 : 1** | Large / disabled only |
| Primary `#4ADE80` | Surface `#0F172A` | **10.3 : 1** | AAA |
| Primary `#4ADE80` | Background `#020617` | **12.4 : 1** | AAA |
| On-primary `#052E16` | Primary `#4ADE80` | **9.1 : 1** | AAA — dark primary buttons use dark text |
| Danger `#F87171` | Surface `#0F172A` | **6.1 : 1** | AA |
| Warning `#FBBF24` | Surface `#0F172A` | **10.4 : 1** | AAA |
| Info `#38BDF8` | Surface `#0F172A` | **8.2 : 1** | AAA |
| Border `#334155` | Surface `#0F172A` | 1.6 : 1 | Decorative; focus ring `#4ADE80` = 8.9:1 ✓ |

**Never rely on color alone** (WCAG 1.4.1). Pair every status color with an icon and/or text: ✓ Approved, ⚠ Expiring, ✕ Rejected.

## 7. Elevation tint in dark mode

Higher surfaces are **lightened**, not shadowed: surface = slate-900; raised surface (menu, dialog) = slate-800; shadow is near-black at higher opacity for depth. See [dark-mode.md](dark-mode.md) and [elevation.md](elevation.md).

## 8. Do / Don't

**Do** — reference semantic aliases; pair status color with an icon + text; use `-700` green for links/labels on white; verify every new pair against §6.
**Don't** — hard-code hex in components; use `primary` green for body text on white (3.31:1); invent new ramps without a contrast pass; use colored shadows.
