# AMDS — Flutter Starter Kit

The runnable Flutter implementation of AMDS. The `docs/` tree is the spec; this is the code.

```
pubspec.yaml            Dart pub workspace (needs Dart ≥ 3.6 / Flutter ≥ 3.27)
melos.yaml              task runner
analysis_options.yaml   shared lint (very strict)
tool/build_tokens.mjs   design-tokens/tokens.json  ->  packages/amds_tokens/lib/src/tokens.dart

packages/
  amds_tokens/   palette · scales · typography · motion · ThemeData · AmdsThemeExt   (tokens.dart is GENERATED)
  amds_core/     Result<T>/Failure · Formatters · Validators · PasswordPolicy         (pure Dart)
  app_config/    AppConfig · Flavor · FeatureFlags · BrandTheme (white-label)
  amds_ui/       Amds* widgets (starter set) · adaptive layout · motion · state screens
apps/
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

## Status — Phase 1

**Done:** `amds_tokens` (complete), `amds_core` (complete), `app_config` (complete), `amds_ui` (a **starter set** — ~12 components + layout + motion + state widgets), `apps/starter`, `widgetbook`, the token generator, CI.

**Next:** expand `amds_ui` to the full ~40 components in [`docs/component-library/`](docs/component-library/README.md) (use [`prompts/component-library-generator.md`](prompts/component-library-generator.md)); add golden tests; wire Riverpod + go_router + a repository layer per [`docs/starter-template/`](docs/starter-template/README.md); build the `_template` app; add the 3 core e2e flows.
