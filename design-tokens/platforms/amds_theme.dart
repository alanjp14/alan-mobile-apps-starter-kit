// ============================================================================
// Alan Mobile Design System (AMDS) v1.0
// Flutter theme. Generated from tokens/tokens.json.
//
// Usage:
//   MaterialApp(
//     theme: AmdsTheme.light,
//     darkTheme: AmdsTheme.dark,
//     themeMode: ThemeMode.system,
//   );
//
// Access custom tokens anywhere:
//   final t = Theme.of(context).extension<AmdsTokens>()!;
//   Container(padding: EdgeInsets.all(t.space4), ...)
// ============================================================================

import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Raw palette ramps. Prefer [AmdsColors] semantic aliases in product code.
class AmdsPalette {
  AmdsPalette._();

  // Brand / green
  static const green50 = Color(0xFFF0FDF4);
  static const green100 = Color(0xFFDCFCE7);
  static const green200 = Color(0xFFBBF7D0);
  static const green300 = Color(0xFF86EFAC);
  static const green400 = Color(0xFF4ADE80);
  static const green500 = Color(0xFF22C55E);
  static const green600 = Color(0xFF16A34A);
  static const green700 = Color(0xFF15803D);
  static const green800 = Color(0xFF166534);
  static const green900 = Color(0xFF14532D);
  static const green950 = Color(0xFF052E16);

  // Neutral / slate
  static const neutral0 = Color(0xFFFFFFFF);
  static const neutral50 = Color(0xFFF8FAFC);
  static const neutral100 = Color(0xFFF1F5F9);
  static const neutral200 = Color(0xFFE2E8F0);
  static const neutral300 = Color(0xFFCBD5E1);
  static const neutral400 = Color(0xFF94A3B8);
  static const neutral500 = Color(0xFF64748B);
  static const neutral600 = Color(0xFF475569);
  static const neutral700 = Color(0xFF334155);
  static const neutral800 = Color(0xFF1E293B);
  static const neutral900 = Color(0xFF0F172A);
  static const neutral950 = Color(0xFF020617);

  // Semantic
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const amber400 = Color(0xFFFBBF24);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);
  static const red400 = Color(0xFFF87171);
  static const sky500 = Color(0xFF0EA5E9);
  static const sky600 = Color(0xFF0284C7);
  static const sky400 = Color(0xFF38BDF8);
}

/// Theme-aware custom token set exposed as a [ThemeExtension].
@immutable
class AmdsTokens extends ThemeExtension<AmdsTokens> {
  const AmdsTokens({
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textLink,
    required this.border,
    required this.borderStrong,
    required this.borderFocus,
    required this.divider,
    required this.surfaceVariant,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.danger,
    required this.dangerContainer,
    required this.info,
    required this.infoContainer,
    required this.skeletonBase,
    required this.skeletonSheen,
    required this.scrim,
  });

  final Color textPrimary, textSecondary, textTertiary, textDisabled, textLink;
  final Color border, borderStrong, borderFocus, divider, surfaceVariant;
  final Color success, successContainer, warning, warningContainer;
  final Color danger, dangerContainer, info, infoContainer;
  final Color skeletonBase, skeletonSheen, scrim;

  // Spacing scale (4pt base)
  double get space0 => 0;
  double get space1 => 4;
  double get space2 => 8;
  double get space3 => 12;
  double get space4 => 16;
  double get space5 => 20;
  double get space6 => 24;
  double get space8 => 32;
  double get space10 => 40;
  double get space12 => 48;
  double get space16 => 64;

  // Radius
  double get radiusXs => 4;
  double get radiusSm => 8;
  double get radiusMd => 12;
  double get radiusLg => 16;
  double get radiusXl => 24;
  double get radius2xl => 32;

  // Sizing
  double get touchTargetMin => 44;
  double get fieldHeight => 48;
  double get appBarHeight => 56;
  double get bottomNavHeight => 64;

  // Motion (milliseconds)
  Duration get durInstant => const Duration(milliseconds: 100);
  Duration get durFast => const Duration(milliseconds: 150);
  Duration get durBase => const Duration(milliseconds: 200);
  Duration get durModerate => const Duration(milliseconds: 250);
  Duration get durSlow => const Duration(milliseconds: 300);
  Duration get durSlower => const Duration(milliseconds: 400);

  static const Curve easeStandard = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve easeDecelerate = Cubic(0.0, 0.0, 0.0, 1.0);
  static const Curve easeAccelerate = Cubic(0.3, 0.0, 1.0, 1.0);
  static const Curve easeSpring = Cubic(0.34, 1.56, 0.64, 1.0);

