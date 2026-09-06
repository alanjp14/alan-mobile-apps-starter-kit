# Typography

> Part of the [Alan Mobile Design System](README.md) · Foundations.
> Tokens: [`design-tokens/typography.json`](../../design-tokens/typography.json).

---

## 1. Typeface

**Inter** (variable) is the default AMDS typeface. Fallback stack: `Inter, "SF Pro Text", Roboto, system-ui, sans-serif`.

Rationale: excellent legibility at small sizes, tall x-height, tabular figures, wide weight range, open-source. It ships on no OS so it **must be bundled** with the app (see [starter-template/developer-handoff.md](../starter-template/developer-handoff.md) §Assets). Numeric / large display may use `"SF Pro Display"` as the iOS fallback.

Enable OpenType features: `cv05` (lowercase l with tail), `ss03` (curved r), and `tnum` (tabular figures) for any aligned numeric data — tables, KPIs, timestamps, currency.

> To switch typefaces for a brand theme, change `font.family.sans` in the token file only — the scale, weights, and line heights are typeface-agnostic. Prefer another modern, variable, system-friendly sans (e.g. a licensed brand face with comparable metrics).

## 2. Type scale

Line height is a **fixed px value** (not unitless) for predictable vertical rhythm on the 4pt grid. Letter-spacing tightens as size grows.

| Role | Token | Size | Line height | Weight | Tracking | Usage |
|---|---|---|---|---|---|---|
| **Display** Large | `displayLarge` | 36 | 44 | 700 | −0.02em | Splash, marketing, empty-state hero |
| Display Medium | `displayMedium` | 32 | 40 | 700 | −0.02em | Onboarding titles |
| Display Small | `displaySmall` | 28 | 36 | 700 | −0.01em | Page hero, big number on a KPI card |
| **Headline** Large | `headingLarge` | 24 | 32 | 600 | −0.01em | Screen title (large app bar) |
| Headline Medium | `headingMedium` | 20 | 28 | 600 | −0.01em | Section header, dialog title |
| Headline Small | `headingSmall` | 18 | 26 | 600 | 0 | Card title, sub-section |
| **Title** Large | `titleLarge` | 16 | 24 | 600 | 0 | List item title, app bar title |
| Title Medium | `titleMedium` | 14 | 20 | 500 | 0.005em | Dense list title, tab label |
| **Body** Large | `bodyLarge` | 16 | 24 | 400 | 0 | Primary reading text, field input |
| Body Medium | `bodyMedium` | 14 | 20 | 400 | 0 | Default body, secondary text |
| Body Small | `bodySmall` | 13 | 18 | 400 | 0.005em | Dense secondary text, table cells |
| **Label** | `label` | 14 | 16 | 500 | 0.01em | Buttons, chips, field labels |
| Label Small | `labelSmall` | 12 | 16 | 500 | 0.02em | Badge, small button, helper |
| **Caption** | `caption` | 12 | 16 | 400 | 0.01em | Timestamps, metadata, footnotes |
| Overline | `overline` | 11 | 16 | 600 | 0.08em | ALL-CAPS section kicker, eyebrow |

## 3. Font weights

| Token | Value | Use |
|---|---|---|
| `regular` | 400 | Body, captions |
| `medium` | 500 | Labels, titles, tab labels |
| `semibold` | 600 | Headings, emphasis, overline |
| `bold` | 700 | Display only |

## 4. Rules

- **Max 3 type roles per screen region.** A list row uses title + body + caption, nothing more.
- **Never scale below 12px** for anything a user must read. 11px overline is decorative / label only.
- **Line length** 40–70 characters on phones; wrap or truncate beyond.
- **Truncation:** single-line → ellipsis at end; multi-line → clamp to 2 lines + ellipsis, full text on tap or in a detail view.
- **Alignment:** left-aligned (RTL: right). Never justify. Center only for empty states, splash, single-line dialog titles.
- **Weight for emphasis, not size.** Bump 400→600, not 14→16.
- **Numbers in tables / KPIs:** always tabular figures (`tnum`), right-aligned when comparing.

## 5. Dynamic Type / font scaling

UI must remain usable from **85% to 200%** scale.

- Use scaled text units — `sp` (Android) / `.dynamicTypeSize` (iOS) / `MediaQuery.textScaler` (Flutter) / `allowFontScaling` (React Native). Never fixed px for text.
- Containers grow with text; no fixed-height rows for text content — use `min-height`.
- At ≥130% scale, two-column rows collapse to stacked; icon+label buttons keep their label (wrap it) — dropping to an icon + tooltip is **not** acceptable.
- Test matrix: 100%, 130%, 200%, plus Bold Text on.

## 6. Do / Don't

**Do** — use the role tokens; combine weight + color for hierarchy; test at 200%; use tabular figures for aligned numbers.
**Don't** — introduce sizes outside the scale; justify text; use size alone for emphasis; hard-code px; use 11px for reading content.
