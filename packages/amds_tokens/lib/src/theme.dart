// AMDS v1.0 · ThemeData assembly. Wires the semantic tokens into a Material 3
// theme so both `Amds*` widgets and built-in Material widgets look right.

import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'theme_ext.dart';
import 'tokens.dart';

/// Material 3 `TextTheme` mapped from the AMDS type scale.
const TextTheme amdsTextTheme = TextTheme(
  displayLarge: AmdsTextStyles.displayLarge,
  displayMedium: AmdsTextStyles.displayMedium,
  displaySmall: AmdsTextStyles.displaySmall,
  headlineLarge: AmdsTextStyles.headingLarge,
  headlineMedium: AmdsTextStyles.headingMedium,
  headlineSmall: AmdsTextStyles.headingSmall,
  titleLarge: AmdsTextStyles.titleLarge,
  titleMedium: AmdsTextStyles.titleMedium,
  titleSmall: AmdsTextStyles.bodySmall,
  bodyLarge: AmdsTextStyles.bodyLarge,
  bodyMedium: AmdsTextStyles.bodyMedium,
  bodySmall: AmdsTextStyles.bodySmall,
  labelLarge: AmdsTextStyles.label,
  labelMedium: AmdsTextStyles.labelSmall,
  labelSmall: AmdsTextStyles.overline,
);

abstract final class AmdsTheme {
  /// Light theme. Pass [colors] for a brand override.
  static ThemeData light({AmdsColors colors = AmdsColors.light}) =>
      _build(Brightness.light, colors);

  /// Dark theme. Pass [colors] for a brand override.
  static ThemeData dark({AmdsColors colors = AmdsColors.dark}) =>
      _build(Brightness.dark, colors);

  static ThemeData _build(Brightness brightness, AmdsColors c) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primaryContainer,
      onPrimaryContainer: c.onPrimaryContainer,
      secondary: c.secondary,
      onSecondary: c.onSecondary,
      secondaryContainer: c.primaryContainer,
      onSecondaryContainer: c.onPrimaryContainer,
      tertiary: c.accent,
      onTertiary: c.textOnColor,
      error: c.danger,
      onError: c.textOnColor,
      errorContainer: c.dangerContainer,
      onErrorContainer: c.onDangerContainer,
      surface: c.surface,
      onSurface: c.onSurface,
      surfaceContainerHighest: c.surfaceVariant,
      onSurfaceVariant: c.onSurfaceVariant,
      outline: c.border,
      outlineVariant: c.divider,
      shadow: const Color(0xFF0F172A),
      scrim: c.overlayScrim,
      inverseSurface: brightness == Brightness.light
          ? AmdsPalette.neutral900
          : AmdsPalette.neutral50,
      onInverseSurface: brightness == Brightness.light
          ? AmdsPalette.neutral50
          : AmdsPalette.neutral900,
      inversePrimary: brightness == Brightness.light
          ? AmdsPalette.green400
          : AmdsPalette.green700,
      surfaceTint: Colors.transparent,
    );

    final ext = AmdsThemeExt(colors: c, brightness: brightness);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      fontFamily: AmdsTextStyles.fontFamily,
      textTheme: amdsTextTheme.apply(
          bodyColor: c.textPrimary, displayColor: c.textPrimary),
      splashFactory: InkSparkle.splashFactory,
      extensions: [ext],
      appBarTheme: AppBarTheme(
        toolbarHeight: AmdsSize.appBarHeight,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: c.surface,
        foregroundColor: c.onSurface,
        titleTextStyle:
            AmdsTextStyles.titleLarge.copyWith(color: c.textPrimary),
      ),
      dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        elevation: 0,
        color: c.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: AmdsRadius.brLg, side: BorderSide(color: c.border)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        constraints: const BoxConstraints(minHeight: AmdsSize.fieldHeight),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AmdsSpacing.md, vertical: AmdsSpacing.sm),
        hintStyle: AmdsTextStyles.bodyLarge.copyWith(color: c.textTertiary),
        labelStyle: AmdsTextStyles.label.copyWith(color: c.textSecondary),
        helperStyle: AmdsTextStyles.caption.copyWith(color: c.textSecondary),
        errorStyle: AmdsTextStyles.caption.copyWith(color: c.danger),
        border: OutlineInputBorder(
            borderRadius: AmdsRadius.brSm,
            borderSide: BorderSide(color: c.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: AmdsRadius.brSm,
            borderSide: BorderSide(color: c.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: AmdsRadius.brSm,
            borderSide: BorderSide(color: c.borderFocus, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: AmdsRadius.brSm,
            borderSide: BorderSide(color: c.danger)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: AmdsRadius.brSm,
            borderSide: BorderSide(color: c.danger, width: 2)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(
              Size.fromHeight(AmdsSize.buttonHeightMd)),
          shape: const WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: AmdsRadius.brMd)),
          textStyle: const WidgetStatePropertyAll(AmdsTextStyles.label),
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.disabled)) return c.disabled;
            if (s.contains(WidgetState.pressed)) return c.primaryPressed;
            return c.primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled)
                ? c.textOnColor.withValues(alpha: 0.6)
                : c.onPrimary,
          ),
          elevation: WidgetStateProperty.resolveWith<double>(
              (s) => s.contains(WidgetState.pressed) ? 0.0 : 1.0),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: c.borderStrong,
        shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AmdsRadius.xl))),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AmdsSize.bottomNavHeight,
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.primaryContainer,
        elevation: 2,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
            AmdsTextStyles.labelSmall.copyWith(color: c.onSurfaceVariant)),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.primaryContainer,
        selectedIconTheme: IconThemeData(color: c.primary),
        unselectedIconTheme: IconThemeData(color: c.onSurfaceVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle:
            AmdsTextStyles.bodyMedium.copyWith(color: scheme.onInverseSurface),
        actionTextColor: c.primary,
        shape: const RoundedRectangleBorder(borderRadius: AmdsRadius.brMd),
        insetPadding: const EdgeInsets.all(AmdsSpacing.md),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AmdsRadius.brLg),
        titleTextStyle:
            AmdsTextStyles.headingMedium.copyWith(color: c.textPrimary),
        contentTextStyle:
            AmdsTextStyles.bodyMedium.copyWith(color: c.textSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceVariant,
        labelStyle: AmdsTextStyles.label.copyWith(color: c.textPrimary),
        shape: const RoundedRectangleBorder(borderRadius: AmdsRadius.brMd),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
            horizontal: AmdsSpacing.sm, vertical: AmdsSpacing.xxs),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
