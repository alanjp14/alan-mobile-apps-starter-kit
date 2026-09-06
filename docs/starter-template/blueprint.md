# 17 · Mobile Application Starter Blueprint

> Foundation: **AMDS v1.0**. The end-to-end blueprint for standing up a new **Android + iOS** enterprise app: Clean Architecture · feature-based · scalable enterprise pattern · **offline-first** · production-ready.
> Cross-platform implementation for **Jetpack Compose**, **Flutter**, **React Native**.

**This document composes the rest of the system — follow the pointers, don't duplicate:**

| Concern | Authoritative doc |
|---|---|
| Design tokens & theming values | [`../../design-tokens/`](../../design-tokens/) · [`02-design-foundations.md`](../design-system/README.md) · [`11-dark-mode.md`](../design-system/dark-mode.md) |
| Components (design) | [`03-component-library.md`](../component-library/README.md) |
| Components (engineering API + platform mappings) | [`16-component-api-reference.md`](../component-library/api-reference.md) |
| Screens (40 templates, 8 archetypes) | [`screen-library/`](../screen-library/README.md) |
| Features (15 blueprints: biz flow · data · API · state · security · scale) | [`feature-library/`](../feature-library/README.md) |
| Navigation system (patterns) | [`04-navigation-system.md`](../design-system/navigation-patterns.md) |
| Folder structure (per platform, full trees) | [`14-folder-structure.md`](../starter-template/project-structure.md) |
| Flutter reference implementation | [`specs/flutter-starter-kit.md`](../specs/flutter-starter-kit.md) |
| Offline sync (tiers, outbox, conflicts) | [`feature-library/08-offline-sync.md`](../feature-library/08-offline-sync.md) |
| Handoff, token pipeline | [`12-developer-handoff.md`](../starter-template/developer-handoff.md) |

---

## 0. Architecture at a glance

```
┌─────────────────────────────────────────────────────────────────────┐
│ PRESENTATION   screen (stateless) ── ViewModel/Notifier/hook ── UiState │  Compose / SwiftUI / Widgets / RN
├─────────────────────────────────────────────────────────────────────┤
│ DOMAIN         entities · use cases · repository interfaces · Result<T> │  pure, no framework imports
├─────────────────────────────────────────────────────────────────────┤
│ DATA           repository impl ── { RemoteDataSource (API) · LocalDataSource (DB) · Outbox } │
├─────────────────────────────────────────────────────────────────────┤
│ CORE / PLATFORM  DI · theme · network client · secure storage · logger · analytics · push · connectivity · sync engine │
└─────────────────────────────────────────────────────────────────────┘
                    features/  →  each feature owns a vertical slice of all four layers
```

**Principles**
1. **Dependency rule** — dependencies point inward. Domain knows nothing of data or presentation. Presentation depends on domain, not data.
2. **Feature-first** — folders are business capabilities (`assets`, `approvals`), not layers (`screens`, `models`). Each feature is a mini clean-architecture stack + its routes + its tests.
3. **Offline-first** — every repository read is cache-first; every write goes through the outbox (see §9, §10, and [`feature-library/08`](../feature-library/08-offline-sync.md)).
4. **Stateless UI** — a screen renders a `UiState` and emits intents; a ViewModel/Notifier/hook owns state and side effects. No business logic or network calls in widgets.
5. **Token-driven** — no hardcoded colors/dimensions/strings in feature code (lint-enforced).
6. **Additive change** — new features add modules; shared code graduates into `core/*` via review + version bump.

**Stack decisions**

| Concern | Jetpack Compose (native) | Flutter | React Native |
|---|---|---|---|
| Language | Kotlin 2.x | Dart 3.x | TypeScript 5.x (strict) |
| UI | Compose + Material 3 | Flutter + Material 3 | RN + a themed component lib |
| DI | Hilt | Riverpod (providers) + `riverpod_generator` | React Context + a service locator |
| State | ViewModel + `StateFlow` | Riverpod 2 (`@riverpod` AsyncNotifier) | Zustand (client) + TanStack Query (server) |
| Navigation | Navigation-Compose (typed) + `NavigationSuiteScaffold` | `go_router` (ShellRoute, guards, deep links) | React Navigation (native-stack + tabs/drawer) |
| Networking | Retrofit + OkHttp + kotlinx.serialization | `dio` + `retrofit`/`chopper` + `freezed`/`json_serializable` | `axios` + `zod` |
| Local DB | Room (SQLCipher) | Drift (SQLCipher) or Isar | WatermelonDB (offline-first) or `op-sqlite` |
| Async | Coroutines + Flow | Futures/Streams + Isolates (`compute`) | Promises + Reanimated worklets |
| Images | Coil | `cached_network_image` | FastImage / Expo Image |
| Monorepo | Gradle modules | Melos packages | Nx / Yarn workspaces (optional) |

Pick native (Compose + SwiftUI) when platform fidelity / deep OS integration dominates; Flutter or RN when one team must ship both fast. This blueprint parameterizes on that choice.

---

## 1. Folder Structure

Full per-platform trees live in [`14-folder-structure.md`](../starter-template/project-structure.md). The canonical shape:

### 1.1 Repository (monorepo, per app)

```
<app>/
├── app/ (or lib/, or src/)          composition root: DI, router, theme wiring, flavor entrypoints
├── core/                            cross-feature infrastructure (see §2 responsibilities)
│   ├── designsystem/  theme/  components/  icons/
│   ├── network/       client, interceptors, error mapping
│   ├── database/      db, DAOs, migrations, encryption
│   ├── datastore/     secure storage, key-value prefs
│   ├── sync/          SyncEngine, Outbox, conflict resolver
│   ├── auth/session/  SessionManager, guards, token store
│   ├── common/        Result, Failure, dispatchers, formatters, validators, extensions
│   ├── logging/       Logger, ring buffer, sinks
│   ├── analytics/     Analytics interface + adapters
│   ├── push/          PushService, message handlers, deep-link router
│   └── navigation/    route registry, deep-link graph, adaptive nav host
├── features/
│   └── <feature>/
│       ├── presentation/  screen · viewmodel/controller · uistate · widgets
│       ├── domain/        entities · usecases · repository (interface)
│       ├── data/          repository impl · remote datasource · local datasource · dtos · mappers
│       └── <feature>_test.*   unit + widget + golden
├── config/                          env files (dev/staging/prod), no secrets
├── build/ or tool/                  token build, codegen, scripts
└── <platform test dirs>             integration/e2e, snapshot baselines
```

### 1.2 Feature module contract (generated by a scaffold: Mason brick / Gradle template / plop)

```
features/assets/
├── presentation/
│   ├── asset_list_page.*            stateless; reads AssetListUiState
│   ├── asset_list_controller.*      owns fetching, paging, filter, selection
│   ├── asset_list_state.*           sealed/freezed UiState
│   ├── asset_detail_page.* / _controller.* / _state.*
│   ├── asset_form_page.*            FormEngine(FormSchema)
│   └── widgets/                     screen-local composables only
├── domain/
│   ├── asset.*                      entity (immutable)
│   ├── asset_repository.*           interface — the ONLY thing presentation imports from data's world
│   └── usecases/  get_assets.* · create_asset.* · check_out_asset.*
├── data/
│   ├── asset_repository_impl.*      cache-first read; outbox write
│   ├── asset_remote_data_source.*   Retrofit/dio/axios
│   ├── asset_local_data_source.*    Room/Drift/WatermelonDB DAO
│   ├── dto/  asset_dto.* (+ mapper to/from entity)
│   └── asset_di.*                   provides the impl (or a Hilt module)
├── asset_routes.*                   route defs + deep links (registered centrally)
└── tests
```

