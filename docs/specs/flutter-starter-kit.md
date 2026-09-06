# Specification · AMDS Flutter Master UI Starter Kit

> **Design foundation:** Alan Mobile Design System (AMDS) v1.0
> **What this is:** a versatile, modular, reusable Flutter template architecture — a "master UI starter kit" you clone to launch any new iOS/Android product on AMDS in ~1 day.
> **Scope:** Standard v1 — auth · dashboard · list/detail · one CRUD workflow · approvals · notifications · profile/settings · help/about, plus the theming, navigation, state, data, and config plumbing.
> **Stack:** Flutter (stable), Dart 3, Material 3.
> **Status:** Blueprint — ready to build.

---

## 1. Goals & principles

| Goal | How the kit delivers it |
|---|---|
| **Reusable across many future apps** | Monorepo of publishable packages; product apps depend on them and add only feature code |
| **Modular** | `amds_tokens` → `amds_ui` → `amds_core` → `app_config` → `app`; clean dependency direction, no cycles |
| **Modern & clean** | Material 3, AMDS tokens, Flutter 3 widgets, no legacy patterns; Riverpod + go_router + freezed |
| **Scalable (5–10 yr)** | Token-driven theming, feature-first architecture, additive change, semantic versioning per package |
| **White-label ready** | Brand + feature-flag + env config layer; a new app overrides tokens and flips flags, not forks |
| **Fast to start** | `mason` bricks + a `melos` bootstrap; a reference app + a bare `_template` app to copy |
| **Accessible & i18n by default** | AMDS a11y baked into `amds_ui`; `flutter_localizations` + ARB wired from screen one |
| **Testable** | Golden tests (light/dark) for every component, widget tests per feature, integration tests for the 3 core flows |

**Non-goals for v1:** backend, complex offline sync engine, multi-tenant auth server, design-tokens build pipeline UI (the `tokens.json` → Dart step is scripted, see §5).

---

## 2. Repository architecture

Monorepo managed by **Melos**. Dependency direction is strictly downward.

```
amds_flutter_starter_kit/
├── melos.yaml
├── pubspec.yaml                    (workspace)
├── analysis_options.yaml           (very_good_analysis + custom lints)
├── tool/
│   ├── build_tokens.dart           tokens.json → packages/amds_tokens/lib/src/*.g.dart
│   └── new_app.sh                   scaffold a product app from _template
├── bricks/                         mason bricks
│   ├── amds_feature/               generate a feature module (screen + controller + state + repo + tests)
│   ├── amds_screen/                generate a single screen
│   └── amds_app/                   generate a new product app shell
├── packages/
│   ├── amds_tokens/                ← generated Dart tokens (colors, type, spacing, radius, elevation, motion)
│   ├── amds_ui/                    ← the component library (Flutter widgets = AMDS component-library)
│   ├── amds_core/                  ← utilities: Result, failures, formatters, validators, network, storage, logging
│   └── app_config/                 ← AppConfig, flavors, feature flags, branding overrides
├── apps/
│   ├── starter/                    ← the reference app: every screen wired, mock data, the "master template"
│   └── _template/                  ← minimal skeleton (splash + login + 1 dashboard) to copy for a real product
└── widgetbook/                     ← component catalog / gallery (widgetbook package), light + dark, all states
```

### 2.1 Package responsibilities

| Package | Depends on | Contains | Publishes |
|---|---|---|---|
| `amds_tokens` | flutter | `AmdsColors`, `AmdsSpacing`, `AmdsRadius`, `AmdsTypography`, `AmdsElevation`, `AmdsMotion`, `AmdsBreakpoints` — **generated** from `design-tokens/tokens.json` | pub (internal) |
| `amds_ui` | `amds_tokens` | `AmdsTheme` (ThemeData + `AmdsThemeExt`), every component widget, adaptive layout helpers, state widgets (empty/error/loading/offline), `AmdsIcons` | pub (internal) |
| `amds_core` | flutter, dio, freezed | `Result<T>`/`Failure`, `AppException`, `Formatters` (date/number/currency/relative-time, locale-aware), `Validators`, `ApiClient` (dio + interceptors), `SecureStore`, `KeyValueStore`, `AppLogger`, `Analytics` abstraction, `Connectivity` | pub (internal) |
| `app_config` | `amds_tokens` | `AppConfig` (name, env, api base, brand token overrides), `Flavor` enum, `FeatureFlags`, `BrandTheme` (per-product token diffs) | pub (internal) |
| `apps/starter` | all packages + riverpod, go_router | Feature modules, router, DI, mock repositories, l10n | — |

