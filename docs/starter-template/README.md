# Starter Template — Architecture

> Part of [AMDS v1.0](../design-system/README.md). The production-ready architecture for a new `[APP_NAME]` on Android + iOS:
> **Clean Architecture · feature-based modularization · scalable enterprise pattern · offline-first · production-ready.**

## Start here

**[`blueprint.md`](blueprint.md)** is the complete, single-file blueprint (all 18 concerns + Compose/Flutter/RN library tables + a day-0 bootstrap checklist). The focused files below own one topic each; each points back to the relevant `blueprint.md` section for depth.

| File | Topic |
|---|---|
| [`blueprint.md`](blueprint.md) | **The whole thing** — read this first |
| [`architecture.md`](architecture.md) | Clean Architecture layers · principles · the feature-module contract |
| [`project-structure.md`](project-structure.md) | Full folder trees per platform · env config · flavors |
| [`navigation.md`](navigation.md) | Typed routes · adaptive shell · guards · deep links · back-stack synthesis |
| [`state-management.md`](state-management.md) | `UiState` contract · state layers · caching · per-platform |
| [`networking.md`](networking.md) | API layer · interceptors · error mapping · repository layer · realtime |
| [`local-storage.md`](local-storage.md) | Encrypted DB · offline outbox · caching · migrations |
| [`error-handling-and-logging.md`](error-handling-and-logging.md) | `Result`/`Failure` · global handlers · structured logging · analytics · crash reporting |
| [`security.md`](security.md) | Transport · tokens · at-rest · authZ · device integrity · privacy |
| [`testing.md`](testing.md) | The testing pyramid · CI/CD pipeline · gates |
| [`code-style-and-guidelines.md`](code-style-and-guidelines.md) | Universal + Kotlin/Compose + Dart/Flutter + TS/RN style · developer guidelines |
| [`developer-handoff.md`](developer-handoff.md) | Token pipeline · design→engineering handoff · redlines · QA |
| [`scalability.md`](scalability.md) | Extending the system · governance at scale · risk register |

## The one-paragraph version

A new app is **feature-first**: each folder is a business capability (`[MODULE_NAME]`), containing its own `presentation` (stateless screens + a ViewModel/Notifier/hook exposing one `UiState`) → `domain` (pure: entities, use cases, repository interfaces, `Result<T>`) → `data` (repository impl over a remote API + an encrypted local DB + a durable outbox). Shared infrastructure lives in `core/*` (DI, theme, network, secure storage, logger, analytics, push, connectivity, sync engine). Dependencies point inward; no feature imports another. Everything is token-driven, offline-first, accessible, and testable. The app runs end-to-end on **mock repositories** before any backend exists.

## Stack

Parameterized — pick one, the blueprint covers all:

| | Jetpack Compose (native) | Flutter | React Native |
|---|---|---|---|
| DI | Hilt | Riverpod | Context + service locator |
| State | ViewModel + `StateFlow` | Riverpod `AsyncNotifier` | Zustand + TanStack Query |
| Nav | Navigation-Compose | `go_router` | React Navigation |
| Network | Retrofit + OkHttp | `dio` | `axios` + `zod` |
| Local DB | Room + SQLCipher | Drift + SQLCipher / Isar | WatermelonDB / op-sqlite |

Full tables (images, charts, monorepo, per-archetype notes): [`blueprint.md §0`](blueprint.md).

## Bootstrap

The day-0 checklist is [`blueprint.md §20`](blueprint.md). Scaffold with [`prompts/mobile-app-starter-template.md`](../../prompts/mobile-app-starter-template.md).
