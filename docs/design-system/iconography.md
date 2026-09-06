# Iconography

> Part of the [Alan Mobile Design System](README.md) · Foundations.

---

## 1. Libraries

- **Primary — Material Symbols** (Rounded, weight 400, optical size 24, grade 0). Consistent with Android and the majority of enterprise iconography needs.
- **Secondary — Lucide** — used where Material lacks a concept or a lighter stroke suits a marketing surface. Lucide default stroke = 2px, visually matching Material Symbols Rounded at 24/400.

Do not mix both libraries **within one screen region**. Pick per feature; document the choice.

## 2. Sizing

| Token | Size | Use |
|---|---|---|
| `iconXs` | 16 | Inline with `bodySmall`, dense chips, table-cell affordance |
| `iconSm` | 20 | Inline with body text, list-row trailing chevron, field affix |
| `iconMd` | 24 | **Default.** App bar actions, list leading, buttons, tabs, bottom nav |
| `iconLg` | 32 | Section headers, empty-state secondary, avatar fallback |
| `iconXl` | 40 | Empty-state primary, onboarding, feature callout |

## 3. Stroke, alignment & touch target

- **Stroke principles:** Rounded family; consistent optical weight; filled for selected/active states, outline for inactive (bottom nav, tabs). Two-tone / multicolor only in illustrations, never in UI controls.
- **Alignment:** center the icon to text **cap-height**, not the bounding box. Icon↔label gap: `space.1` (4) tight, `space.2` (8) for buttons/list rows.
- **Touch target:** icon-only controls have a ≥44dp hit area even at a 24dp visual size, and a required accessible label describing the **action** ("More options"), not the glyph.

## 4. Semantic status icons

Monochrome, tinted by the semantic token — always paired with text (never color alone):

| Meaning | Material | Token tint |
|---|---|---|
| Success ✓ | `check_circle` | `success` |
| Warning ⚠ | `warning` | `warning` |
| Error ✕ | `error` | `error` |
| Info ⓘ | `info` | `info` |

Brand / product logos are **not** icons — keep them in a separate asset set.

## 5. Standard icon set by domain

| Context | Concept | Material Symbol | Lucide |
|---|---|---|---|
| **Navigation** | Home | `home` | `home` |
| | Back | `arrow_back` (RTL: `arrow_forward`) | `arrow-left` |
| | Close | `close` | `x` |
| | Menu / drawer | `menu` | `menu` |
| | More actions | `more_vert` | `ellipsis-vertical` |
| | Search | `search` | `search` |
| | Filter | `filter_list` | `sliders-horizontal` |
| | Sort | `swap_vert` | `arrow-up-down` |
| | Expand / collapse | `expand_more` / `expand_less` | `chevron-down` / `chevron-up` |
| **Dashboard** | Overview | `dashboard` | `layout-dashboard` |
| | Trending up / down | `trending_up` / `trending_down` | `trending-up` / `trending-down` |
| | Alert | `notifications_active` | `bell-ring` |
| | Quick action | `bolt` | `zap` |
| | Activity feed | `history` | `activity` |
| **Forms** | Add | `add` | `plus` |
| | Edit | `edit` | `pencil` |
| | Delete | `delete` | `trash-2` |
| | Save | `save` / `check` | `save` / `check` |
| | Attach | `attach_file` | `paperclip` |
| | Calendar / date | `calendar_today` | `calendar` |
| | Time | `schedule` | `clock` |
| | Required error | `error` | `alert-circle` |
| **Settings** | Settings | `settings` | `settings` |
| | Preferences | `tune` | `sliders-horizontal` |
| | Security | `lock` / `shield` | `lock` / `shield` |
| | Language | `language` | `globe` |
| | Theme | `dark_mode` / `light_mode` | `moon` / `sun` |
| | Logout | `logout` | `log-out` |
| **Profile** | Person | `person` | `user` |
| | Account / badge | `badge` | `id-card` |
| | Team / group | `groups` | `users` |
| | Email | `mail` | `mail` |
| | Phone | `call` | `phone` |
| | Camera / photo | `photo_camera` | `camera` |
| **Analytics** | Bar chart | `bar_chart` | `bar-chart-3` |
| | Line chart | `show_chart` | `line-chart` |
| | Pie / donut | `pie_chart` | `pie-chart` |
| | Report / document | `description` | `file-text` |
| | Export / download | `download` | `download` |
| | Date range | `date_range` | `calendar-range` |

## 6. Implementation notes

| | Jetpack Compose | Flutter | React Native | SwiftUI |
|---|---|---|---|---|
| Source | Material Symbols font / per-icon `ImageVector` | `material_symbols_icons` + `flutter_svg` | `react-native-vector-icons` (MaterialSymbols) + `react-native-svg` | SF Symbols where equivalent, else a bundled set |
| App-level map | `AppIcons` object (concept → resource) | `AppIcons` class | `AppIcons` module | `AppIcons` enum |

One `AppIcons` map per app (concept → asset); components never reference a raw icon name.

## 7. Do / Don't

**Do** — one library per screen region; label icon-only controls by action; pair status icons with text; center to cap-height.
**Don't** — mix Material + Lucide in one region; use color as the only status signal; multicolor icons in controls; icon-only with no accessible label.
