# Component Library

> Part of [AMDS v1.0](../design-system/README.md). ~40 reusable, token-driven, accessible-by-default components for Android + iOS + tablet, light + dark.
> `Amds*`-prefixed. Built on Material 3 (Android) + Apple HIG (iOS), one unified API.

## Files

| File | Side |
|---|---|
| [`design-specs.md`](design-specs.md) | **Design** — Purpose · Anatomy · Variants · Sizes · States · Accessibility · Usage rules · Light/Dark · Responsive · Do/Don't |
| [`api-reference.md`](api-reference.md) | **Engineering** — Properties (API table) · States · Accessibility · Animation · Do/Don't · **Jetpack Compose / Flutter / React Native / SwiftUI** mappings |
| [`data-display.md`](data-display.md) | Data List · Data Table · Chart Container · Statistic · Filter Bar · Sort Control · Pagination · Export |

Between `design-specs.md` and `api-reference.md`, every component covers the full **15-point template** below.

## The 15-point component template

Every component is documented against these. `design-specs.md` owns 1–7, 9–13; `api-reference.md` owns 4, 5, 8, 14, 15; `data-display.md` for data components.

| # | Point | Where |
|---|---|---|
| 1 | **Purpose** — one sentence; not a variant of an existing component | design-specs |
| 2 | **Anatomy** — token-named parts | design-specs |
| 3 | **Variants** — visual emphasis / context | both |
| 4 | **Properties** — API table: name · type · default · notes | api-reference |
| 5 | **States** — enabled · hover · focus-visible · pressed · disabled · loading · error · selected/checked/expanded | both |
| 6 | **Interaction behavior** — gestures, keyboard, timing | design-specs |
| 7 | **Accessibility** — role · name · state · target ≥44dp · focus · reduced-motion · Dynamic Type · RTL | both |
| 8 | **Motion** — AMDS tokens (100–400ms) + reduced-motion equivalent | api-reference |
| 9 | **Light theme** — semantic token mapping | design-specs |
| 10 | **Dark theme** — semantic token mapping | design-specs |
| 11 | **Responsive behavior** — phone / small tablet / large tablet | design-specs |
| 12 | **Do** | both |
| 13 | **Don't** | both |
| 14 | **Example usage** | api-reference |
| 15 | **Developer implementation notes** — Jetpack Compose / Flutter / React Native / SwiftUI (real APIs, not pseudocode) | api-reference |

## Universal conventions (apply to every component)

### Property set

`variant` · `size` (`sm`/`md`/`lg`) · `enabled`/`disabled` · `loading` · `onPress`/`onClick` · `leadingIcon`/`trailingIcon` · `semanticLabel`/`contentDescription` · `testId` · `modifier`/`style` (layout only, never token overrides).

### State model

`enabled` (default) · `hover` (pointer only, 8% `onSurface` overlay) · `focus-visible` (2px `borderFocus` ring, 2px offset) · `pressed` (12% overlay or 0.96 scale, 100ms `standard`) · `selected/checked/active` · `disabled` (38% opacity, not focusable) · `loading` (`aria-busy`, non-interactive) · `error` · `indeterminate` · `dragged`.

### Accessibility baseline

Role exposed · accessible name from a visible label or explicit prop · state announced (`selected`/`disabled`/`expanded`/`checked`/`busy`) · ≥44×44dp target, ≥8dp to neighbors · keyboard / switch / D-pad operable · visible unobstructed focus (WCAG 2.4.11) · honors reduced-motion + Dynamic Type (200%) · RTL mirrored. Contrast: text ≥4.5:1, UI/large ≥3:1, focus ring ≥3:1.

### Token references

| Concept | Compose | Flutter | React Native | SwiftUI |
|---|---|---|---|---|
| color | `AmdsTheme.colors.primary` | `context.amds.colors.primary` | `theme.colors.primary` | `Color.amdsPrimary` |
| spacing | `AmdsSpacing.md` | `AmdsSpacing.md` | `theme.spacing[4]` | `AmdsSpacing.md` |
| radius | `AmdsRadius.md` | `AmdsRadius.md` | `theme.radius.md` | `AmdsRadius.md` |
| type | `MaterialTheme.typography.labelLarge` | `context.text.labelLarge` | `theme.typography.label` | `.font(.amdsLabel)` |

## Component inventory

| Category | Components |
|---|---|
| **Actions** | Button (Primary · Secondary · Tertiary · Tonal · Destructive · Destructive-text) · Icon Button · Floating Action Button |
| **Inputs** | Text Field · Password Field · Search Bar · Dropdown / Select · Checkbox · Radio · Switch · Slider · Date Picker · Time Picker |
| **Content** | Card · KPI Card · Chart Card · Profile Card · List Item / Row · Avatar · Badge · Chip · Tag · Divider · Timeline · Accordion · Stepper · Progressive Image |
| **Navigation** | Top App Bar · Bottom Navigation · Navigation Rail · Navigation Drawer · Tabs · Breadcrumb · Segmented Control (see also [navigation patterns](../design-system/navigation-patterns.md)) |
| **Feedback** | Dialog · Modal · Bottom Sheet · Snackbar / Toast · Tooltip · Banner / Inline Alert · Success / Error / Warning / Empty / Offline states |
| **Loading** | Circular / Linear Progress · Skeleton · Shimmer · Pull-to-refresh · Loading overlay |
| **Data display** | Data List · Data Table · Chart Container · Statistic · Filter Bar · Sort Control · Pagination · Export → [data-display.md](data-display.md) |

## Component → screen usage

See the matrix at the end of [`api-reference.md`](api-reference.md) — each component mapped to the [screen-library](../screen-library/README.md) screens that use it.

## Adding a component

Run [`prompts/component-library-generator.md`](../../prompts/component-library-generator.md). Follow the 15-point template and the [Definition of Done — component](../governance.md#4-definition-of-done--component). A new component must serve **≥2 real product needs** and not be a variant of an existing one.