**Rule:** feature code lives only in apps. If something is reusable, it graduates into a package via PR + version bump.

---

## 3. App-internal architecture (feature-first + light clean layers)

```
apps/starter/lib/
├── main_dev.dart / main_staging.dart / main_prod.dart   flavor entrypoints
├── bootstrap.dart                     runZonedGuarded, error hooks, DI overrides, runApp
├── app/
│   ├── app.dart                       MaterialApp.router(theme, darkTheme, themeMode, locale, routerConfig)
│   ├── router/
│   │   ├── app_router.dart            GoRouter + ShellRoute (adaptive nav) + deep links
│   │   ├── routes.dart                typed route names + paths (navigation-patterns §9)
│   │   └── guards.dart                auth gate, permission gate, redirect logic
│   └── di/
│       └── providers.dart             root ProviderScope overrides (env, repos)
├── core/
│   ├── theme/theme_controller.dart    ThemeMode + textScale + density (persisted)
│   ├── session/session_controller.dart  auth token, current user, permissions
│   ├── l10n/                          app_en.arb, app_id.arb, ... (generated)
│   └── analytics/                     event names, tracking helpers
├── features/
│   ├── splash/
│   ├── onboarding/
│   ├── auth/                          login, forgot_password, (reset)
│   ├── dashboard/
│   ├── records/                       generic list + detail + crud form (config-driven)
│   ├── approvals/                     queue + detail
│   ├── notifications/
│   ├── profile/
│   ├── settings/
│   └── help/                          help center + about
└── data/
    ├── models/                        freezed DTOs shared across features
    ├── repositories/                  interfaces
    └── repositories_mock/             in-memory impls (the kit ships fully working on mock data)
```

**Each feature module** (generated by the `amds_feature` brick):

```
features/dashboard/
├── dashboard_page.dart               ConsumerWidget — stateless, reads a UiState provider
├── dashboard_controller.dart         @riverpod class — owns fetching, refresh, actions
├── dashboard_state.dart              @freezed — UiState (loading/data/error per block)
├── widgets/                          screen-local composables (KpiGrid, NeedsYouList, ...)
├── data/
│   ├── dashboard_repository.dart      interface
│   └── dashboard_dto.dart             @freezed
└── dashboard_test.dart               widget + golden + controller unit tests
```

### 3.1 Layering rules

- **Page** = dumb: reads one `AsyncValue<XUiState>` provider, renders `amds_ui` widgets, dispatches intents to the controller. No business logic, no direct repo calls.
- **Controller** (Riverpod notifier) = state + orchestration: calls repositories, maps `Result`/`Failure` → `UiState`, handles optimistic updates, retries, debounced refresh.
- **Repository** = data access behind an interface; the app is wired to `repositories_mock` by default and swaps to real impls via a single DI override.
- **Model** = `freezed` immutable DTOs; UI models separate from DTOs when they diverge.
- **No `setState` in features** except trivial local widget state (a toggle, an animation controller).

---

## 4. State management — Riverpod 2 (code-gen)

- `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator` + `custom_lint`/`riverpod_lint`.
- One `@riverpod` controller per screen; `AsyncNotifier` for screens that load data.
- Cross-cutting providers: `sessionControllerProvider`, `themeControllerProvider`, `featureFlagsProvider`, `connectivityProvider`, `analyticsProvider`.
- Repositories exposed as providers; overridden in `main` / tests.
- `ref.listen` for side effects (snackbars, navigation on auth loss). No `BuildContext` in controllers.
- Pattern for a data screen:

