/// Alan Mobile Design System (AMDS) v1.0 — design tokens for Flutter.
///
/// ```dart
/// MaterialApp(
///   theme: AmdsTheme.light(),
///   darkTheme: AmdsTheme.dark(),
///   themeMode: ThemeMode.system,
/// );
///
/// // anywhere in the tree:
/// final c = context.amds.colors;      // semantic colors, theme-aware
/// Padding(padding: EdgeInsets.all(AmdsSpacing.md), ...);
/// ```
library;

export 'src/theme.dart' show AmdsTheme, amdsTextTheme;
export 'src/theme_ext.dart' show AmdsColors, AmdsThemeExt, AmdsContextX;
export 'src/tokens.dart'
    show
        AmdsPalette,
        AmdsSpacing,
        AmdsRadius,
        AmdsBorderWidth,
        AmdsSize,
        AmdsBreakpoints,
        AmdsMotion,
        AmdsElevation,
        AmdsTextStyles,
        AmdsOpacity;
