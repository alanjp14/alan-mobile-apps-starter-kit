# AMDS — Flutter Starter Kit

The runnable Flutter implementation of AMDS. The `docs/` tree is the spec; this is the code.

```
pubspec.yaml            Dart pub workspace (needs Dart ≥ 3.6 / Flutter ≥ 3.27)
melos.yaml              task runner
analysis_options.yaml   shared lint (very strict)
tool/build_tokens.mjs   design-tokens/tokens.json  ->  packages/amds_tokens/lib/src/tokens.dart

packages/
  amds_tokens/   palette · scales · typography · motion tokens · ThemeData · AmdsThemeExt (tokens.dart is GENERATED)
  amds_core/     Result<T>/Failure · Formatters · Validators · PasswordPolicy         (pure Dart)
  amds_motion/   route transitions · entrances · micro-interactions · switchers    (reduce-motion aware)
  app_config/    AppConfig · Flavor · FeatureFlags · BrandTheme (white-label)
  amds_ui/       ~45 Amds* widgets · adaptive layout · state screens · re-exports amds_motion
apps/
  _template/     clean-architecture starter — clone this to begin a new app
                 (Riverpod DI · go_router · domain/data/presentation · mock repo)
  starter/       the reference app — a showcase on mock data
widgetbook/      component gallery (light + dark), dependency-free
```

## Setup

```bash
# 1. install the toolchain
flutter --version          # need >= 3.27 (stable)

# 2. regenerate tokens (optional — committed output is current)
node tool/build_tokens.mjs

# 3. resolve + bootstrap
flutter pub get
dart pub global activate melos
melos bootstrap

# 4. run the demo (generates android/ ios/ the first time)
cd apps/starter
flutter create --org com.example --project-name starter .
flutter run
```

## Everyday commands

| Command | Does |
|---|---|
| `melos run tokens` | regenerate `amds_tokens` from `design-tokens/tokens.json` |
| `melos run analyze` | static analysis across the workspace |
| `melos run format` | `dart format` |
| `melos run test` | Flutter package + app tests |
| `melos run test:dart` | pure-Dart (`amds_core`) tests |
| `melos run test:golden` | update golden files |
| `melos run ci` | what CI runs |
| `node tool/validate.mjs` | validate the docs/repo |

## Using it in a product app

```dart
import 'package:amds_ui/amds_ui.dart';   // re-exports amds_tokens

MaterialApp(
  theme: AmdsTheme.light(),
  darkTheme: AmdsTheme.dark(),
  themeMode: themeMode,   // device-local ThemeController (see docs/design-system/theme-architecture.md §5)
  builder: (context, child) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(textScaler: mq.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 2.0)),
      child: child!,
    );
  },
  home: AmdsScaffold(title: 'Home', body: ...),
);
```

White-label: `BrandTheme(primary: Color(0xFF2563EB)).light()` — recolors semantic tokens only.

## Motion

`amds_motion` (re-exported by `amds_ui`) is the shared animation toolkit — Material 3
shared-axis / fade-through route transitions, staggered entrances, tap/press
micro-interactions, and content-swap animations. All of it honors the OS "reduce
motion" setting plus an app-level `AmdsMotionScope` override, and animates
transform/opacity only.

```dart
AmdsMotionScope(
  settings: const AmdsMotionSettings(speed: 1.0),   // global speed / disable
  child: MaterialApp.router(/* ... */),
);

// go_router
pageBuilder: (context, state) => CustomTransitionPage(
  key: state.pageKey,
  child: DetailScreen(id: state.pathParameters['id']!),
  transitionsBuilder: AmdsPageTransitions.sharedAxisX,
);
```

See [`packages/amds_motion/README.md`](packages/amds_motion/README.md).

## Clone a new app

```bash
cp -r apps/_template apps/my_app
#   → rename `name:` in apps/my_app/pubspec.yaml
#   → add `apps/my_app` to the workspace list in the root pubspec.yaml
#   → replace the [PLACEHOLDER] strings, drop in a BrandTheme + AppConfig
#   → delete the `items` feature once your first real feature lands
flutter pub get && cd apps/my_app && flutter test
```

`apps/_template` wires the architecture from [`docs/starter-template/`](docs/starter-template/README.md):
Riverpod composition root (`lib/core/di.dart`), a central `go_router` table
(`lib/app/router.dart`), and a worked `items` feature (domain / data /
presentation) that exercises every state — loading, empty, error, offline — on a
`MockItemsRepository`. Swap the mock for an HTTP impl; nothing above the
`ItemsRepository` interface changes.

## Status — Phase 1

**Done:** `amds_tokens` (complete), `amds_core` (complete), `amds_motion` (route transitions · entrances · micro-interactions · switchers · `AmdsMotionScope`), `app_config` (complete), `amds_ui` (~45 components — actions · inputs · content · navigation · feedback · loading · state, all token-driven + dark-mode + a11y), `apps/starter`, `apps/_template` (Riverpod + go_router + AMDS route transitions + repository layer), `widgetbook`, the token generator, CI. Verified against Flutter/Dart SDK: `dart analyze` clean, all package/app tests green (amds_motion 9, amds_ui 19, amds_core 10, apps/starter 2, apps/_template 5).

**Next:** the remaining data components (Data Table, Chart Container, Timeline, Breadcrumb, Time Picker, rich Tooltip) in [`docs/component-library/`](docs/component-library/README.md); golden tests per component (light/dark); the 3 core e2e flows.
