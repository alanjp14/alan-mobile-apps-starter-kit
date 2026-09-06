# Architecture

> Part of the [starter template](README.md). Full detail + platform tables: [`blueprint.md §0, §2`](blueprint.md) and [`../feature-library/00-framework.md`](../feature-library/00-framework.md).

---

## 1. Layers (Clean Architecture)

```
┌ PRESENTATION ─ screen (stateless) ── ViewModel/Notifier/hook ── UiState ─┐  Compose / SwiftUI / Widgets / RN
├ DOMAIN ─────── entities · use cases · repository interfaces · Result<T> ──┤  pure — no framework imports
├ DATA ───────── repository impl ── { RemoteDataSource · LocalDataSource · Outbox } ┤
└ CORE / PLATFORM ─ DI · theme · network · secure storage · logger · analytics · push · connectivity · sync engine ┘
```

**The dependency rule:** dependencies point **inward**. Domain knows nothing of data or presentation. Presentation depends on domain (interfaces), never on data. Enforce with a lint/architecture test (Konsist / `import_lint` / `eslint-plugin-boundaries`).

## 2. Principles

1. **Dependency inversion** — presentation and data both depend on domain abstractions (`[Entity]Repository` interface); the impl is injected.
2. **Feature-first** — folders are business capabilities (`[MODULE_NAME]`), not layers. Each feature is a mini clean-architecture stack + its routes + its tests. **No feature imports another** — cross-feature needs go through `core/*` or a domain event.
3. **Stateless UI** — a screen renders a `UiState` and emits intents. No business logic, network calls, or navigation inside a component.
4. **Separation of concerns** — one class, one reason to change. ViewModels orchestrate; use cases hold business rules; repositories hold data access; data sources hold I/O.
5. **Testability** — pure domain (no I/O), injected dependencies, mock repositories that ship by default so the app runs before the backend.
6. **Offline-first** — repositories are cache-first; writes go through a durable, idempotent, ordered outbox (see [local-storage.md](local-storage.md), [`../feature-library/08-offline-sync.md`](../feature-library/08-offline-sync.md)).
7. **Token-driven** — no hard-coded colors/dimensions/strings in feature code (lint-enforced).
8. **Additive change** — new features add modules; shared code graduates into `core/*` via review + version bump.

## 3. Feature-module contract

Every feature module (scaffold with a Mason brick / Gradle template / plop) has this shape:

```
features/[MODULE_NAME]/
├── presentation/
│   ├── [module]_list_page.*          stateless; reads [Module]ListUiState
│   ├── [module]_list_controller.*    owns fetching, paging, filter, selection
│   ├── [module]_list_state.*         sealed/freezed UiState
│   ├── [module]_detail_page.* / _controller.* / _state.*
│   ├── [module]_form_page.*          FormEngine(FormSchema)
│   └── widgets/                      screen-local composables only
├── domain/
│   ├── [module].*                    entity (immutable)
│   ├── [module]_repository.*         interface — the ONLY thing presentation imports from data's world
│   └── usecases/  get_[modules].* · create_[module].* · …
├── data/
│   ├── [module]_repository_impl.*    cache-first read; outbox write
│   ├── [module]_remote_data_source.* Retrofit / dio / axios
│   ├── [module]_local_data_source.*  Room / Drift / WatermelonDB DAO
│   ├── dto/  [module]_dto.* (+ mapper to/from entity)
│   └── [module]_di.*
├── [module]_routes.*                 route defs + deep links (registered centrally)
└── [module]_test.*                   unit + widget + golden
```

**DTOs never leak past `data/`.** Map to domain entities at the boundary.

## 4. `core/` responsibilities

| Module | Owns |
|---|---|
| `designsystem` | AMDS theme, `Amds*` components, `AppIcons`, adaptive layout |
| `network` | HTTP client, auth/retry/logging/idempotency interceptors, `problem+json` → `Failure` mapping |
| `database` | encrypted DB, migrations, `cache_*` + `outbox_op` + `sync_state` tables |
| `datastore` | secure storage (tokens, keys), non-secret prefs |
| `sync` | `SyncEngine`, `Outbox`, delta pull, conflict resolution |
| `auth/session` | `SessionManager` (`status`/`user`/`permissions`/`tenant`), token lifecycle, guards, step-up |
| `common` | `Result<T>` / `Failure`, dispatchers, `Formatters`, `Validators`, extensions |
| `logging` | `AppLogger`, ring buffer, sinks |
| `analytics` | `Analytics` interface, consent gating, event schema |
| `push` | `PushService`, message handlers, deep-link router |
| `navigation` | route registry, deep-link graph, adaptive nav host |

## 5. Platform mapping

| Concern | Jetpack Compose | Flutter | React Native | SwiftUI |
|---|---|---|---|---|
| Layering | Gradle modules `:core:*` `:feature:*` `:app` + a convention plugin | Melos packages / `lib/features/*` + `import_lint` | `src/core/*` `src/features/*` + `eslint-plugin-boundaries` | SPM targets + `@testable` boundaries |
| DI | Hilt | Riverpod providers | Context + service locator | manual / Factory pattern |
| Enforcement test | Konsist | `dart_code_metrics` / custom lint | `eslint-plugin-boundaries` | a dependency-graph test |

Full per-platform folder trees: [`project-structure.md`](project-structure.md).