  static List<BoxShadow> elevation(int level) {
    switch (level) {
      case 1:
        return const [BoxShadow(color: Color(0x0F0F172A), blurRadius: 2, offset: Offset(0, 1))];
      case 2:
        return const [
          BoxShadow(color: Color(0x140F172A), blurRadius: 4, spreadRadius: -1, offset: Offset(0, 2)),
          BoxShadow(color: Color(0x0A0F172A), blurRadius: 2, offset: Offset(0, 1)),
        ];
      case 3:
        return const [
          BoxShadow(color: Color(0x1A0F172A), blurRadius: 8, spreadRadius: -2, offset: Offset(0, 4)),
          BoxShadow(color: Color(0x0D0F172A), blurRadius: 4, spreadRadius: -1, offset: Offset(0, 2)),
        ];
      case 4:
        return const [
          BoxShadow(color: Color(0x1F0F172A), blurRadius: 20, spreadRadius: -4, offset: Offset(0, 12)),
          BoxShadow(color: Color(0x0F0F172A), blurRadius: 8, spreadRadius: -2, offset: Offset(0, 4)),
        ];
      case 5:
        return const [
          BoxShadow(color: Color(0x290F172A), blurRadius: 40, spreadRadius: -8, offset: Offset(0, 24)),
          BoxShadow(color: Color(0x140F172A), blurRadius: 16, spreadRadius: -4, offset: Offset(0, 8)),
        ];
      default:
        return const [];
    }
  }

