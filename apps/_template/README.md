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

| Concern            | Choice                          | Where                                  |
| ------------------ | ------------------------------- | -------------------------------------- |
| DI / composition   | Riverpod providers              | `lib/core/di.dart`                     |
| Navigation         | `go_router`, central table      | `lib/app/router.dart`                  |
| Auth gate          | `redirect` on `authController`  | `lib/app/router.dart` + `features/auth`|
| Theming            | `AmdsTheme` + brand overlay     | `lib/app/app.dart`, `theme_controller` |
| Feature structure  | domain / data / presentation    | `lib/features/*/`                      |
| Data → UI contract | `Result<T>` / `Failure`         | `amds_core`                            |
| Async UI state     | `AsyncNotifier` + AMDS states   | `features/*/presentation/`             |
| Forms              | `Form` + `Validators` (amds_core)| `login_screen`, `item_form_screen`    |

## Two worked features

- **`auth`** — a login form gated by `Validators`, a `MockAuthRepository`
  (any email + 8-char password), and a router `redirect` that bounces you to
  `/login` until there's a session.
- **`items`** — list · detail · create · edit · approve · archive, every state
  (loading skeleton / empty / error / offline), backed by `MockItemsRepository`.
  Swap the mock for an HTTP client and nothing above the `ItemsRepository`
  interface changes. Delete both features once your first real one lands.

## The 3 core e2e flows

`test/flows_test.dart` drives the whole app (real router + DI + widgets, mock
repos at zero latency) through the release-gate flows from
`docs/starter-template/testing.md`. They run under `flutter test` with no
emulator; for on-device runs, add platform folders (`flutter create .`) and
move the file under `integration_test/`.

1. **login → dashboard → approve**
2. **list → edit → save**
3. **create via form**

## Run

```bash
flutter run -t apps/_template/lib/main.dart
```

## Test

```bash
cd apps/_template && flutter test   # unit + widget + the 3 e2e flows
```

See `docs/starter-template/` for the reasoning behind each choice.
