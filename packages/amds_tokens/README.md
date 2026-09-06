# amds_tokens

AMDS v1.0 design tokens for Flutter. Palette · spacing · radius · sizing · elevation · motion · typography · `ThemeData`.

## Use

```dart
import 'package:amds_tokens/amds_tokens.dart';

MaterialApp(
  theme: AmdsTheme.light(),
  darkTheme: AmdsTheme.dark(),
  themeMode: ThemeMode.system,
  home: const Home(),
);
```

```dart
// semantic colors — theme-aware, never AmdsPalette directly
final c = context.amds.colors;
Container(color: c.surface, ...);

// scales — theme-agnostic constants
EdgeInsets.all(AmdsSpacing.md);            // 16
BorderRadius.circular(AmdsRadius.lg);      // 16
AmdsSize.touchTarget;                       // 44
context.amds.elevation(2);                  // List<BoxShadow>, dark-aware

// motion
AnimatedContainer(duration: AmdsMotion.base, curve: AmdsMotion.standard, ...);

// type
Text('Total', style: context.text.titleMedium);   // or AmdsTextStyles.titleMedium
```

## White-label

```dart
const acme = AmdsColors.light; // start from the base, then:
final acmeLight = AmdsTheme.light(
  colors: AmdsColors.light.copyWith(
    primary: const Color(0xFF2563EB),
    primaryContainer: const Color(0xFFDBEAFE),
  ),
);
```

Only **semantic** colors change; spacing, radius, and the type scale stay shared. Re-run the contrast lint for the new palette.

## Regenerate

`lib/src/tokens.dart` is generated from [`../../design-tokens/tokens.json`](../../design-tokens/tokens.json):

```bash
node tool/build_tokens.mjs      # from the repo root, or: melos run tokens
```

`theme_ext.dart` (the `AmdsColors` shape) and `theme.dart` (the `ThemeData` wiring) are hand-maintained.

## Fonts

Inter ships on no OS. Drop the OFL font files into `fonts/` and uncomment the `flutter.fonts` block in `pubspec.yaml`. Until then Flutter falls back to the platform sans and the scale still holds.