```dart
@riverpod
class DashboardController extends _$DashboardController {
  @override
  Future<DashboardUiState> build() => _load();

  Future<DashboardUiState> _load() async {
    final repo = ref.read(dashboardRepositoryProvider);
    final res = await repo.fetch(filter: ref.read(dashboardFilterProvider));
    return res.fold(
      onSuccess: (d) => DashboardUiState.fromData(d),
      onFailure: (f) => DashboardUiState.error(f),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading<DashboardUiState>().copyWithPrevious(state);
    state = await AsyncValue.guard(_load);
  }

  Future<void> approve(String id) async { /* optimistic remove + undo + rollback */ }
}
```

**Alternatives considered:** BLoC (more boilerplate for this size), `provider` only (weaker async ergonomics), GetX (opinionated, harder to test). Riverpod chosen for testability, compile-safe DI, and code-gen ergonomics.

---

## 5. Design tokens → Dart

`tool/build_tokens.dart` reads [`design-tokens/tokens.json`](../../design-tokens/tokens.json) and emits `packages/amds_tokens/lib/src/`:

```
colors.g.dart      AmdsPalette (raw ramps) + AmdsColorScheme (light/dark semantic sets)
typography.g.dart  AmdsTypography.textTheme + individual TextStyles
spacing.g.dart     AmdsSpacing (const doubles 0..64)
radius.g.dart      AmdsRadius
elevation.g.dart   AmdsElevation.level(1..5) -> List<BoxShadow> (light & dark)
motion.g.dart      durations + Curves
breakpoints.g.dart AmdsBreakpoints
```

- Run via `dart run tool/build_tokens.dart` (also a Melos script + a CI check that fails if generated output is stale).
- The committed [`design-tokens/platforms/amds_theme.dart`](../../design-tokens/platforms/amds_theme.dart) is the reference implementation the generator targets.
- **Product code imports semantic tokens only** — `context.amds.colors.primary`, `AmdsSpacing.md` — never raw hex, never `AmdsPalette.green600` directly.

### 5.1 Theme access

`amds_ui` exposes `AmdsTheme.light` / `AmdsTheme.dark` (ThemeData) with an `AmdsThemeExt` `ThemeExtension` carrying every semantic token, plus an extension for ergonomics:

```dart
extension AmdsContext on BuildContext {
  AmdsThemeExt get amds => Theme.of(this).extension<AmdsThemeExt>()!;
  TextTheme get text => Theme.of(this).textTheme;
}

// usage
Container(
  padding: EdgeInsets.all(AmdsSpacing.md),
  decoration: BoxDecoration(
    color: context.amds.colors.surface,
    borderRadius: BorderRadius.circular(AmdsRadius.lg),
    border: Border.all(color: context.amds.colors.border),
  ),
  child: Text('Total', style: context.text.titleMedium?.copyWith(color: context.amds.colors.textSecondary)),
);
```

---

## 6. Component library (`amds_ui`) — the widget kit

Every AMDS component (component-library) as a Flutter widget with a **consistent API** (developer-handoff §3): `variant`, `size`, `enabled`, `loading`, `onPressed`, `leadingIcon`, `trailingIcon`, `semanticLabel`.

| Group | Widgets |
|---|---|
| Actions | `AmdsButton` (6 variants × 3 sizes), `AmdsIconButton`, `AmdsFab` (regular/small/extended) |
| Inputs | `AmdsTextField`, `AmdsPasswordField`, `AmdsDropdown<T>`, `AmdsSearchField`, `AmdsCheckbox`, `AmdsRadioGroup<T>`, `AmdsSwitchTile`, `AmdsDatePickerField`, `AmdsTimePickerField` |
| Containment | `AmdsCard`, `AmdsKpiCard`, `AmdsChartCard`, `AmdsProfileCard`, `AmdsListTileX`, `AmdsAccordion`, `AmdsSectionHeader` |
| Feedback | `AmdsDialog.confirm/destructive/acknowledge`, `AmdsBottomSheet.show`, `AmdsSnackbar`, `AmdsBanner`, `AmdsTooltip`, `AmdsBadge`, `AmdsAvatar`, `AmdsChip` |
| Progress | `AmdsSpinner`, `AmdsProgressBar`, `AmdsSkeleton` + `AmdsSkeletonList/Card/Dashboard` |
| Layout | `AmdsScaffold` (safe areas + scroll + optional sticky footer), `AmdsAdaptiveNavigation` (bottom bar ↔ rail ↔ drawer), `AmdsResponsive` (breakpoint builder), `AmdsPullToRefresh` |
| States | `AmdsEmptyState`, `AmdsErrorState`, `AmdsOfflineBanner`, `AmdsPermissionDeniedState` |
| Motion | `AmdsPageTransitions` (shared-axis, reduced-motion aware), `AmdsAnimatedCount`, `AmdsFadeSlideIn` (staggered list entrance) |