**Rule:** `features/<a>` never imports `features/<b>`. Cross-feature needs go through `core/` or a domain event.

### 1.3 Platform notes
- **Compose:** enforce with Gradle modules `:core:*`, `:feature:*`, `:app`; a convention plugin; `dependency-analysis` / Konsist tests to assert the dependency rule.
- **Flutter:** Melos packages `packages/core_*`, `packages/feature_*` (optional) or top-level `lib/features/*` with `import_lint` rules; `dart_code_metrics` / a custom lint to forbid cross-feature imports.
- **React Native:** `src/core/*`, `src/features/*`; `eslint-plugin-boundaries` to enforce layer + feature isolation; path aliases (`@core/*`, `@features/*`).

---

## 2. `core/` responsibilities

| Module | Owns | Exposes |
|---|---|---|
| `designsystem` | AMDS theme, components ([`16`](../component-library/api-reference.md)), icons, adaptive layout | `AmdsTheme`, `Amds*` widgets, `AppIcons` |
| `network` | HTTP client, auth/retry/logging/idempotency interceptors, `problem+json` → `Failure` mapping, connectivity-aware | `ApiClient`, `NetworkResult` |
| `database` | encrypted DB, migrations, `cache_*` + `outbox_op` + `sync_state` tables | DAOs / query objects |
| `datastore` | secure storage (tokens, keys), non-secret prefs | `SecureStore`, `PrefsStore` |
| `sync` | `SyncEngine`, `Outbox`, delta pull, conflict resolution | `SyncStatus` stream, `enqueue(op)` |
| `auth/session` | `SessionManager` (`status/user/permissions/tenant`), token lifecycle, guards, step-up | `SessionState` stream, `can(permission)` |
| `common` | `Result<T>` / `Failure` union, dispatchers, `Formatters` (date/number/currency, locale+tz aware), `Validators`, extensions | pure utilities |
| `logging` | `AppLogger`, in-memory ring buffer (for Contact Support), sinks (console/file/crash) | `log.d/i/w/e` |
| `analytics` | `Analytics` interface, consent gating, event schema | `track(event)` |
| `push` | `PushService`, token register/deregister, foreground/background handlers, `NotificationDeepLinkRouter` | `permissionStatus` |
| `navigation` | route registry, deep-link parser, adaptive nav host, back-stack synthesis | `AppRouter` |

---

## 3. Navigation Structure

Patterns: [`04-navigation-system.md`](../design-system/navigation-patterns.md). Deep-link scheme: [`04 §9`](../design-system/navigation-patterns.md).

### 3.1 Route model

- **Typed routes**, defined per feature, aggregated in `core/navigation`. No stringly-typed navigation.
- Two graphs: **`AuthGraph`** (splash, onboarding, login, register, forgot/reset, verify — no bottom nav) and **`AppGraph`** (a `ShellRoute` hosting the adaptive nav + all feature routes).
- **Guards / redirects:** unauthenticated → `/login` (store `pendingDeepLink`); missing permission → `/denied`; forced password change → `/security/change-password`; unknown → `/not-found`.
- **Adaptive shell:** bottom nav (phone) → nav rail (tablet portrait) → persistent drawer (tablet landscape), by window size class ([`04 §2`](../design-system/navigation-patterns.md)).
- **Deep links:** `[app-scheme]://<app>/<section>/<resource>/<id>?<params>` + verified `https://` App Links / Universal Links; **synthesize the back stack** on entry (Dashboard → List → Detail).
- **Back:** temporal (reverse last navigation); modals use `close` not back-arrow; dirty-form guard on dismiss.
- **State preservation:** list filters/sort/scroll and selected tab preserved per session.

### 3.2 Route registry (concept)

```
routes = [
  Route("/",                 SplashScreen),
  Route("/login",            LoginScreen,           graph = Auth),
  Route("/dashboard",        DashboardScreen,       graph = App, tab = Home),
  Route("/{type}",           DataListScreen,        graph = App, deepLink = true),
  Route("/{type}/{id}",      DataDetailScreen,      graph = App, deepLink = true, backStack = ["/dashboard","/{type}"]),
  Route("/{type}/new",       CreateFormScreen,      graph = App, requires = "{type}:create"),
  Route("/{type}/{id}/edit", EditFormScreen,        graph = App, requires = "{type}:update"),
  Route("/approvals",        ApprovalQueueScreen,   graph = App, tab = Approvals, badge = pendingApprovals),
  Route("/approvals/{id}",   ApprovalDetailScreen,  graph = App, deepLink = true),
  Route("/notifications",    NotificationListScreen,graph = App),
  Route("/profile",          ProfileScreen,         graph = App, tab = More),
  Route("/settings/**",      …,                     graph = App),
  Route("/help/**",          …,                     graph = App),
  Route("/sync/pending",     PendingChangesScreen,  graph = App),
  Route("/denied", "/not-found", ErrorScreens),
]
```

### 3.3 Platform

| | Compose | Flutter | React Native |
|---|---|---|---|
| Library | `androidx.navigation:navigation-compose` (type-safe routes, Kotlin serialization) | `go_router` | `@react-navigation/native` + `native-stack` |
| Adaptive shell | `NavigationSuiteScaffold` + `WindowSizeClass` | `ShellRoute` + `LayoutBuilder` → `AmdsAdaptiveNavigation` | conditional `BottomTabs` / custom rail / `Drawer` via `useWindowDimensions` |
| Guards | a `NavController` wrapper / a start-destination decider observing `SessionState` | `GoRouter(redirect:)` reading `sessionControllerProvider` | a root navigator switching `AuthStack`/`AppStack` on session |
| Deep links | `navDeepLink { uriPattern }` + `<intent-filter>` (App Links, `autoVerify`) | `GoRouter` paths + `uni_links`/AndroidManifest/`apple-app-site-association` | `linking: { prefixes, config }` + native link setup |
| Transitions | `AmdsPageTransitions` (shared-axis / fade), reduced-motion aware | `CustomTransitionPage` + `animations` pkg | Reanimated / native-stack animations |
| Back-stack synth | build the stack in the deep-link handler before `navigate` | `GoRouter` `redirect` returning a stack, or `.go()` with `extra` | `navigation.reset({ routes: [...] })` |

---

## 4. Theme Structure

Values & rules: [`02-design-foundations.md`](../design-system/README.md), [`11-dark-mode.md`](../design-system/dark-mode.md). Token files: [`../../design-tokens/`](../../design-tokens/).

### 4.1 Layers

```
tokens.json (W3C DTCG, source of truth)
   └─ Style Dictionary build → per-platform theme files (committed in tokens/)
        ├─ primitives     raw ramps/scale — never used directly
        ├─ semantic       theme-aware aliases (primary, surface, textSecondary…) — used everywhere
        └─ component       scoped overrides when needed (button.primary.bg)
```

