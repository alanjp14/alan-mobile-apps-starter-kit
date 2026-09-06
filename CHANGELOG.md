# Changelog

All notable changes to the Alan Mobile Design System (AMDS) are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/). Versioning: [SemVer](https://semver.org/) — see [`docs/governance.md`](docs/governance.md).

## [1.0.0] — 2026-09-06

First release of the reusable master template.

### Repository

- `docs/` organized into responsibility folders: [`design-system/`](docs/design-system/README.md), [`component-library/`](docs/component-library/README.md), [`screen-library/`](docs/screen-library/README.md), [`feature-library/`](docs/feature-library/README.md), [`starter-template/`](docs/starter-template/README.md), plus [`governance.md`](docs/governance.md) and `specs/`.
- [`design-tokens/`](design-tokens/README.md): `tokens.json` (W3C DTCG source of truth) + split views (`colors/typography/spacing/radius/shadows.json`) + `platforms/` generated themes (CSS · Tailwind · `amds_theme.dart` · `Theme.kt` · `theme.ts`).
- [`prompts/`](prompts/README.md): 6 reusable AI prompts (mobile-design-system · component/screen/feature generators · mobile-app-starter-template · ux-audit).
- [`templates/`](templates/README.md): copy-paste starting points — dashboard · authentication · crud · approval · profile · monitoring.
- `exports/` (generated artifacts, gitignored) · `tool/validate.mjs` (repo validator) · `.gitignore` · Git initialized.

### Design system

- Three-tier token model (primitive → semantic → component) — [`theme-architecture.md`](docs/design-system/theme-architecture.md).
- **Color** — 11-step green + slate ramps; amber/red/sky status ramps; semantic aliases incl. `brand`, `primary`, `secondary`, `accent`, `background`, `surface`, `surfaceVariant`, `border`, `divider`, `textPrimary/Secondary/Tertiary` (a.k.a. Muted), `disabled`, `success`, `warning`, `danger` (M3 "error"), `info`; light + dark; **verified WCAG 2.2 contrast tables**.
- **Typography** — Inter; Display · Heading · Title · Body · Label · Caption (16 roles: size, line-height, weight, tracking, usage).
- **Spacing** — `4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64` (4pt base) + grid + breakpoints (phone S/M/L, small/large tablet).
- **Radius** — `xs · sm · md · lg · xl · 2xl · full`. **Elevation** — 5 levels, light + dark, flat-by-default.
- **Iconography** — Material Symbols + Lucide; sizing; concept→glyph map (Navigation / Dashboard / Forms / Settings / Profile / Analytics).
- **Motion** — 100–400ms tokens, 4 easings, pattern catalog, reduced-motion requirements.
- **Accessibility** — WCAG 2.2 AA conformance mapping + testing matrix.
- **Dark mode** — surface/elevation model, full color mapping, switching, QA checklist.
- **Foundations** — interaction principles, universal component-state model, screen-level state model, density, responsive behavior.
- **Navigation patterns** + **Figma structure**.

### Component library

- ~40 components across Actions · Inputs · Content · Navigation · Feedback · Loading · Data display.
- Each documented against the **15-point template** — split across [`design-specs.md`](docs/component-library/design-specs.md) (design), [`api-reference.md`](docs/component-library/api-reference.md) (properties + Compose/Flutter/RN/SwiftUI), [`data-display.md`](docs/component-library/data-display.md) (tables/filters/pagination).

### Screen library

- 40+ screen templates on **8 archetypes** (Focused Task · Dashboard · List · Detail · Form · Confirmation · Settings · Content) — [`00-framework.md`](docs/screen-library/00-framework.md).
- Groups: Authentication · Dashboard · User Management · Data Management · Approval · Notification · Reporting · Profile · Settings · Help Center · **Utility States** (Loading · Empty · Error · Offline · No Permission · Session Expired · Maintenance).
- Design patterns: `dashboard-system.md`, `form-design-system.md`. Worked example: [`specs/dashboard.md`](docs/specs/dashboard.md).

### Feature library

- 16 feature blueprints across 10 files — Authentication · User Management · Role Management · Approval Workflow · Notification Center · Push Notifications · Dashboard Analytics · Reports · Search & Filter · File Upload · Settings · Profile · Audit Logs · Activity Timeline · Offline Sync · **Deep Linking · Session Management**.
- Each covers 13 dimensions: Purpose · Business Flow · UX Flow · Screen Mapping · Required Components · Database Entities · API Endpoints · State Management · Compose/Flutter/RN · Security · Scalability.

### Starter template

- [`blueprint.md`](docs/starter-template/blueprint.md) (full) + focused docs: architecture · project-structure · navigation · state-management · networking · local-storage · security · testing · error-handling-and-logging · code-style-and-guidelines · developer-handoff · scalability.
- Clean Architecture · feature-first · offline-first · production-ready; Jetpack Compose / Flutter / React Native / SwiftUI mappings; CI/CD, testing pyramid, environment config.
- Reference implementation: [`specs/flutter-starter-kit.md`](docs/specs/flutter-starter-kit.md).

[1.0.0]: #