- All widgets: reduced-motion aware (`MediaQuery.disableAnimations`), Dynamic Type safe (min-height not fixed-height), RTL-mirrored, ≥44dp targets, `Semantics` with role+label+state.
- **Widgetbook** catalogs every widget × variant × state × theme; deployed per PR for design review; doubles as the golden-test source.

---

## 7. Navigation (`go_router` + adaptive shell)

- **Typed routes** in `routes.dart` matching AMDS deep-link structure (navigation-patterns §9): `/dashboard`, `/records/:type`, `/records/:type/:id`, `/records/:type/:id/edit`, `/records/:type/new`, `/approvals`, `/approvals/:id`, `/notifications`, `/profile`, `/settings`, `/help`.
- **`ShellRoute`** hosts `AmdsAdaptiveNavigation`: bottom nav (phone) → nav rail (tablet portrait) → persistent drawer (tablet landscape), switched by `AmdsBreakpoints` via `LayoutBuilder`/`MediaQuery`.
- **Guards** (`redirect`): unauthenticated → `/login` (store pending deep link, resume after); missing permission → `/denied`; unknown route → `/not-found`.
- **Back-stack synthesis** for deep links (e.g. `/records/asset/123` builds `[dashboard, records/asset, records/asset/123]`).
- Page transitions from `AmdsPageTransitions` (shared-axis X for push, fade for reduced-motion), platform-appropriate (Cupertino edge-swipe on iOS).
- Deep-link config registered for `[app-scheme]://` scheme + `https://` App Links / Universal Links.

---

## 8. Screens shipped in v1

Each is a generated feature module; the reference app wires all of them against mock repositories. Detailed per-screen specs follow the AMDS screen templates.

| # | Screen | Template (screen-library) | Notes for the kit |
|---|---|---|---|
| 1 | **Splash** | §1 | native splash → session resolve → route; honors theme from frame 1 |
| 2 | **Onboarding** | §2 | 3-page pager, config-driven content (`app_config`), skippable, "seen" persisted |
| 3 | **Login** | §3 | email + password + biometric hook + SSO button slots; error Banner; `autofill` |
| 4 | **Forgot password** | §5 | request → confirmation state (no account-existence leak) → resend cooldown |
| 5 | **Dashboard** | §6 / dashboard-system (operational) | KPI grid, "Needs you", trend `AmdsChartCard`, recent activity, quick actions, FAB — full spec in [`dashboard.md`](dashboard.md) |
| 6 | **Records — List** | §8 | **generic, config-driven**: pass a `RecordListConfig` (columns, filters, sort, row builder) → reuse for assets/incidents/requests/contacts |
| 7 | **Records — Detail** | §9 | header block + primary actions + tabbed sections (Overview/History/Documents/Comments) driven by a `RecordDetailConfig` |
| 8 | **Records — CRUD Form** | §10 / form-design-system | **schema-driven form engine**: a `FormSchema` (list of `FormFieldSpec`) renders `amds_ui` inputs, validation, autosave draft, submit |
| 9 | **Approvals — Queue** | §11 | list filtered to "pending me", inline approve with Undo, bulk approve (low-risk) |
| 10 | **Approvals — Detail** | §11 | summary + line items + approval chain (`AmdsStepper` vertical) + comment-required reject/return |
| 11 | **Notifications** | §12 | grouped list, filter chips, deep-link on tap, mark-all-read, swipe dismiss |
| 12 | **Profile** | §13 | header `AmdsProfileCard`, contact rows, links to settings; edit uses the form engine |
| 13 | **Settings** | §14 | Appearance (theme/textScale/density segmented), Notifications toggles, Privacy/Security, About, Support — toggles apply instantly via `themeControllerProvider` etc. |
| 14 | **Help Center & About** | §15 | search, FAQ accordions, contact; About = version/build (copyable), legal, licenses (`showLicensePage`) |
| — | **State screens** | component-library F | `AmdsEmptyState` / `AmdsErrorState` / offline banner reused everywhere |