### 4.2 Runtime theme controller

`ThemeController` state (device-local, persisted): `{ mode: system|light|dark, textScale (clamp 0.85–2.0), density: comfortable|compact, boldText, highContrast, brandId? }`.
- Applied **live** (200ms root crossfade; instant under reduced-motion).
- `System` tracks the OS in real time (including scheduled dark).
- A `MediaQuery`/`Configuration` wrapper clamps text scale app-wide while still honoring the user.
- **White-label:** a `BrandTheme { primarySeed, logo, font, radiusScale?, featureFlags }` recolors **semantic** tokens only; primitives/spacing/type stay shared; contrast re-validated per brand in CI ([`specs/flutter-starter-kit.md §10.2`](../specs/flutter-starter-kit.md)).

### 4.3 Platform

| | Compose | Flutter | React Native |
|---|---|---|---|
| Entry | `AmdsTheme(darkTheme, textScale) { }` — `MaterialTheme` + CompositionLocals (`AmdsTheme.colors/spacing/radius/elevation`) | `MaterialApp(theme: AmdsTheme.light, darkTheme: AmdsTheme.dark, themeMode)` + `AmdsThemeExt` `ThemeExtension`; `context.amds.*` | `<ThemeProvider>` over `amdsLight`/`amdsDark` (theme.ts); `useTheme()` |
| Dark | `isSystemInDarkTheme()` + override store; set system bar contrast | `themeMode` from `ThemeController`; `SystemUiOverlayStyle` | `useColorScheme()` + override; `react-native-edge-to-edge`, `StatusBar` |
| Fonts | bundle Inter in `res/font/`; `FontFamily` | `pubspec` `fonts:` | `react-native.config.js` assets / `expo-font` |
| Dynamic type | `sp` units; test 100/130/200 + Bold | `MediaQuery.textScaler` (auto); clamp globally | `allowFontScaling` (default) + `maxFontSizeMultiplier` |
| Files | [`../tokens/Theme.kt`](../../design-tokens/platforms/Theme.kt) | [`../tokens/amds_theme.dart`](../../design-tokens/platforms/amds_theme.dart) | [`../tokens/theme.ts`](../../design-tokens/platforms/theme.ts) |

Lint rule (all): **no raw hex / no magic dp / no hardcoded user-facing strings** in `features/`.

---

## 5. Component Structure

Design specs: [`03-component-library.md`](../component-library/README.md). Engineering API + per-platform code: [`16-component-api-reference.md`](../component-library/api-reference.md).

### 5.1 Layering

```
core/designsystem/components/          Amds* widgets — the ONLY visual primitives features use
   ├─ actions/     AmdsButton, AmdsIconButton, AmdsFab
   ├─ inputs/      AmdsTextField, AmdsPasswordField, AmdsDropdown, AmdsSearchField, AmdsCheckbox…
   ├─ containment/ AmdsCard, AmdsKpiCard, AmdsChartCard, AmdsProfileCard, AmdsListTileX
   ├─ feedback/    AmdsDialog, AmdsBottomSheet, AmdsSnackbar, AmdsBanner, AmdsTooltip, AmdsBadge, AmdsAvatar
   ├─ progress/    AmdsSpinner, AmdsProgressBar, AmdsSkeleton*
   ├─ layout/      AmdsScaffold, AmdsAdaptiveNavigation, AmdsResponsive, AmdsPullToRefresh
   ├─ state/       AmdsEmptyState, AmdsErrorState, AmdsOfflineBanner, AmdsPermissionDeniedState
   ├─ timeline/    AmdsTimeline
   └─ motion/      AmdsPageTransitions, AmdsAnimatedCount, AmdsFadeSlideIn
core/designsystem/engines/             the 3 reusable engines
   ├─ list/    RecordListConfig + DataListScreen
   ├─ detail/  RecordDetailConfig + DataDetailScreen
   └─ form/    FormSchema + FormEngine
features/*/presentation/widgets/       screen-LOCAL composites only (never promoted without review)
```

### 5.2 Rules
- Every `Amds*` widget: the universal prop set + universal states + a11y baseline + reduced-motion + RTL + Dynamic Type ([`16 §0`](../component-library/api-reference.md)).
- Components **never** call the network, read stores, or navigate — they take data + callbacks.
- A **component catalog** (Widgetbook / Storybook / Paparazzi gallery) renders every component × variant × state × {light,dark} × {1.0,2.0 text}; deployed per PR; doubles as the golden-test source.
- Adding/changing a component follows the DoD checklist ([`03 §G`](../component-library/README.md)).

### 5.3 Platform
- **Compose:** components in `:core:designsystem`; preview functions per variant; Paparazzi/Roborazzi goldens.
- **Flutter:** `packages/amds_ui`; Widgetbook + `alchemist` goldens.
- **React Native:** `src/core/designsystem` (or a package); Storybook + Chromatic / RN snapshot.

---

## 6. State Management Structure

Framework: [`feature-library/00-framework.md §2.3`](../feature-library/00-framework.md).

### 6.1 The `UiState` contract (every data screen)

```
sealed UiState<T> {
  Loading(previous: T?)          // show skeleton or keep previous + shimmer
  Data(value: T, stale: Bool)    // stale → "as of HH:MM" marker
  Empty(reason: FirstRun|NoResults|NoPermission)
  Error(failure: Failure, retryable: Bool)
}
// Dashboards compose per-block: DashboardUiState { blocks: { kpis: BlockState<..>, ... } }  (specs/dashboard.md §9.1)
```

### 6.2 Layers of state

| Layer | Scope | Holder |
|---|---|---|
| **Server cache** | app | query cache (TanStack Query) / repository + DB (`Flow`/`Stream` single source of truth) — `staleTime` 30–60s, optimistic `onMutate` + rollback |
| **Screen state** | one screen | ViewModel / Notifier / hook → exposes one `UiState` + intent methods |
| **Session** | app | `SessionManager` → `{ status, user, permissions, tenantId, pendingDeepLink }` |
| **Theme** | app | `ThemeController` (device-local) |
| **Sync** | app | `SyncEngine` → `SyncStatus { state, pendingCount, failedCount, conflictCount, lastSyncAt }` |
| **Feature flags / config** | app | `AppConfig` + `FeatureFlags` provider |
| **Connectivity** | app | `Connectivity` provider |
| **Ephemeral UI** | one widget | local (`remember` / `useState` / `setState`) — a toggle, an animation, an unsent draft only |

### 6.3 Rules
- Screens are **stateless**: read one state object, call intents. No `setState` for anything non-trivial; no `BuildContext`/`Context` in controllers.
- Side effects (snackbars, navigation on auth loss) via a one-shot event channel (`Channel`/`ref.listen`/`useEffect`), not state flags.
- Repositories are the single source of truth for domain data; the DB emits reactive queries; the network updates the DB.
- Optimistic updates always paired with rollback; every mutation carries an `Idempotency-Key`.

### 6.4 Platform

