# Testing Strategy & CI/CD

> Part of the [starter template](README.md). Full detail: [`blueprint.md §15, §16`](blueprint.md).

---

## 1. The testing pyramid

| Layer | What | Tools (Compose / Flutter / RN) | Gate |
|---|---|---|---|
| **Unit — domain** | use cases, `Failure` mapping, validators, formatters, reducers | JUnit + Turbine / `test` + `mocktail` / Jest + `zod` | ≥ 80% |
| **Unit — data** | repository (cache-first, outbox, conflict), DTO mappers, DAO queries, **migrations** | Room `MigrationTestHelper` / `drift` migration tests / WatermelonDB schema tests | ≥ 70% |
| **State** | ViewModel/Notifier/hook: every `UiState` transition, optimistic + rollback, one-shot events | ViewModel tests + fake repos / `ProviderContainer` + overrides / `renderHook` + QueryClient | all transitions |
| **Component** | every `Amds*` × variant × state × {light,dark} × {1.0, 2.0 text} — **golden / snapshot** | Paparazzi/Roborazzi / `alchemist`,`golden_toolkit` / Storybook + Chromatic | 100% of components |
| **Component behavior** | interactions, callbacks, a11y semantics (role/name/state), reduced-motion | Compose UI test / `flutter_test` / RN Testing Library | key components |
| **Screen** | renders each state; key interactions; empty/error/offline | Compose UI test / widget test / RNTL | each screen's states |
| **Accessibility** | contrast, tap targets, labels — automated + a manual SR pass on top flows | `AccessibilityChecks` / `meetsGuideline(...)` / `eslint-plugin-react-native-a11y` + manual | CI + per-release manual |
| **Integration** | a feature slice against a mock server / fake — repo → API contract | Hilt test rules + MockWebServer / `dio` + a fake / MSW | per feature |
| **E2E** | the 3 core flows on a real device/emulator: login→dashboard→approve · list→edit→save · create via form | Espresso + Compose / `integration_test` / **Detox** or **Maestro** | CI (smoke) + nightly (full) — **release gate** |
| **Contract** | client ⇄ OpenAPI schema | schema validation in CI | on schema change |
| **Performance** | cold start, first meaningful paint, jank frames, APK/IPA size, memory — budgeted | Macrobenchmark + `JankStats` / DevTools timeline / Flashlight | budgets enforced |
| **Security** | SCA, secret scan, auth-flow pen test (pre-release) | Snyk/OWASP + gitleaks + manual/automated pen test | CI + pre-release |

## 2. Rules

- Tests live **next to the code** (`[module]_test.*`), not in a parallel tree.
- Every bug fix ships with a regression test.
- Golden baselines are reviewed like code; update deliberately (`--update-goldens` in a dedicated commit).
- The 3 E2E flows must stay green — they're the release gate.
- Mock repositories mean features are testable and demoable **before** the backend exists.

## 3. CI pipeline (per PR)

```
1. Setup            checkout · restore caches · install the pinned toolchain
2. Generate/verify  codegen fresh (freezed/hilt/openapi/tokens) — fail if stale
3. Static analysis  lint · format check · type check (TS) · dependency-rule tests
4. Security         SCA (Snyk/OWASP) · secret scan (gitleaks) · license check
5. Unit + widget    with coverage gates — fail on regression
6. Golden/snapshot  components × variants × states × {light,dark} × {1.0,2.0} — visual diff
7. Contrast/a11y    token contrast lint · automated a11y guideline tests on key screens
8. Build            Android (assembleDebug + a signed RC) · iOS (no-sign archive)
9. Integration/e2e  3 core flows on an emulator/simulator
10. Catalog         deploy Widgetbook/Storybook (web) as a review artifact
11. Report          post coverage + size + a11y summary as a PR comment
```

## 4. Release pipeline (on tag / merge to `release/*`)

```
- bump version (SemVer) + generate changelog
- build signed artifacts per flavor (dev/staging/prod) via Fastlane / EAS
- Android: AAB -> Play internal -> closed -> production (staged rollout 10% -> 50% -> 100%)
- iOS: IPA -> TestFlight -> App Store (phased release)
- upload dSYM / mapping / sourcemaps to the crash reporter
- smoke tests on the release build
- tag, notify, monitor crash-free rate + key funnels for 48h (auto-halt rollout on regression)
```

## 5. Environment config

- `flutter run --flavor dev` / product flavors (Android) / schemes (iOS).
- Config via `--dart-define-from-file` / `BuildConfig` / `react-native-config` — **no secrets in the repo**; CI injects prod.
- Feature flags: one service (LaunchDarkly / Firebase Remote Config / Unleash), flags named `feature.<area>.<name>`.
- Reproducible builds: pinned toolchain (`.tool-versions` / `fvm` / `.nvmrc`).

## 6. Do / Don't

**Do** — tests next to code; regression test per fix; golden 100% of components; keep the 3 E2E flows green; enforce coverage + performance budgets; gate the rollout on crash-free rate.
**Don't** — a parallel test tree; skip migration tests; update goldens silently; ship without the E2E gate; put secrets in the repo; OTA-push native changes (RN).