### 8.1 The three reusable "engines" (what makes it a starter kit, not just screens)

1. **`RecordListConfig` / list engine** — declarative list screen: data source (repo + query), row widget, filter definitions (chips/sheet), sort options, empty/error copy, FAB action, selection mode. One widget powers every list in every future app.
2. **`RecordDetailConfig` / detail engine** — header fields, action set (permission-gated), section/tab definitions (field groups, related lists, activity), destructive action. 
3. **`FormSchema` / form engine** — `List<FormFieldSpec>` where each spec = `{ key, type, label, helper, validators, visibleWhen, options, async }`. Renders the right `amds_ui` input, wires validation timing (form-design-system §6), inline errors, submit-summary, autosave. Supports multi-step (`List<FormStep>`) with a review step.

These three cover ~70% of enterprise CRUD app surface area. A new product configures them; it doesn't rebuild them.

---

## 9. Data layer

- **`Result<T>` / `Failure`** (`amds_core`): every repo method returns `Future<Result<T>>`; `Failure` is a `freezed` union (`network`, `timeout`, `unauthorized`, `forbidden`, `notFound`, `conflict`, `validation(fields)`, `server(traceId)`, `unknown`).
- **`ApiClient`**: `dio` + interceptors (auth token, retry with backoff, logging, `traceId` capture, connectivity check). Base URL from `AppConfig`.
- **Repositories**: interface in `features/*/data`, real impl (`*_api.dart`) + mock impl (`repositories_mock/`). The kit runs **100% on mocks** out of the box → designers/PMs can click through immediately; wiring a backend = implementing interfaces + one DI override.
- **Local**: `flutter_secure_storage` (tokens, biometrics), `shared_preferences`/`hive` (prefs, onboarding-seen, theme), optional `drift` for cached lists + offline draft queue.
- **Offline (v1, light)**: read-through cache for list/detail/dashboard; **draft autosave** for the form engine (encrypted local, resumes on return); an **outbox** for queued mutations (approve/create) that replays on reconnect with idempotency keys. Full bidirectional sync is a v2 concern (scalability).
- **Models**: `freezed` + `json_serializable`; `build_runner` in CI.

---

## 10. Theming, dark mode, white-label

### 10.1 Theme

- `MaterialApp.router(theme: AmdsTheme.light, darkTheme: AmdsTheme.dark, themeMode: ...)`.
- `themeControllerProvider` holds `{ ThemeMode, double textScale, Density }`, persisted; Settings changes apply live (200ms root crossfade, instant under reduced-motion).
- Dark mode per dark-mode — full semantic remap, surface-step elevation, verified contrast. Nothing hardcoded.
- `MediaQuery` wrapper clamps `textScaler` to AMDS range (0.85–2.0) app-wide while still respecting the user.

### 10.2 White-label / new-brand mechanism

`app_config` exposes a `BrandTheme` — a small override object applied on top of AMDS:

```dart
const acmeBrand = BrandTheme(
  name: 'Acme Field',
  primarySeed: Color(0xFF2563EB),        // regenerates the green->blue semantic ramp mapping
  logoAsset: 'assets/brand/acme_logo.svg',
  radiusScale: 1.0,                       // keep AMDS radius
  fontFamily: 'Inter',                    // or a brand face
  featureFlags: {'approvals': true, 'analytics': false},
);
```

- The theme builder takes `BrandTheme` → recolors **semantic** tokens (primitives + spacing + type scale stay shared) → produces `ThemeData`.
- A new product: copy `apps/_template`, drop in a `BrandTheme`, set `AppConfig` (name, bundle id, API base, flavors), flip feature flags, run the `amds_app` brick. No component or token forks.
- Contrast is re-validated per brand in CI (golden + a contrast test).

