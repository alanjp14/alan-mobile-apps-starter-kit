# app_template

The **clone-to-start** app. Copy this folder, rename, and build your product on
top of it — the architecture, routing, DI, theming and state patterns are
already wired against AMDS.

```bash
cp -r apps/_template apps/my_app
# then: rename `name:` in pubspec.yaml, update the [PLACEHOLDER] strings,
# and add `apps/my_app` to the workspace list in the root pubspec.yaml
```

## What's inside

| Concern            | Choice                        | Where                                  |
| ------------------ | ----------------------------- | -------------------------------------- |
| DI / composition   | Riverpod providers            | `lib/core/di.dart`                     |
| Navigation         | `go_router`, central table    | `lib/app/router.dart`                  |
| Theming            | `AmdsTheme` + brand overlay   | `lib/app/app.dart`, `theme_controller` |
| Feature structure  | domain / data / presentation  | `lib/features/items/`                  |
| Data → UI contract | `Result<T>` / `Failure`       | `amds_core`                            |
| Async UI state     | `AsyncNotifier` + AMDS states | `features/items/presentation/`         |

## The `items` feature is a worked example

It shows the full loop — list, detail, an optimistic mutation, and every state
(loading skeleton, empty, error, offline) — backed by `MockItemsRepository`.
Swap that for an HTTP client and nothing above the `ItemsRepository` interface
changes. Delete the feature once your first real one lands.

## Run

```bash
flutter run -t apps/_template/lib/main.dart
```

## Test

```bash
cd apps/_template && flutter test
```

See `docs/starter-template/` for the reasoning behind each choice.