| | Compose | Flutter | React Native |
|---|---|---|---|
| Screen state | `ViewModel` + `StateFlow<UiState>` + `collectAsStateWithLifecycle()` | Riverpod `@riverpod` `AsyncNotifier` → `AsyncValue<UiState>` | a `useXxx` hook: Zustand slice + TanStack Query |
| Server cache | Repository + Room `Flow` (SSOT); no separate cache lib needed | Repository + Drift `watch()`; or `riverpod` `keepAlive` + manual `staleTime` | **TanStack Query** (`useQuery`/`useMutation`, `persistQueryClient`) |
| DI | Hilt (`@HiltViewModel`, modules) | Riverpod providers (compile-safe) + `riverpod_generator` | Context providers + a small service locator |
| Events | `Channel` → `receiveAsFlow()` | `ref.listen` + a `StreamController` for one-shots | `useEffect` on a state field, or an event emitter |
| Lint | `detekt` + a rule: no android imports in domain | `custom_lint` + `riverpod_lint` | `eslint-plugin-boundaries` |

---

## 7. API Layer Structure

Conventions: [`feature-library/00-framework.md §2.1`](../feature-library/00-framework.md).

```
core/network/
├── ApiClient                 base URL from AppConfig; JSON (kotlinx/freezed/zod); gzip
├── interceptors/
│   ├── AuthInterceptor        attach Bearer; on 401 → single-flight refresh → retry once → else logout
│   ├── IdempotencyInterceptor add Idempotency-Key on POST/PATCH/DELETE (from the outbox op or a fresh uuid)
│   ├── EtagInterceptor        add If-Match from the entity's cached etag on writes
│   ├── LoggingInterceptor     structured, redacts Authorization/PII, includes traceId
│   ├── RetryInterceptor       5xx/timeout → exp backoff + jitter, capped
│   └── ConnectivityInterceptor  fail fast when offline → typed NetworkFailure
├── ErrorMapper               problem+json → Failure union (validation/unauthorized/forbidden/notFound/conflict/server/…)
├── CertPinning               pin the API host + a backup pin + remote kill-switch
└── generated/                typed clients from OpenAPI (Retrofit / retrofit_dart / openapi-generator-ts)
features/<f>/data/<f>_remote_data_source  → thin wrapper over the generated client; returns Result<Dto>
```

**Rules**
- One OpenAPI 3 contract; **generate** typed clients — no hand-written request builders.
- Every remote call returns `Result<T>` (never throws to the caller); errors are the `Failure` union.
- Pagination: keyset (`?limit=&cursor=` → `{ items, nextCursor }`).
- No secrets in the app; base URLs per flavor via `config/*.json` (`--dart-define-from-file` / `BuildConfig` / `react-native-config`).
- Realtime: a `RealtimeClient` (WebSocket/SSE) in `core/network` exposing `Flow<DomainEvent>` per channel; reconnect with backoff; fall back to polling.

| | Compose | Flutter | React Native |
|---|---|---|---|
| Client | Retrofit + OkHttp + `kotlinx.serialization` converter | `dio` + `retrofit`/`chopper` + `json_serializable` | `axios` (or `ky`) + `zod` parse at the boundary |
| Codegen | `openapi-generator` (kotlin) | `openapi-generator` / `chopper_generator` / `retrofit_generator` | `openapi-typescript` + `openapi-fetch` |
| Interceptors | OkHttp `Interceptor` + `Authenticator` | `dio` `Interceptor` + a `Lock`/`Completer` | axios interceptors + a refresh queue |
| Cert pinning | OkHttp `CertificatePinner` | `dio` `badCertificateCallback` / `http` + pinning, or a native plugin | `react-native-ssl-pinning` / `react-native-cert-pinner` |
| Realtime | OkHttp WebSocket / `okhttp-sse` | `web_socket_channel` / SSE via `http` | `reconnecting-websocket` / `react-native-sse` |

---

## 8. Repository Layer Structure

Offline-first contract ([`feature-library/08 §9`](../feature-library/08-offline-sync.md)).

```
domain/<f>_repository (interface)         // presentation depends on THIS
data/<f>_repository_impl:
  read(id/query):
    1. emit from LocalDataSource (cache) immediately  → UiState.Data(stale = isStale(cachedAt))
    2. if online & stale → RemoteDataSource.fetch → map DTO→entity → LocalDataSource.upsert → re-emit
    3. on remote error → keep cache, surface a non-blocking error
  mutate(create/update/delete/action):
    1. validate locally
    2. LocalDataSource.upsert(optimistic, dirty = true)
    3. Outbox.enqueue(op{ entity, base_etag, idempotency_key, depends_on })
    4. return Result.Success(optimistic)   // SyncEngine drains later
  (SyncEngine on reconnect: drain outbox → reconcile cache → pull deltas)
```

**Rules**
- The repository is the **only** place that knows about remote vs local; use cases and presentation see one interface.
- DTOs never leak past `data/`; map to domain entities at the boundary.
- Mock implementations ship for every repository → the app runs end-to-end offline on mock data from day one.
- Each feature declares its **offline tier** (T0–T3, [`feature-library/08 §2`](../feature-library/08-offline-sync.md)) per operation.
- Reads return reactive streams (`Flow`/`Stream`/a query hook) so the UI updates when the cache changes (from sync, from another screen).

| | Compose | Flutter | React Native |
|---|---|---|---|
| SSOT | Room `Flow` from DAO; repo combines with a network trigger | Drift `watch()`; repo combines with a fetch | TanStack Query cache backed by WatermelonDB/SQLite; `observe()` for reactive lists |
| Pattern helper | `NetworkBoundResource` (Kotlin) | a `syncedQuery` helper / `flutter_data` | a `useSyncedList` hook wrapping `useQuery` + local observe |
| Mocks | a `:core:testing` fake + Hilt test module | `repositories_mock/` + a Riverpod override | MSW + a mock adapter, or in-memory repos |

---

## 9. Local Database Structure

Detail: [`feature-library/08 §7`](../feature-library/08-offline-sync.md).

```
core/database/  (encrypted — SQLCipher / Realm encryption / encrypted adapter)
├── cache_<entity>        id, payload(json or columns), etag, cached_at, dirty, pending_op_id?
├── outbox_op             id(uuid), created_at, entity_type, entity_id, op, payload, base_etag,
│                         idempotency_key, depends_on, state(pending/inflight/failed/conflict/done),
│                         attempts, next_attempt_at, error, conflict_snapshot
├── sync_state            entity_type, last_sync_cursor, last_sync_at
├── id_map                client_id ↔ server_id  (offline-created references)
├── attachment_queue      (File Upload feature)
├── kv                    small misc (feature-scoped)
└── migrations/           versioned, tested up-migrations (never destructive without a plan)
```