### 10.3 Flavors & env

- `flutter run --flavor dev -t lib/main_dev.dart` (+ staging, prod).
- Config via `--dart-define-from-file=config/dev.json` (no secrets in the repo; CI injects prod).
- Android product flavors + iOS schemes/configs generated by the `amds_app` brick.

---

## 11. Accessibility & i18n (built in, not bolted on)

- `amds_ui` widgets ship AMDS a11y (accessibility): semantics, 44dp targets, focus, reduced-motion, RTL, Dynamic Type. Features get it for free.
- `flutter_localizations` + `intl` + ARB from screen one; `app_en.arb` complete, `app_id.arb` stub; **no hardcoded user-facing strings** (custom lint rule).
- `Formatters` are locale + timezone aware (relative time from server clock).
- CI: `flutter test` includes `meetsGuideline(textContrastGuideline)`, `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline` on key screens.
- Manual gate per release: TalkBack + VoiceOver on the 3 core flows, 200% text, reduce-motion, RTL.

---

## 12. Testing strategy

| Layer | Tool | Coverage target |
|---|---|---|
| Token/theme | unit | generated tokens match `tokens.json`; light/dark schemes complete |
| Components (`amds_ui`) | **golden** (alchemist/golden_toolkit) — every widget × variant × state × {light,dark} × {1.0, 2.0 text} | 100% of components |
| Component behavior | widget tests | states, callbacks, a11y semantics, reduced-motion |
| Feature controllers | unit (Riverpod `ProviderContainer` + mock repos) | all state transitions, error mapping, optimistic + rollback |
| Feature screens | widget tests | renders each `UiState`; key interactions |
| Core flows | `integration_test` | (1) login → dashboard → open a priority → approve; (2) list → filter → open detail → edit → save; (3) create via form engine → submit → see in list |
| A11y | `meetsGuideline` in CI + manual checklist | key screens |
| Perf | `flutter test --profile` timeline + a manual min-spec pass | FMP, jank frames |

`melos run test` runs everything; `melos run test:golden` updates goldens.

---

## 13. Tooling & CI

- **Lint:** `very_good_analysis` + `riverpod_lint` + `custom_lint`; custom rules: no raw `Color(0x...)`/hex in `apps/`, no magic `EdgeInsets` numbers (must use `AmdsSpacing`), no hardcoded strings.
- **Format:** `dart format` enforced.
- **codegen:** `build_runner` (freezed, json, riverpod, go_router) — CI fails on stale generated code.
- **Melos scripts:** `bootstrap`, `analyze`, `test`, `test:golden`, `build:tokens`, `gen`, `widgetbook:build`.
- **CI (GitHub Actions / GitLab CI):**
  1. `melos bootstrap` → `analyze` → `build_runner` freshness → `build:tokens` freshness
  2. `test` (unit + widget + golden) with coverage gate
  3. `integration_test` on an emulator (core flows)
  4. a11y guideline tests
  5. build `apps/starter` for Android + iOS (no-sign) to catch breakage
  6. deploy Widgetbook (web) as a review artifact
  7. on tag: bump package versions (`melos version`), publish internal packages, build signed flavors (Fastlane), upload to TestFlight / Play internal
- **Renovate/Dependabot** for dep updates; monthly `flutter upgrade` check.

---

## 14. Developer workflow — "new app in a day"

```
1. tool/new_app.sh acme_field            # or: mason make amds_app
     → copies apps/_template → apps/acme_field
     → sets package name, bundle ids, flavors, entrypoints
2. Edit apps/acme_field/lib/brand.dart    # BrandTheme: color seed, logo, font
3. Edit AppConfig                         # name, api base, feature flags
4. melos bootstrap && melos run gen
5. flutter run --flavor dev -t lib/main_dev.dart   # working app: splash, login, dashboard, settings
6. mason make amds_feature --name work_orders       # generate the first real feature
     → configure RecordListConfig + RecordDetailConfig + FormSchema
     → implement WorkOrderRepository (or start on the mock)
7. Wire the feature route into app_router.dart (brick does a first pass)
8. Ship dev build; iterate.
```

Everything the AMDS docs promise (a11y, dark mode, adaptive nav, deep links, i18n, state screens) is already working in step 5.

