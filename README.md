# Alan Mobile Apps — Master Template

[![CI](https://github.com/alanjp14/alan-mobile-apps-starter-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/alanjp14/alan-mobile-apps-starter-kit/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-16A34A.svg)](LICENSE)

**System:** Alan Mobile Design System (AMDS) **v1.0**
**Repository:** [`alanjp14/alan-mobile-apps-starter-kit`](https://github.com/alanjp14/alan-mobile-apps-starter-kit)

A reusable **UI/UX + architecture master template** for every future `[COMPANY_NAME]` mobile application on **Android and iOS**. This is **not** a production app — it is a central source of truth you clone, brand, and build on.

```bash
git clone https://github.com/alanjp14/alan-mobile-apps-starter-kit.git
node tool/validate.mjs      # or: npm run validate
```

---

## 1. What AMDS is

| Layer | Location | Contents |
|---|---|---|
| **Design system** | [`docs/design-system/`](docs/design-system/README.md) | Color · typography · spacing · radius · elevation · iconography · motion · accessibility · dark mode · theme architecture · navigation patterns · Figma structure |
| **Design tokens** | [`design-tokens/`](design-tokens/README.md) | `tokens.json` (source of truth) + split JSON views + generated platform themes (Compose / Flutter / RN / web) |
| **Component library** | [`docs/component-library/`](docs/component-library/README.md) | ~40 components — design specs + engineering API + Compose/Flutter/RN/SwiftUI mappings |
| **Screen library** | [`docs/screen-library/`](docs/screen-library/README.md) | 40+ reusable screen templates on 8 archetypes; auth, dashboards, CRUD, approval, notifications, reporting, profile, settings, utility states |
| **Feature library** | [`docs/feature-library/`](docs/feature-library/README.md) | 15+ feature blueprints — business flow · data model · API · state · security · scalability · per-platform notes |
| **Starter template** | [`docs/starter-template/`](docs/starter-template/README.md) | Clean Architecture · folder / navigation / state / API / repository / DB / error / logging / analytics / push / security / CI-CD / testing / code style |
| **AI prompts** | [`prompts/`](prompts/README.md) | 6 copy-paste prompts to drive future work with any AI agent |
| **Templates** | [`templates/`](templates/) | Copy-paste screen starting points: dashboard · authentication · crud · approval · profile · monitoring |
| **Governance** | [`docs/governance.md`](docs/governance.md) | Versioning · contribution · deprecation · git workflow · AI-assisted workflow |
| **Deep specs** | [`docs/specs/`](docs/specs/) | Full worked examples (dashboard screen, Flutter starter kit) |
| **Exports** | [`exports/`](exports/README.md) | Generated, non-committed artifacts |
| **Tooling** | [`tool/`](tool/) | `validate.mjs` (repo validator), `fix-refs.mjs` (one-off) |

## 2. Why it exists

Every new `[COMPANY_NAME]` app — HRIS, K3/safety, asset management, inventory, approval workflow, monitoring, field operations, attendance, reporting, business dashboards, internal tools, SaaS — was re-deciding color, spacing, components, navigation, architecture, and security from scratch. AMDS makes those decisions **once**, keeps them **consistent**, **accessible**, and **cross-platform**, and lets a new app start at "Stage 3" (patterns + architecture) on day one.

## 3. Architecture philosophy

- **Token-driven** — every design decision is a named token; the brand color is swappable without touching components.
- **Platform-aware, unified** — Material 3 on Android, Apple HIG on iOS, one design language; adaptable to phone / small tablet / large tablet.
- **Accessible by default** — WCAG 2.2 AA is the floor.
- **Clean Architecture + feature-first** — presentation → domain (pure) → data; folders are business capabilities, not layers.
- **Offline-first** — cache-first reads; durable, idempotent, ordered write outbox.
- **Reusable, never business-specific** — placeholders (`[APP_NAME]`, `[MODULE_NAME]`, …) instead of a concrete product.
- **Additive change** — new variants over forks; deprecate over two minor versions.

Visual direction: **green + white** — fresh, clean, modern, premium, minimal, spacious, professional. Avoid gradients, clutter, decorative elements, heavy shadows.

## 4. Repository structure

```
alan-mobileapps-master-template/
├── README.md                    ← you are here
├── CHANGELOG.md
├── .gitignore
├── docs/
│   ├── governance.md
│   ├── design-system/           foundations + theme architecture + a11y + dark mode + nav patterns + Figma
│   ├── component-library/       design-specs.md · api-reference.md · data-display.md · README.md
│   ├── screen-library/          00-framework.md + 01..11 groups + dashboard-system + form-design-system
│   ├── feature-library/         00-framework.md + 01..09 feature blueprints
│   ├── starter-template/        blueprint.md + architecture/project-structure/navigation/state/... 
│   └── specs/                   dashboard.md · flutter-starter-kit.md
├── prompts/                     mobile-design-system · component-library-generator · screen-library-generator
│                                · feature-template-library · mobile-app-starter-template · ux-audit
├── design-tokens/
│   ├── tokens.json              W3C DTCG — source of truth
│   ├── colors.json · typography.json · spacing.json · radius.json · shadows.json   (split views)
│   └── platforms/               variables.css · tailwind.config.js · amds_theme.dart · Theme.kt · theme.ts
├── templates/
│   ├── dashboard/ · authentication/ · crud/ · approval/ · profile/ · monitoring/
├── exports/                     generated artifacts (gitignored)
└── tool/                        validate.mjs · fix-refs.mjs
```

## 5. How to use AMDS for a new project

1. **Read** [`docs/design-system/README.md`](docs/design-system/README.md) → [`docs/starter-template/README.md`](docs/starter-template/README.md).
2. **Pick your stack** (Flutter / React Native / Native) — see [`docs/starter-template/blueprint.md §0`](docs/starter-template/blueprint.md).
3. **Copy the tokens** — import the matching file from [`design-tokens/platforms/`](design-tokens/README.md) and wire `AmdsTheme` at your app root.
4. **Customize branding** — see §6 below.
5. **Scaffold the architecture** from [`docs/starter-template/`](docs/starter-template/README.md); the app should run end-to-end on mock repositories before any backend.
6. **Build features** — for each, follow its blueprint in [`docs/feature-library/`](docs/feature-library/README.md) and its screens in [`docs/screen-library/`](docs/screen-library/README.md).
7. **Assemble screens** from [`templates/`](templates/) starting points + [`docs/component-library/`](docs/component-library/README.md).
8. **Verify** against the Definition-of-Done checklists ([governance.md §4–5](docs/governance.md)).

### Working with AI agents

Use the [`prompts/`](prompts/README.md) library — each prompt has Role · Context · Inputs · Rules · Expected output · Validation · Acceptance criteria and is designed to paste into Claude / Gemini / Antigravity / Cursor / etc.

## 6. How to customize branding

The brand color is a **semantic token**, not a hard-coded value. See [`docs/design-system/theme-architecture.md`](docs/design-system/theme-architecture.md).

1. Add a `theme.<brand>.*` mode in `design-tokens/tokens.json` **or** a `tokens.<brand>.json` overlay that overrides **semantic** aliases only (`primary`, `primaryContainer`, `textLink`, …).
2. Keep primitives (the neutral slate ramp), the spacing scale, the type scale, and radii **shared**.
3. Regenerate the platform theme files (or resolve at runtime via a `BrandTheme { primarySeed, logo, font? }`).
4. **Components do not change.**
5. Re-run the contrast lint for the new theme — a failing pair blocks the brand.

## 7. How to create a new screen / component / feature

| Want to… | Do this |
|---|---|
| **New component** | Run [`prompts/component-library-generator.md`](prompts/component-library-generator.md); follow the 15-point template; add to `docs/component-library/`; DoD in [governance.md §4](docs/governance.md) |
| **New screen** | Run [`prompts/screen-library-generator.md`](prompts/screen-library-generator.md); inherit an archetype from [`docs/screen-library/00-framework.md`](docs/screen-library/00-framework.md); add to the group file + a `templates/` starting point |
| **New feature** | Run [`prompts/feature-template-library.md`](prompts/feature-template-library.md); all 13 dimensions; add to `docs/feature-library/` |
| **New app** | Run [`prompts/mobile-app-starter-template.md`](prompts/mobile-app-starter-template.md) |
| **Audit a design/build** | Run [`prompts/ux-audit.md`](prompts/ux-audit.md) |

## 8. How to use design tokens

- **Source of truth:** [`design-tokens/tokens.json`](design-tokens/tokens.json). Never hand-edit generated files.
- **In product code:** import the platform theme from `design-tokens/platforms/` and reference **semantic** tokens only (`colors.primary`, `spacing[4]`, `radius.md`) — never hex or primitives. This is lint-enforced.
- **Split views** (`colors.json`, etc.) are for tools/designers; regenerate them from `tokens.json`.
- Full guidance: [`design-tokens/README.md`](design-tokens/README.md) and [`docs/design-system/theme-architecture.md`](docs/design-system/theme-architecture.md).

## 9. How to maintain consistency

- Use a documented component/screen/pattern before inventing one.
- No hard-coded colors, dimensions, or user-facing strings — tokens + placeholders.
- Every screen implements all states: Loading · Empty · Success · Error · Offline · No-permission.
- Accessibility, dark mode, responsive behavior, and reduced-motion are part of the same change, not follow-ups.
- Run `node tool/validate.mjs` before every commit.
- Update every doc that references a value/pattern you change (search the repo).

## 10. Versioning & Git workflow

- **SemVer** — MAJOR (breaking token/API change + migration guide) · MINOR (new components/screens/features, backwards-compatible) · PATCH (tweaks, docs). See [`docs/governance.md §2`](docs/governance.md).
- Trunk-based / short-lived branches (`feat/…`, `fix/…`, `docs/…`); PRs required; green CI required to merge; no direct pushes to `main`.
- Every merge to `main` is releasable; releases are tagged and recorded in `CHANGELOG.md`.
- Don't commit generated platform token files without the matching `tokens.json` change.

## 11. Governance & contribution

See [`docs/governance.md`](docs/governance.md): roles, contribution workflow, Definition-of-Done checklists, deprecation policy, release cadence, RFC process, adoption dashboard, quarterly audit, and the AI-assisted development workflow.

## 12. Validation

```bash
node tool/validate.mjs
```

Checks JSON syntax, empty files, broken relative markdown references, duplicate filenames, stale references, and placeholder mistakes. **0 errors** is the merge gate.

## 13. Contributing & license

- **Contributing:** [`CONTRIBUTING.md`](CONTRIBUTING.md) (short) · [`docs/governance.md`](docs/governance.md) (full). CI (`.github/workflows/ci.yml`) runs `tool/validate.mjs` on every push and PR — green is the merge gate.
- **License:** [MIT](LICENSE).

---

*AMDS v1.0 — see [`CHANGELOG.md`](CHANGELOG.md).*
