# Developer Guidelines & Code Style

> Part of the [starter template](README.md). Full detail: [`blueprint.md §17, §18`](blueprint.md).

---

## 1. Developer guidelines

### Getting started (day 1)

1. Install the pinned toolchain (`.tool-versions` / `fvm use` / `nvm use`).
2. `<bootstrap>` — Gradle sync / `melos bootstrap` / `yarn && pod install`.
3. Copy `config/dev.example.json` → `config/dev.json` (no secrets).
4. Run the app against **mock repositories** — every screen works offline on mock data.
5. Run `<test>` — green from a clean clone is the contract.
6. Open the component catalog (Widgetbook / Storybook).
7. Read: [`README.md`](README.md) → [`../feature-library/00-framework.md`](../feature-library/00-framework.md) → the feature you're touching → its screen specs.

### Adding a feature

1. Scaffold the [feature-module contract](architecture.md#3-feature-module-contract).
2. Define the **domain** first (entity + repository interface + use cases). No framework imports.
3. Define the **API contract** (OpenAPI) + regenerate the typed client.
4. Implement the **mock repository** → wire screens → demo it.
5. Implement the **real repository** (cache-first + outbox); declare the offline tier per operation.
6. Build screens from the [screen-library](../screen-library/README.md) archetype; use the 3 engines (`RecordListConfig` / `RecordDetailConfig` / `FormSchema`) where they fit.
7. Register routes + deep links centrally; add analytics events; note audit expectations.
8. Tests per [testing.md](testing.md); a11y + dark-mode + tablet + reduced-motion pass.
9. PR with the feature's [Definition of Done](../feature-library/00-framework.md) ticked.

### Working agreements

- **Definition of Done** per feature/screen/component is enforced in review.
- **Small PRs** (< ~400 lines), one concern, self-review first.
- **No `TODO` without a ticket link.** No commented-out code.
- **Feature flags** for anything risky or incomplete; remove the flag when stable.
- **Backwards-compatible** DB migrations and API changes; deprecate over two minor versions.
- **Accessibility, dark mode, offline, and RTL are not follow-ups** — same PR.
- **Never** hard-code a color / dimension / user-facing string in `features/` (lint fails).
- **Never** import one feature from another.
- **Never** put a network call, store read, or navigation inside a component.
- **Update the docs** in the same PR when you change a pattern.

### Code review checklist

- [ ] Dependency rule respected (domain pure; no cross-feature imports; no data types in presentation)
- [ ] All `UiState` branches handled (loading / data / empty / error / offline / no-permission)
- [ ] Mutations: optimistic + rollback + `Idempotency-Key`; 409 handled
- [ ] Tokens only (no hex/dp/strings); dark + 200% text + RTL OK
- [ ] a11y: role/name/state on interactive elements; reduced-motion path
- [ ] Errors mapped to `Failure`; no raw exceptions/stack traces to the user; `traceId` surfaced
- [ ] Analytics events fire; audit expectations noted; no PII in logs/events/URLs
- [ ] Tests: state transitions + component goldens + a11y; regression test for any fix
- [ ] Offline tier declared and implemented for each new operation
- [ ] No secrets; no new unpinned dependency; SCA clean

## 2. Code style

### Universal

- **The formatter is law** — `ktlint`/`spotless` · `dart format` · `prettier`. CI fails on unformatted code. No style debates in review.
- **Naming** — features = domain nouns (`assets`, not `screens`); files = the primary type; `Amds*` for design-system widgets; `*Screen`/`*Page`, `*Controller`/`*ViewModel`/`use*`, `*Repository`, `*Dto`, `*UiState`.
- **Immutability by default** — `val`/`final`/`readonly`/`const`; immutable data classes.
- **Small units** — a function does one thing; extract when it needs a comment to explain a block.
- **Comments explain *why*, not *what*.** Match the surrounding code's comment density.
- **No magic numbers/strings** — named constants or tokens; enums over string literals.
- **Nullability explicit** — no `!!` / `!` / non-null assertions without a guarded reason; model absence in types.
- **Errors as values** (`Result`/`Either`); exceptions only at true boundaries.
- **Pure domain** — no framework, I/O, or platform imports in `domain/`.

### Kotlin / Compose

- Kotlin coding conventions + `ktlint`. `detekt` + Compose lint rules; Konsist for architecture.
- Composables: `PascalCase`, no side effects in composition, hoist state, `Modifier` as the first optional param, preview functions per variant.
- `sealed interface` for `UiState`/`Failure`; `StateFlow` over `LiveData`; `collectAsStateWithLifecycle`.
- Coroutines: structured concurrency, inject dispatchers, no `GlobalScope`.

### Dart / Flutter

- `flutter_lints` + `very_good_analysis` + `custom_lint` + `riverpod_lint`.
- `freezed` for models + unions; `const` constructors everywhere possible; `key` on list items.
- Small composable widgets; short `build` methods; extract widgets (not methods) for rebuildable subtrees.
- Riverpod: `@riverpod` codegen, `AsyncNotifier` for data, `ref.watch` in build / `ref.read` in callbacks, no `BuildContext` in providers.
- `import_lint` / a boundary lint to forbid cross-feature and layer violations.

### TypeScript / React Native

- `strict: true`; ESLint (`@typescript-eslint`, `react-hooks`, `react-native-a11y`, `eslint-plugin-boundaries`) + Prettier.
- Function components + hooks only; one component per file; `React.memo` for list rows; stable keys.
- Zod-validate all external data at the boundary; infer types from schemas.
- TanStack Query for server state; Zustand slices for client state; no prop-drilling beyond 2 levels.
- Path aliases (`@core/*`, `@features/*`); no relative `../../..` across features.

### SwiftUI

- SwiftLint + SwiftFormat. Value types by default; `@Observable` models; small views; extract subviews.
- No business logic in `View`; a model owns state and effects.