  @override
  AmdsTokens copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textLink,
    Color? border,
    Color? borderStrong,
    Color? borderFocus,
    Color? divider,
    Color? surfaceVariant,
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? danger,
    Color? dangerContainer,
    Color? info,
    Color? infoContainer,
    Color? skeletonBase,
    Color? skeletonSheen,
    Color? scrim,
  }) {
    return AmdsTokens(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      textLink: textLink ?? this.textLink,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      borderFocus: borderFocus ?? this.borderFocus,
      divider: divider ?? this.divider,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      danger: danger ?? this.danger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonSheen: skeletonSheen ?? this.skeletonSheen,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  AmdsTokens lerp(ThemeExtension<AmdsTokens>? other, double t) {
    if (other is! AmdsTokens) return this;
    return AmdsTokens(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textLink: Color.lerp(textLink, other.textLink, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonSheen: Color.lerp(skeletonSheen, other.skeletonSheen, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
    );
  }
}

class AmdsTypography {
  AmdsTypography._();

  static const String fontFamily = 'Inter';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(fontFamily: fontFamily, fontSize: 36, height: 44 / 36, fontWeight: FontWeight.w700, letterSpacing: -0.72),
    displayMedium: TextStyle(fontFamily: fontFamily, fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w700, letterSpacing: -0.64),
    displaySmall: TextStyle(fontFamily: fontFamily, fontSize: 28, height: 36 / 28, fontWeight: FontWeight.w700, letterSpacing: -0.28),
    headlineLarge: TextStyle(fontFamily: fontFamily, fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600, letterSpacing: -0.24),
    headlineMedium: TextStyle(fontFamily: fontFamily, fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600, letterSpacing: -0.2),
    headlineSmall: TextStyle(fontFamily: fontFamily, fontSize: 18, height: 26 / 18, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontFamily: fontFamily, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontFamily: fontFamily, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, letterSpacing: 0.07),
    titleSmall: TextStyle(fontFamily: fontFamily, fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontFamily: fontFamily, fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontFamily: fontFamily, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontFamily: fontFamily, fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontFamily: fontFamily, fontSize: 14, height: 16 / 14, fontWeight: FontWeight.w500, letterSpacing: 0.14),
    labelMedium: TextStyle(fontFamily: fontFamily, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, letterSpacing: 0.24),
    labelSmall: TextStyle(fontFamily: fontFamily, fontSize: 11, height: 16 / 11, fontWeight: FontWeight.w600, letterSpacing: 0.88),
  );
}

class AmdsTheme {
  AmdsTheme._();

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AmdsPalette.green600,
      onPrimary: AmdsPalette.neutral0,
      primaryContainer: AmdsPalette.green100,
      onPrimaryContainer: AmdsPalette.green900,
      secondary: AmdsPalette.green500,
      onSecondary: AmdsPalette.neutral0,
      secondaryContainer: AmdsPalette.green100,
      onSecondaryContainer: AmdsPalette.green900,
      tertiary: AmdsPalette.sky600,
      onTertiary: AmdsPalette.neutral0,
      error: AmdsPalette.red600,
      onError: AmdsPalette.neutral0,
      errorContainer: Color(0xFFFEF2F2),
      onErrorContainer: Color(0xFFB91C1C),
      surface: AmdsPalette.neutral0,
      onSurface: AmdsPalette.neutral900,
      onSurfaceVariant: AmdsPalette.neutral500,
      outline: AmdsPalette.neutral200,
      outlineVariant: AmdsPalette.neutral100,
      shadow: AmdsPalette.neutral900,
      scrim: AmdsPalette.neutral900,
      inverseSurface: AmdsPalette.neutral900,
      onInverseSurface: AmdsPalette.neutral50,
      inversePrimary: AmdsPalette.green400,
      surfaceTint: AmdsPalette.green600,
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: AmdsPalette.neutral50,
      extensions: const [
        AmdsTokens(
          textPrimary: AmdsPalette.neutral900,
          textSecondary: AmdsPalette.neutral500,
          textTertiary: AmdsPalette.neutral400,
          textDisabled: AmdsPalette.neutral300,
          textLink: AmdsPalette.green700,
          border: AmdsPalette.neutral200,
          borderStrong: AmdsPalette.neutral300,
          borderFocus: AmdsPalette.green600,
          divider: AmdsPalette.neutral200,
          surfaceVariant: AmdsPalette.neutral100,
          success: AmdsPalette.green600,
          successContainer: AmdsPalette.green50,
          warning: AmdsPalette.amber600,
          warningContainer: Color(0xFFFFFBEB),
          danger: AmdsPalette.red600,
          dangerContainer: Color(0xFFFEF2F2),
          info: AmdsPalette.sky600,
          infoContainer: Color(0xFFF0F9FF),
          skeletonBase: AmdsPalette.neutral200,
          skeletonSheen: AmdsPalette.neutral100,
          scrim: Color(0x7A0F172A),
        ),
      ],
    );
  }

  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AmdsPalette.green400,
      onPrimary: AmdsPalette.green950,
      primaryContainer: AmdsPalette.green900,
      onPrimaryContainer: AmdsPalette.green100,
      secondary: AmdsPalette.green500,
      onSecondary: AmdsPalette.green950,
      secondaryContainer: AmdsPalette.green900,
      onSecondaryContainer: AmdsPalette.green100,
      tertiary: AmdsPalette.sky400,
      onTertiary: AmdsPalette.neutral950,
      error: AmdsPalette.red400,
      onError: AmdsPalette.neutral950,
      errorContainer: Color(0x29EF4444),
      onErrorContainer: Color(0xFFFEE2E2),
      surface: AmdsPalette.neutral900,
      onSurface: AmdsPalette.neutral50,
      onSurfaceVariant: AmdsPalette.neutral400,
      outline: AmdsPalette.neutral700,
      outlineVariant: AmdsPalette.neutral800,
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: AmdsPalette.neutral50,
      onInverseSurface: AmdsPalette.neutral900,
      inversePrimary: AmdsPalette.green700,
      surfaceTint: AmdsPalette.green400,
    );

    return _base(scheme).copyWith(
      scaffoldBackgroundColor: AmdsPalette.neutral950,
      extensions: const [
        AmdsTokens(
          textPrimary: AmdsPalette.neutral50,
          textSecondary: AmdsPalette.neutral400,
          textTertiary: AmdsPalette.neutral500,
          textDisabled: AmdsPalette.neutral700,
          textLink: AmdsPalette.green400,
          border: AmdsPalette.neutral700,
          borderStrong: AmdsPalette.neutral600,
          borderFocus: AmdsPalette.green400,
          divider: AmdsPalette.neutral800,
          surfaceVariant: AmdsPalette.neutral800,
          success: AmdsPalette.green400,
          successContainer: Color(0x2922C55E),
          warning: AmdsPalette.amber400,
          warningContainer: Color(0x29F59E0B),
          danger: AmdsPalette.red400,
          dangerContainer: Color(0x29EF4444),
          info: AmdsPalette.sky400,
          infoContainer: Color(0x290EA5E9),
          skeletonBase: AmdsPalette.neutral800,
          skeletonSheen: AmdsPalette.neutral700,
          scrim: Color(0xA3020617),
        ),
      ],
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AmdsTypography.fontFamily,
      textTheme: AmdsTypography.textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        toolbarHeight: 56,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: AmdsTypography.textTheme.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size.fromHeight(44)),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          textStyle: WidgetStateProperty.all(AmdsTypography.textTheme.labelLarge),
          elevation: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.pressed) ? 0 : 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        constraints: const BoxConstraints(minHeight: 48),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.outline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.outline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: scheme.error)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: scheme.outline)),
        margin: EdgeInsets.zero,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        showDragHandle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: scheme.surface,
        elevation: 2,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