---

## 15. Package dependency picks (v1)

| Concern | Package | Why |
|---|---|---|
| State / DI | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`, `riverpod_lint` | testable, compile-safe DI, code-gen |
| Routing | `go_router` | official, deep links, ShellRoute, redirect guards |
| Models | `freezed`, `json_serializable` | immutability, unions, JSON |
| Network | `dio` | interceptors, cancel tokens, retry |
| Local | `flutter_secure_storage`, `shared_preferences` (+ `drift` optional) | tokens vs prefs vs cache |
| i18n | `flutter_localizations`, `intl` | standard |
| Charts | `fl_chart` | dashboard trend/sparkline; wrapped by `AmdsChartCard` |
| Icons | `material_symbols_icons` (+ custom SVG set via `flutter_svg`) | AMDS iconography (design-foundations §6) |
| Catalog | `widgetbook` (+ `widgetbook_generator`) | component gallery + golden source |
| Monorepo | `melos` | scripts, versioning, bootstrap |
| Lints | `very_good_analysis`, `custom_lint` | strict, extensible |
| Testing | `mocktail`, `alchemist`/`golden_toolkit`, `integration_test` | mocks + goldens + e2e |
| Tooling | `mason` / `mason_cli` | scaffolding bricks |
| Splash / launch | `flutter_native_splash` | native splash per screen-library §1 |
| Connectivity | `connectivity_plus` | offline banner + outbox trigger |

Avoid for v1: heavyweight offline-sync frameworks, `get`/`getx`, hand-rolled DI, multiple state libs.

---

## 16. Scalability & roadmap (aligns with scalability)

| Phase | Additions |
|---|---|
| **v1.0 (this spec)** | Packages, 3 engines, 13 screens on mock data, theming/white-label, adaptive nav, a11y+i18n, golden+e2e tests, CI, bricks |
| **v1.1** | Real-API adapters for the reference app; biometric auth module; push notifications module; analytics adapter (Firebase/Amplitude) |
| **v1.2** | Robust offline: `drift` cache + outbox with conflict UI (form-design-system §4.3); background sync |
| **v1.3** | `amds_ui` for large screens: two-pane list-detail, data table widget (data-display), master-detail routing |
| **v2.0** | Tokens Studio ↔ Git two-way sync; `amds_ui` published to a private pub server with changelogs + codemods; contract tests (Figma props == widget API) |
| **Ongoing** | New `BrandTheme`s per product; quarterly dependency + Flutter SDK bump; component additions via RFC; adoption dashboard across product apps |

**Risk mitigations:** token source stays open JSON (no Flutter lock-in of decisions); every screen is documented against the AMDS templates; the three engines are versioned and covered by goldens so refactors are safe; `_template` app keeps the "clone" path always green.

---

## 17. Definition of done (the starter kit itself)

- [ ] `melos bootstrap && melos run test` green from a clean clone
- [ ] `apps/starter` runs on Android + iOS, all 13 screens reachable, mock data flows end-to-end
- [ ] `apps/_template` runs (splash → login → dashboard → settings) and is documented as the clone target
- [ ] `tool/build_tokens.dart` regenerates `amds_tokens` from `design-tokens/tokens.json`; CI checks freshness
- [ ] Widgetbook lists every `amds_ui` component × variant × state, light + dark; deployed in CI
- [ ] Golden tests cover 100% of components (light/dark, 1.0/2.0 text)
- [ ] 3 integration flows pass on an emulator in CI
- [ ] a11y guideline tests pass; manual TalkBack/VoiceOver pass on core flows
- [ ] Dark mode QA checklist (dark-mode) passes on every screen
- [ ] Adaptive nav verified at phone / tablet-portrait / tablet-landscape
- [ ] Deep links resolve with correct synthesized back stacks
- [ ] `mason` bricks (`amds_app`, `amds_feature`, `amds_screen`) generate compiling, test-passing code
- [ ] `new_app.sh` produces a runnable branded app in < 15 min
- [ ] README + this spec + per-package READMEs current
- [ ] No lint violations; no hardcoded colors/dimens/strings in `apps/`