**Rules**
- **Encrypt at rest.** DB key in the secure enclave; optionally gate DB open behind biometrics for high-security tenants.
- Store only the **authorized working set** (user's sites, recent/assigned records) — never bulk-download a tenant; scope-scof eviction by count + age.
- Migrations are versioned, forward-only, and covered by a migration test (open an old DB, migrate, assert).
- Wipe completely on sign-out / account switch / deactivation / remote wipe.
- Reactive queries only (`Flow`/`Stream`/observers) so the UI reflects cache changes.

| | Compose | Flutter | React Native |
|---|---|---|---|
| Library | **Room** + `net.zetetic:android-database-sqlcipher` (or `androidx.sqlite` + BoringSSL) | **Drift** + `sqlcipher_flutter_libs`, or **Isar** | **WatermelonDB** (built for sync) or `op-sqlite` + SQLCipher; `expo-sqlite` for Expo |
| Key storage | Keystore-wrapped passphrase in EncryptedSharedPreferences | `flutter_secure_storage` | `react-native-keychain` |
| Migrations | Room `Migration` classes + `MigrationTestHelper` | Drift `MigrationStrategy` + tests | WatermelonDB schema migrations / manual SQL |
| Big/offline-first | Paging 3 `RemoteMediator` | `drift` + `infinite_scroll_pagination`; `powersync`/`realm` for turnkey T3 | WatermelonDB sync adapter; PowerSync/RxDB for turnkey |

---

## 10. Error Handling Structure

```
core/common/
├── Failure (sealed/union):
│   Network | Timeout | Unauthorized | Forbidden | NotFound | Conflict(currentResource)
│   | Validation(fieldErrors: Map<field, message>) | Server(traceId) | Offline | Unknown
├── AppException  (thrown only at true boundaries; caught and mapped to Failure)
└── Result<T> = Success(T) | Error(Failure)     // the currency between layers
```

**Flow**
1. **Data layer** never throws to callers → returns `Result`. HTTP/DB exceptions are caught and mapped by `ErrorMapper`.
2. **Domain/use case** propagates `Result`; may add domain-specific failures.
3. **Presentation** maps `Failure` → a `UiState.Error` (retryable?) or an inline field error (`Validation`) or a one-shot event (Snackbar for transient, Dialog for blocking).
4. **UI rendering** ([`screen-library/00-framework §6.1`](../screen-library/00-framework.md)):
   - `Validation` → inline under the field, focus the first error, announce.
   - `Network`/`Offline` → the standard offline Banner + cache "as of HH:MM".
   - `Server` → `AmdsErrorState` / Banner + **Retry** + a copyable `traceId` for support.
   - `Conflict` → the conflict-resolution UI ([`08 §6`](../feature-library/08-offline-sync.md)), never a silent overwrite.
   - `Unauthorized` → silent refresh → else save drafts + route to Login.
   - `Forbidden` → `AmdsPermissionDeniedState` with who to contact.
5. **Global safety net:** a top-level uncaught-handler (`runZonedGuarded` / `Thread.setDefaultUncaughtExceptionHandler` / an error boundary) → log + crash-report + a graceful "Something went wrong — Restart" screen (never a white screen).
6. **Distinguish "your fault" (validation, phrased helpfully) from "our fault" (system, apologetic + trace id).** Never show raw stack traces or error codes to users.

| | Compose | Flutter | React Native |
|---|---|---|---|
| Result type | `sealed interface Result` (or Arrow `Either`) | `freezed` union / `Result` from `dartz`/`fpdart` | a discriminated union type + `neverthrow` optional |
| Global handler | `runCatching` at VM edges + `Thread.setDefaultUncaughtExceptionHandler` + Compose `ErrorBoundary`-like wrapper | `runZonedGuarded` + `FlutterError.onError` + `PlatformDispatcher.onError` | `ErrorUtils.setGlobalHandler` + React `ErrorBoundary` + `react-native-exception-handler` |
| Screen fallback | an `AmdsErrorState` composable per screen | `AsyncValue.when(error:)` → `AmdsErrorState` | `<ErrorBoundary fallback={<AmdsErrorState/>}>` per route |

---

## 11. Logging Structure

```
core/logging/
├── AppLogger                 log.v/d/i/w/e(tag, message, throwable?, fields: Map)
├── RingBuffer                in-memory, last ~500 lines / N minutes → Contact Support attaches this (scrubbed)
├── sinks/
│   ├── ConsoleSink           debug builds only, pretty
│   ├── FileSink              rotating, size-capped, debug/internal builds; NOT prod by default
│   └── CrashSink             breadcrumbs → the crash reporter (Crashlytics/Sentry)
└── Redactor                  strips tokens, Authorization, emails, phone, ids flagged sensitive
```

**Rules**
- **Structured** logs (`event`, `traceId`, `feature`, `screen`, key fields) — not string soup.
- **Levels:** `v/d` compiled out or disabled in release; `i` for lifecycle/nav/sync milestones; `w` for handled degradations; `e` for unexpected (also → crash reporter as a non-fatal).
- **Never log** credentials, tokens, PII, full request/response bodies, or DB rows. The `Redactor` runs on every sink.
- **traceId** flows from the network layer into logs and is surfaced in error UIs for support.
- Prod devices don't write files by default; "Share diagnostic logs" (Contact Support) pulls the scrubbed ring buffer with explicit consent.
- Crash + ANR + slow-frame reporting on in prod (consent-gated where required).

| | Compose | Flutter | React Native |
|---|---|---|---|
| Lib | Timber + a custom `Tree` per sink | `logger` / `logging` + custom outputs | a thin wrapper over `console` + `react-native-logs` |
| Crash | Firebase Crashlytics / Sentry (`sentry-android`) | `firebase_crashlytics` / `sentry_flutter` | `@sentry/react-native` / Crashlytics |
| Perf | Macrobenchmark + `JankStats` → traces | Flutter DevTools / `sentry` performance | Flipper / Sentry performance / `react-native-performance` |

---

## 12. Analytics Structure

Consent & schema: [`feature-library/06-account.md`](../feature-library/06-account.md) (Settings), event tables in each feature's doc.

```
core/analytics/
├── Analytics (interface)     track(event: AnalyticsEvent), setUserProps(...), screen(name)
├── AnalyticsEvent            typed events: sealed class / a registry — NOT free-form strings
├── adapters/  FirebaseAnalyticsAdapter | AmplitudeAdapter | SegmentAdapter | NoOpAdapter
├── ConsentGate              routes to NoOpAdapter when analytics consent is off
└── ScreenTracker            hooks navigation → screen_view events
```

**Rules**
- **One tracking module.** Events are **typed and defined alongside the feature** (`AnalyticsEvent.DashboardViewed(source, isColdLoad, …)`), with a documented schema (name, properties, when it fires).
- **No PII** in event names or properties; user is identified by an opaque id; respect the consent toggle (runtime gate, default per privacy stance + region).
- A naming convention: `object_action` snake_case (`kpi_tapped`, `approval_decided`, `export_requested`).
- Screen views auto-tracked from the router; funnel/conversion events explicit.
- Validate events in CI against the schema (a JSON schema or a codegen check).

| | Compose | Flutter | React Native |
|---|---|---|---|
| Default adapter | Firebase Analytics / Amplitude Kotlin | `firebase_analytics` / `amplitude_flutter` | `@react-native-firebase/analytics` / `@amplitude/analytics-react-native` |
| Screen hook | a `NavController` `OnDestinationChangedListener` → `analytics.screen()` | a `GoRouter` `observers: [AnalyticsObserver()]` | React Navigation `onStateChange` |
| Consent | swap the provider binding | swap the provider | swap the context value / call `setAnalyticsCollectionEnabled(false)` |

---

## 13. Push Notification Structure

Full feature: [`feature-library/03-notifications.md`](../feature-library/03-notifications.md) (Push Notifications).

```
core/push/
├── PushService              init · request permission (contextual, primed) · get token · register/deregister
├── TokenRegistrar          POST /me/push-tokens (on login, on refresh); DELETE on logout
├── MessageRouter           foreground → NotificationBus (in-app Banner / badge / list update, no dup OS banner)
│                           background data → SyncEngine.pullNow() / cache invalidation
├── DeepLinkRouter          data.entityRef → typed route (queued during cold start like pendingDeepLink)
├── Channels                one per notification category (importance mapped from priority)
└── BadgeSync               OS app-icon badge ← unreadCount (+ authoritative `badge` from payload)
```

**Rules**
- Register the token **after** sign-in; deregister on sign-out / account switch (so the previous user stops receiving).
- **Payloads carry opaque ids only** — no amounts, PII, or record content (visible on lock screen + provider logs); fetch-then-act after auth.
- Request permission at a contextual moment with a priming sheet, not on first launch; handle "denied" with a deep link to OS settings (surfaced in Notification Settings).
- Foreground messages never produce a duplicate OS banner — route to the in-app `NotificationBus`.
- Silent/data pushes only for genuine sync triggers; respect OS budgets.
- Provider credentials in a secrets manager, rotated.

| | Compose | Flutter | React Native |
|---|---|---|---|
| Lib | `firebase-messaging` + `NotificationCompat` + channels | `firebase_messaging` + `flutter_local_notifications` | `@react-native-firebase/messaging` + `notifee` |
| Token registration | `onNewToken` → `WorkManager` job | `onTokenRefresh` → provider | `onTokenRefresh` → mutation |
| Cold-start tap | `getIntent()` / `onNewIntent` → router | `getInitialMessage()` | `getInitialNotification()` |
| Background data | a `FirebaseMessagingService` / high-priority data message | a top-level `firebaseMessagingBackgroundHandler` | `setBackgroundMessageHandler` |
| Permission (A13+) | `POST_NOTIFICATIONS` runtime request | `requestPermission()` / `permission_handler` | `requestPermission()` / `PermissionsAndroid` |
| Badge | `ShortcutBadger` / `NotificationManager` | `flutter_app_badger` | `notifee.setBadgeCount` / iOS badge API |

---

## 14. Security Structure

Baseline: [`feature-library/00-framework.md §2.4`](../feature-library/00-framework.md). Per-feature threats in each feature doc's §12. Accessibility-of-auth: [`10-accessibility-guidelines.md`](../design-system/accessibility.md) (WCAG 3.3.8).

| Area | Control |
|---|---|
| **Transport** | TLS 1.2+; **certificate pinning** (host + backup pin + remote kill-switch); reject cleartext |
| **Tokens** | access JWT 5–15 min (RS256, `tenant`/`sub`/`sid` claims) + **rotating single-use refresh** with reuse-detection; stored in the secure enclave; never in prefs/logs/analytics/deep links |
| **At rest** | encrypted local DB (SQLCipher/Realm); secrets in Keystore/Keychain; `EncryptedSharedPreferences`/`flutter_secure_storage`/`react-native-keychain` |
| **App lock** | inactivity timeout → biometric/PIN re-unlock; step-up re-auth for sensitive actions (password, MFA, role changes, payments, delete) |
| **AuthZ** | **server is the authority**; client `can(permission)` is UX only; every endpoint re-checks permission + tenant + record state; no privilege escalation |
| **Device integrity** | Play Integrity / DeviceCheck / App Attest; bind refresh tokens to `device_id`; optional root/jailbreak refusal for high-security tenants |
| **Screen privacy** | `FLAG_SECURE` + app-switcher blur on auth/PII screens; disable screenshots per policy |
| **Input/output** | validate both sides; parameterized queries; sanitize markdown; content-type sniffing on uploads (magic bytes); CSV-injection guard on exports |
| **Rate limiting** | auth, OTP, search, export, password reset — server-side + client backoff with jitter |
| **Deep links / URLs** | no tokens or sensitive ids in query strings; verified App Links / Universal Links only |
| **Dependencies** | pinned versions; SCA (Dependabot/Renovate + Snyk/OWASP); SBOM; no unmaintained libs |
| **Secrets** | none in the repo or app bundle; injected at build (CI secrets) / fetched via authenticated remote config; scan the repo (gitleaks) in CI |
| **Privacy** | data minimization; explicit consent for analytics/crash/diagnostics; regional data residency; right-to-erasure via soft-delete → purge; document data flows |
| **Offline** | encrypted cache; scoped working set; wipe on logout/deactivation/remote-wipe; T0 actions truly blocked offline ([`08 §13`](../feature-library/08-offline-sync.md)) |
| **Monitoring** | audit every state-changing action ([`feature-library/07`](../feature-library/07-observability.md)); anomaly alerts (new device, geo-velocity, mass export) |
| **Pen testing** | pre-release pen test for auth-adjacent releases; annual full assessment; a threat model per feature |

| | Compose | Flutter | React Native |
|---|---|---|---|
| Biometric | `androidx.biometric` (`BIOMETRIC_STRONG`) | `local_auth` | `react-native-keychain` biometric access control / `react-native-biometrics` |
| Secure storage | `EncryptedSharedPreferences` + Keystore | `flutter_secure_storage` | `react-native-keychain` / `expo-secure-store` |
| Cert pinning | OkHttp `CertificatePinner` | `dio` cert callback / native | `react-native-ssl-pinning` |
| Integrity | Play Integrity API / SafetyNet successor + DeviceCheck (via a bridge) | `google_api_availability` + platform channels | `react-native-play-integrity` / `react-native-device-check` |
| Screenshot block | `window.setFlags(FLAG_SECURE)` | `flutter_windowmanager` / `secure_application` | `react-native-screenshot-prevent` / native `FLAG_SECURE` |
| Root/JB detect | `RootBeer` | `flutter_jailbreak_detection` | `jail-monkey` |

---

## 15. CI/CD Recommendations

### 15.1 Pipeline (per PR)

```
1. Setup            checkout · restore caches · install toolchain
2. Generate/verify  codegen fresh (freezed/hilt/openapi/tokens) — fail if stale
3. Static analysis  lint (detekt/analyzer+custom_lint/eslint) · format check · type check (TS) · dependency-rule tests (Konsist/import_lint/boundaries)
4. Security         SCA (Snyk/OWASP dep-check) · secret scan (gitleaks) · license check
5. Unit + widget    with coverage gate (e.g. ≥ 70% domain, ≥ 60% overall) — fail on regression
6. Golden/snapshot  components × variants × states × {light,dark} × {1.0,2.0} — visual diff
7. Contrast/a11y    token contrast lint · automated a11y guideline tests on key screens
8. Build            Android (assembleDebug + a signed release-candidate) · iOS (no-sign archive) — catch breakage
9. Integration/e2e  3 core flows on an emulator/simulator (login→dashboard→approve; list→edit→save; create via form)
10. Catalog         deploy Widgetbook/Storybook (web) as a review artifact
11. Report          post coverage + size + a11y summary as a PR comment
```

### 15.2 Release (on tag / merge to `release/*`)

```
- bump version (semantic) + generate changelog
- build signed artifacts per flavor (dev/staging/prod)
- Android: AAB → Play internal → closed track → production (staged rollout 10%→50%→100%)
- iOS: IPA → TestFlight → App Store (phased release)
- upload dSYM / mapping / sourcemaps to the crash reporter
- run smoke tests on the release build
- tag the release, notify, monitor crash-free rate + key funnels for 48h (auto-halt rollout on regression)
```

### 15.3 Tooling

| | Native (Compose/SwiftUI) | Flutter | React Native |
|---|---|---|---|
| CI | GitHub Actions / GitLab CI / Bitrise | same | same + EAS (Expo) optional |
| Build/sign/ship | **Fastlane** (`gym`, `supply`, `pilot`, `match` for iOS certs) | Fastlane + `flutter build` | Fastlane / EAS Build + EAS Submit |
| Monorepo tasks | Gradle + build cache (remote) | **Melos** scripts | Nx / Turborepo (optional) |
| Emulators | Gradle Managed Devices / Firebase Test Lab | Firebase Test Lab / `integration_test` | Detox + device farm / Maestro |
| Feature flags | one flag service (LaunchDarkly / Firebase Remote Config / Unleash) — `feature.<area>.<name>` | same | same |
| OTA (RN only) | — | — | CodePush / EAS Update for JS-only fixes (never for native changes; respect store policy) |
| Env | `BuildConfig` + product flavors | `--dart-define-from-file` + flavors | `react-native-config` + schemes/flavors |

### 15.4 Rules
- Trunk-based or short-lived branches; PRs required; **green CI required to merge**; no direct pushes to `main`.
- Reproducible builds; pinned toolchain versions (`.tool-versions` / `fvm` / `.nvmrc` + `.ruby-version`).
- Signing keys in CI secret storage / `match` (iOS); never in the repo.
- Every merge to `main` is releasable; releases are cut from `main`.
- Post-release monitoring gates the rollout (crash-free sessions ≥ 99.5%, no funnel regression).

---

## 16. Testing Strategy

The pyramid (bottom = most):

| Layer | What | Tools (Compose / Flutter / RN) | Gate |
|---|---|---|---|
| **Unit — domain** | use cases, `Failure` mapping, validators, formatters, reducers | JUnit + kotlin.test + Turbine / `test` + `mocktail` / Jest + `zod` | ≥ 80% |
| **Unit — data** | repository (cache-first, outbox, conflict), DTO mappers, DAO queries, migrations | Room `MigrationTestHelper` / `drift` migration tests / WatermelonDB schema tests | ≥ 70% |
| **State** | ViewModel/Notifier/hook: every `UiState` transition, optimistic + rollback, events | `ViewModel` tests + fake repos / `ProviderContainer` + overrides / `renderHook` + a QueryClient | all transitions |
| **Component** | every `Amds*` × variant × state × {light,dark} × {1.0,2.0 text} — **golden/snapshot** | Paparazzi/Roborazzi / `alchemist`,`golden_toolkit` / Storybook + Chromatic | 100% of components |
| **Component behavior** | interactions, callbacks, a11y semantics (role/name/state), reduced-motion | Compose UI test / `flutter_test` / RN Testing Library | key components |
| **Screen** | renders each state; key interactions; empty/error/offline | Compose UI test / widget test / RNTL | each screen's states |
| **Accessibility** | contrast, tap targets, labels — automated + a manual SR pass on top flows | `AccessibilityChecks` / `meetsGuideline(...)` / `eslint-plugin-react-native-a11y` + manual | CI + per-release manual |
| **Integration** | a feature slice against a mock server (MSW / a fake) — repo → API contract | Hilt test rules + MockWebServer / `dio` + a fake / MSW | per feature |
| **E2E** | the 3 core flows on a real device/emulator | Espresso + Compose / `integration_test` / **Detox** or **Maestro** | CI on each PR (smoke) + nightly (full) |
| **Contract** | client ⇄ OpenAPI schema; (later) Figma props ⇄ component API | schema validation in CI | on schema change |
| **Performance** | cold start, FMP, jank frames, APK/IPA size, memory — budgeted, regression-gated | Macrobenchmark + `JankStats` / DevTools + `integration_test` timeline / Flashlight, `react-native-performance` | budgets enforced |
| **Security** | SCA, secret scan, auth flow pen test (pre-release) | Snyk/OWASP + gitleaks + a manual/automated pen test | CI + pre-release |

**Rules**
- Tests live **next to the code** (`<feature>_test.*`), not in a parallel tree.
- Every bug fix ships with a regression test.
- Golden baselines are reviewed like code; update deliberately (`--update-goldens` in a dedicated commit).
- The 3 E2E flows must stay green — they're the release gate.
- Mock repositories mean features are testable and demoable before the backend exists.

---

## 17. Developer Guidelines

### 17.1 Getting started (day 1)
1. Install the pinned toolchain (`.tool-versions` / `fvm use` / `nvm use`).
2. `<bootstrap>` — Gradle sync / `melos bootstrap` / `yarn && pod install`.
3. Copy `config/dev.example.json` → `config/dev.json` (no secrets; ask for the staging URL).
4. Run the app against **mock repositories** — every screen works offline on mock data.
5. Run `<test>` — green from a clean clone is the contract.
6. Open the component catalog (Widgetbook/Storybook) — browse the design system.
7. Read: this doc → [`feature-library/00-framework`](../feature-library/00-framework.md) → the feature you're touching → its screen specs.

### 17.2 Adding a feature
1. Scaffold: `<gen> feature <name>` (Mason brick / Gradle template / plop) → creates the module contract (§1.2) + tests + a route stub.
2. Define the **domain** first: entity + repository interface + use cases. No framework imports.
3. Define the **API contract** (OpenAPI) + regenerate the typed client.
4. Implement the **mock repository** → wire the screens against it → demo it.
5. Implement the **real repository** (cache-first + outbox); declare the offline tier per operation.
6. Build screens from the **screen-library** archetype; use the 3 engines (`RecordListConfig`/`RecordDetailConfig`/`FormSchema`) where they fit.
7. Register routes + deep links centrally; add analytics events; add audit expectations.
8. Tests per §16; a11y + dark-mode + tablet + reduced-motion pass.
9. PR with the feature's DoD checklist ([`feature-library/00 §4`](../feature-library/00-framework.md)) ticked.

### 17.3 Working agreements
- **Definition of done** per feature/screen/component is enforced in review (checklists in the respective docs).
- **Small PRs** (< ~400 lines diff), one concern, self-review first.
- **No `TODO` without a ticket link.** No commented-out code.
- **Feature flags** for anything risky or incomplete; remove the flag when stable.
- **Backwards-compatible** DB migrations and API changes; deprecate over two minor versions.
- **Accessibility, dark mode, offline, and RTL are not follow-ups** — they're part of the same PR.
- **Never** hardcode a color, dimension, or user-facing string in `features/` (lint fails).
- **Never** import one feature from another.
- **Never** put a network call, store read, or navigation inside a component.
- **Update the docs** in the same PR when you change a pattern.

### 17.4 Code review checklist
- [ ] Dependency rule respected (domain pure; no cross-feature imports; no data types in presentation)
- [ ] All `UiState` branches handled (loading/data/empty/error/offline)
- [ ] Mutations: optimistic + rollback + `Idempotency-Key`; 409 handled
- [ ] Tokens only (no hex/dp/strings); dark + 200% text + RTL OK
- [ ] a11y: role/name/state on interactive elements; reduced-motion path
- [ ] Errors mapped to `Failure`; no raw exceptions/stack traces to the user; trace id surfaced
- [ ] Analytics events fire; audit expectations noted; no PII in logs/events/URLs
- [ ] Tests: state transitions + component goldens + a11y; regression test for any fix
- [ ] Offline tier declared and implemented for each new operation
- [ ] No secrets; no new unpinned dependency; SCA clean

---

## 18. Code Style Guidelines

### 18.1 Universal
- **Formatter is law** — `ktlint`/`spotless` · `dart format` · `prettier`. CI fails on unformatted code. No style debates in review.
- **Naming:** features = domain nouns (`assets`, not `screens`); files = the primary type; `Amds*` for design-system widgets; `*Screen`/`*Page`, `*Controller`/`*ViewModel`/`use*`, `*Repository`, `*Dto`, `*UiState`.
- **Immutability by default** — `val`/`final`/`readonly`/`const`; immutable data classes (`data class` / `freezed` / `readonly` + `zod`).
- **Small units** — functions do one thing; extract when a function needs a comment to explain a block.
- **Comments explain *why*, not *what*.** Match the surrounding code's comment density.
- **No magic numbers/strings** — named constants or tokens; enums over string literals.
- **Nullability explicit** — no `!!` / `!` / non-null assertions without a guarded reason; model absence in types.
- **Errors as values** (`Result`/`Either`), exceptions only at true boundaries.
- **Pure domain** — no framework, IO, or platform imports in `domain/`.
- **Ordering:** public API first, private helpers below; related things together.

### 18.2 Kotlin / Compose
- Follow the [Kotlin style guide](https://kotlinlang.org/docs/coding-conventions.html) + `ktlint`.
- Composables: `PascalCase`, no side effects in composition, hoist state, `Modifier` as the first optional param, preview functions per variant.
- Prefer `sealed interface` for `UiState`/`Failure`; `StateFlow` over `LiveData`; `collectAsStateWithLifecycle`.
- Coroutines: structured concurrency, inject dispatchers, no `GlobalScope`.
- `detekt` + Compose lint rules; Konsist tests for architecture.

### 18.3 Dart / Flutter
- `flutter_lints` + `very_good_analysis` + `custom_lint` + `riverpod_lint`.
- `freezed` for models + unions; `const` constructors everywhere possible; `key` on list items.
- Widgets small and composable; `build` methods short; extract widgets, not methods, for rebuildable subtrees.
- Riverpod: `@riverpod` codegen, `AsyncNotifier` for data, `ref.watch` in build / `ref.read` in callbacks, no `BuildContext` in providers.
- `import_lint` / a boundary lint to forbid cross-feature and layer violations.

### 18.4 TypeScript / React Native
- `strict: true`; ESLint (`@typescript-eslint`, `eslint-plugin-react-hooks`, `eslint-plugin-react-native-a11y`, `eslint-plugin-boundaries`) + Prettier.
- Function components + hooks only; one component per file; `React.memo` for list rows; stable keys.
- Zod-validate all external data at the boundary; infer types from schemas.
- TanStack Query for server state; Zustand slices for client state; no prop-drilling beyond 2 levels (context or a store).
- Path aliases (`@core/*`, `@features/*`); no relative `../../..` across features.
- Reanimated worklets kept pure; avoid inline styles in hot lists (StyleSheet or the theme).

---

## 19. Future Scalability Recommendations

Extends [`15-future-scalability.md`](../starter-template/scalability.md).

| Horizon | Recommendation |
|---|---|
| **Now** | Feature-first + clean layers; mock repos; the 3 engines; token pipeline in CI; golden + e2e gates; offline tiers declared; audit wiring from day one |
| **Modularization** | Split into build modules (`:core:*`, `:feature:*`) / Melos packages / Nx projects for build speed + enforced boundaries; a convention plugin/preset so new modules are consistent |
| **Design system as a package** | Publish `amds_ui` / `:core:designsystem` / the RN DS to a private registry, versioned, with a changelog + codemods for breaking changes; product apps depend on it |
| **Tokens two-way sync** | Tokens Studio ↔ Git so designers commit token changes via PR; contrast lint per brand |
| **White-label at scale** | `BrandTheme` + feature flags per product; a `new-app` scaffold that produces a runnable branded app in < 1 day; no component forks |
| **Backend-for-frontend** | A mobile BFF that shapes/aggregates responses (screen-scoped payloads, partial-tolerant dashboards) so the client stays thin as services multiply |
| **Offline-first maturity** | Move from T2 (queue-and-replay) to T3 (full offline-first with bidirectional sync) for field features via PowerSync / WatermelonDB sync / Realm — behind the same repository interface |
| **Realtime** | A single realtime gateway (WS/SSE) with per-tenant topics; client `RealtimeClient` abstraction so features subscribe without knowing the transport |
| **New platforms** | The same tokens + feature blueprints extend to Compose Multiplatform, KMP shared logic, wearOS/watchOS companions, Android Auto/CarPlay, or a web admin — add a Style Dictionary target + a component lib, reuse domain + contracts |
| **Governance** | An RFC process (`docs/rfcs/`) for cross-cutting changes; an adoption dashboard (token/component/engine usage per app); federated contributors per app; quarterly audits |
| **Performance** | Per-app budgets (cold start, FMP, jank, size) tracked in CI; downsample charts server-side; image variants + CDN; keyset pagination everywhere; a BFF to keep payloads small |
| **Data growth** | Partition audit/notifications/activity by month; move search to a dedicated index; analytics to a warehouse; archive cold data; per-tenant quotas |
| **Team growth** | Scaffolds + `_template` app keep onboarding to a day; the docs are the onboarding path and are updated as part of every change's DoD |

---

## 20. Bootstrap checklist (new app, day 0–1)

- [ ] Repo created from the template; toolchain pinned (`.tool-versions` / `fvm` / `.nvmrc`)
- [ ] `core/*` modules in place (§2); dependency-rule tests pass
- [ ] Token pipeline wired: `tokens.json` → platform theme files; CI freshness check
- [ ] `AmdsTheme` applied; light + dark render; component catalog deploys
- [ ] Navigation: `AuthGraph` + `AppGraph` + adaptive shell + deep-link scheme registered; guards reading `SessionManager`
- [ ] Auth feature: Splash → Login → Dashboard on **mock** data; secure token storage; biometric hook
- [ ] `SyncEngine` + `Outbox` + encrypted DB scaffolded; offline Banner + `SyncStatus`
- [ ] `ApiClient` with all interceptors; `ErrorMapper`; `Result`/`Failure`
- [ ] `AppLogger` + crash reporter; `Analytics` interface + NoOp adapter + consent gate
- [ ] `PushService` scaffolded (permission priming, token register/deregister, deep-link router)
- [ ] Security: cert pinning, `FLAG_SECURE` on auth screens, secret scan in CI
- [ ] CI pipeline (§15.1) green; 3 e2e flow stubs
- [ ] `config/dev.json` + `staging` + `prod` flavors/schemes; no secrets in the repo
- [ ] `_template`/scaffold verified: `<gen> feature demo` compiles + tests pass
- [ ] `CONTRIBUTING.md` points here; DoD checklists linked
- [ ] First real feature picked; its feature-library blueprint + screen specs read
