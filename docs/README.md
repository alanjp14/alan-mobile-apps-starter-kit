# AMDS Documentation

The `docs/` tree is the design + architecture source of truth for the Alan Mobile Design System (AMDS) v1.0.
Start at the [repository README](../README.md) for the big picture.

## Map

| Folder / file | What it covers | Audience |
|---|---|---|
| [`governance.md`](governance.md) | Versioning · contribution · Definition of Done · deprecation · Git & AI workflow | Everyone |
| [`design-system/`](design-system/README.md) | Foundations: color · typography · spacing · radius · elevation · iconography · motion · accessibility · dark mode · theme architecture · navigation patterns · Figma structure | Designers, engineers |
| [`component-library/`](component-library/README.md) | ~40 components — design specs, engineering API, Compose/Flutter/RN/SwiftUI mappings, data-display patterns | Designers, engineers, QA |
| [`screen-library/`](screen-library/README.md) | 40+ screen templates on 8 archetypes + dashboard-system + form-design-system | Designers, engineers, PM |
| [`feature-library/`](feature-library/README.md) | 15+ feature blueprints (business flow · data · API · state · security · scalability · per-platform) | Engineers, architects, PM |
| [`starter-template/`](starter-template/README.md) | Clean-Architecture app blueprint: folder · nav · state · API · repo · DB · error · logging · analytics · push · security · CI/CD · testing · code style | Engineers, architects, leads |
| [`specs/`](specs/) | Deep worked examples — [`dashboard.md`](specs/dashboard.md) (full screen spec), [`flutter-starter-kit.md`](specs/flutter-starter-kit.md) (reference Flutter architecture) | All |

## Reading paths

- **Designer, new to AMDS:** [`design-system/README.md`](design-system/README.md) → [`component-library/README.md`](component-library/README.md) → [`screen-library/README.md`](screen-library/README.md) → [`design-system/figma-structure.md`](design-system/figma-structure.md)
- **Mobile engineer, starting an app:** [`design-system/theme-architecture.md`](design-system/theme-architecture.md) → [`../design-tokens/README.md`](../design-tokens/README.md) → [`starter-template/README.md`](starter-template/README.md) → [`starter-template/blueprint.md`](starter-template/blueprint.md) → [`feature-library/00-framework.md`](feature-library/00-framework.md)
- **Building one feature:** its [`feature-library/`](feature-library/README.md) blueprint → its screens in [`screen-library/`](screen-library/README.md) → components in [`component-library/`](component-library/README.md)
- **QA / Accessibility:** [`design-system/accessibility.md`](design-system/accessibility.md) → [`design-system/dark-mode.md`](design-system/dark-mode.md) → [`screen-library/00-framework.md §6`](screen-library/00-framework.md)
- **Product / PM:** [`screen-library/README.md`](screen-library/README.md) → [`screen-library/dashboard-system.md`](screen-library/dashboard-system.md) → [`feature-library/README.md`](feature-library/README.md)

## Conventions used throughout

- **Placeholders** — `[APP_NAME]` `[COMPANY_NAME]` `[USER_NAME]` `[DATA_NAME]` `[MODULE_NAME]` `[FEATURE_NAME]` `[ROLE_NAME]` (never a concrete product).
- **Tokens** — semantic names (`primary`, `surface`, `space.4`, `radius.md`), never hex/dp in examples.
- **States** — every screen: Loading · Empty · Success · Error · Offline · No-permission.
- **Cross-platform** — Jetpack Compose · Flutter · React Native (· SwiftUI where useful).
- **Standard** — WCAG 2.2 AA, Material 3 + Apple HIG unified, phone / small tablet / large tablet.

Run `node ../tool/validate.mjs` from the repo root to check references and structure.
