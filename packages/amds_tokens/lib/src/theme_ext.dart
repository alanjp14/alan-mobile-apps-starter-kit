// AMDS v1.0 · semantic colors + the ThemeExtension that carries them.
// Semantic values are generated from design-tokens/tokens.json; the class shape
// is hand-maintained. Regenerate values: `node tool/build_tokens.mjs`.

import 'package:flutter/material.dart';

import 'tokens.dart';

/// Theme-aware semantic colors. Product code reads these via `context.amds.colors`,
/// never [AmdsPalette] directly. Swap for a brand by passing a custom instance to
/// `AmdsTheme.light(colors: ...)` / `AmdsTheme.dark(colors: ...)`.
@immutable
class AmdsColors {
  const AmdsColors({
    required this.brand,
    required this.primary,
    required this.primaryHover,
    required this.primaryPressed,
    required this.primaryContainer,
    required this.onPrimary,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.accent,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceRaised,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textOnColor,
    required this.textLink,
    required this.border,
    required this.borderStrong,
    required this.borderFocus,
    required this.divider,
    required this.disabled,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.danger,
    required this.dangerContainer,
    required this.onDangerContainer,
    required this.info,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.overlayScrim,
    required this.skeletonBase,
    required this.skeletonSheen,
  });

  final Color brand;
  final Color primary,
      primaryHover,
      primaryPressed,
      primaryContainer,
      onPrimary,
      onPrimaryContainer;
  final Color secondary, onSecondary, accent;
  final Color background, onBackground;
  final Color surface,
      surfaceVariant,
      surfaceRaised,
      onSurface,
      onSurfaceVariant;
  final Color textPrimary,
      textSecondary,
      textTertiary,
      textDisabled,
      textOnColor,
      textLink;
  final Color border, borderStrong, borderFocus, divider, disabled;
  final Color success, successContainer, onSuccessContainer;
  final Color warning, warningContainer, onWarningContainer;
  final Color danger, dangerContainer, onDangerContainer;
  final Color info, infoContainer, onInfoContainer;
  final Color overlayScrim, skeletonBase, skeletonSheen;

  static const AmdsColors light = AmdsColors(
    brand: AmdsPalette.green600,
    primary: AmdsPalette.green600,
    primaryHover: AmdsPalette.green700,
    primaryPressed: AmdsPalette.green800,
    primaryContainer: AmdsPalette.green100,
    onPrimary: AmdsPalette.neutral0,
    onPrimaryContainer: AmdsPalette.green900,
    secondary: AmdsPalette.green500,
    onSecondary: AmdsPalette.neutral0,
    accent: AmdsPalette.sky600,
    background: AmdsPalette.neutral50,
    onBackground: AmdsPalette.neutral900,
    surface: AmdsPalette.neutral0,
    surfaceVariant: AmdsPalette.neutral100,
    surfaceRaised: AmdsPalette.neutral0,
    onSurface: AmdsPalette.neutral900,
    onSurfaceVariant: AmdsPalette.neutral500,
    textPrimary: AmdsPalette.neutral900,
    textSecondary: AmdsPalette.neutral500,
    textTertiary: AmdsPalette.neutral400,
    textDisabled: AmdsPalette.neutral300,
    textOnColor: AmdsPalette.neutral0,
    textLink: AmdsPalette.green700,
    border: AmdsPalette.neutral200,
    borderStrong: AmdsPalette.neutral300,
    borderFocus: AmdsPalette.green600,
    divider: AmdsPalette.neutral200,
    disabled: AmdsPalette.neutral300,
    success: AmdsPalette.green600,
    successContainer: AmdsPalette.green50,
    onSuccessContainer: AmdsPalette.green800,
    warning: AmdsPalette.amber600,
    warningContainer: AmdsPalette.amber50,
    onWarningContainer: AmdsPalette.amber700,
    danger: AmdsPalette.red600,
    dangerContainer: AmdsPalette.red50,
    onDangerContainer: AmdsPalette.red700,
    info: AmdsPalette.sky600,
    infoContainer: AmdsPalette.sky50,
    onInfoContainer: AmdsPalette.sky700,
    overlayScrim: Color(0x7A0F172A),
    skeletonBase: AmdsPalette.neutral200,
    skeletonSheen: AmdsPalette.neutral100,
  );

  static const AmdsColors dark = AmdsColors(
    brand: AmdsPalette.green500,
    primary: AmdsPalette.green400,
    primaryHover: AmdsPalette.green300,
    primaryPressed: AmdsPalette.green200,
    primaryContainer: AmdsPalette.green900,
    onPrimary: AmdsPalette.green950,
    onPrimaryContainer: AmdsPalette.green100,
    secondary: AmdsPalette.green500,
    onSecondary: AmdsPalette.green950,
    accent: AmdsPalette.sky400,
    background: AmdsPalette.neutral950,
    onBackground: AmdsPalette.neutral50,
    surface: AmdsPalette.neutral900,
    surfaceVariant: AmdsPalette.neutral800,
    surfaceRaised: AmdsPalette.neutral800,
    onSurface: AmdsPalette.neutral50,
    onSurfaceVariant: AmdsPalette.neutral400,
    textPrimary: AmdsPalette.neutral50,
    textSecondary: AmdsPalette.neutral400,
    textTertiary: AmdsPalette.neutral500,
    textDisabled: AmdsPalette.neutral700,
    textOnColor: AmdsPalette.neutral950,
    textLink: AmdsPalette.green400,
    border: AmdsPalette.neutral700,
    borderStrong: AmdsPalette.neutral600,
    borderFocus: AmdsPalette.green400,
    divider: AmdsPalette.neutral800,
    disabled: AmdsPalette.neutral700,
    success: AmdsPalette.green400,
    successContainer: Color(0x2922C55E),
    onSuccessContainer: AmdsPalette.green200,
    warning: AmdsPalette.amber400,
    warningContainer: Color(0x29F59E0B),
    onWarningContainer: AmdsPalette.amber100,
    danger: AmdsPalette.red400,
    dangerContainer: Color(0x29EF4444),
    onDangerContainer: AmdsPalette.red100,
    info: AmdsPalette.sky400,
    infoContainer: Color(0x290EA5E9),
    onInfoContainer: AmdsPalette.sky100,
    overlayScrim: Color(0xA3020617),
    skeletonBase: AmdsPalette.neutral800,
    skeletonSheen: AmdsPalette.neutral700,
  );

  AmdsColors copyWith(
      {Color? primary,
      Color? primaryContainer,
      Color? secondary,
      Color? accent,
      Color? brand}) {
    return AmdsColors(
      brand: brand ?? this.brand,
      primary: primary ?? this.primary,
      primaryHover: primaryHover,
      primaryPressed: primaryPressed,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimary: onPrimary,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary,
      accent: accent ?? this.accent,
      background: background,
      onBackground: onBackground,
      surface: surface,
      surfaceVariant: surfaceVariant,
      surfaceRaised: surfaceRaised,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textTertiary: textTertiary,
      textDisabled: textDisabled,
      textOnColor: textOnColor,
      textLink: textLink,
      border: border,
      borderStrong: borderStrong,
      borderFocus: borderFocus,
      divider: divider,
      disabled: disabled,
      success: success,
      successContainer: successContainer,
      onSuccessContainer: onSuccessContainer,
      warning: warning,
      warningContainer: warningContainer,
      onWarningContainer: onWarningContainer,
      danger: danger,
      dangerContainer: dangerContainer,
      onDangerContainer: onDangerContainer,
      info: info,
      infoContainer: infoContainer,
      onInfoContainer: onInfoContainer,
      overlayScrim: overlayScrim,
      skeletonBase: skeletonBase,
      skeletonSheen: skeletonSheen,
    );
  }

  static AmdsColors lerp(AmdsColors a, AmdsColors b, double t) {
    Color c(Color x, Color y) => Color.lerp(x, y, t)!;
    return AmdsColors(
      brand: c(a.brand, b.brand),
      primary: c(a.primary, b.primary),
      primaryHover: c(a.primaryHover, b.primaryHover),
      primaryPressed: c(a.primaryPressed, b.primaryPressed),
      primaryContainer: c(a.primaryContainer, b.primaryContainer),
      onPrimary: c(a.onPrimary, b.onPrimary),
      onPrimaryContainer: c(a.onPrimaryContainer, b.onPrimaryContainer),
      secondary: c(a.secondary, b.secondary),
      onSecondary: c(a.onSecondary, b.onSecondary),
      accent: c(a.accent, b.accent),
      background: c(a.background, b.background),
      onBackground: c(a.onBackground, b.onBackground),
      surface: c(a.surface, b.surface),
      surfaceVariant: c(a.surfaceVariant, b.surfaceVariant),
      surfaceRaised: c(a.surfaceRaised, b.surfaceRaised),
      onSurface: c(a.onSurface, b.onSurface),
      onSurfaceVariant: c(a.onSurfaceVariant, b.onSurfaceVariant),
      textPrimary: c(a.textPrimary, b.textPrimary),
      textSecondary: c(a.textSecondary, b.textSecondary),
      textTertiary: c(a.textTertiary, b.textTertiary),
      textDisabled: c(a.textDisabled, b.textDisabled),
      textOnColor: c(a.textOnColor, b.textOnColor),
      textLink: c(a.textLink, b.textLink),
      border: c(a.border, b.border),
      borderStrong: c(a.borderStrong, b.borderStrong),
      borderFocus: c(a.borderFocus, b.borderFocus),
      divider: c(a.divider, b.divider),
      disabled: c(a.disabled, b.disabled),
      success: c(a.success, b.success),
      successContainer: c(a.successContainer, b.successContainer),
      onSuccessContainer: c(a.onSuccessContainer, b.onSuccessContainer),
      warning: c(a.warning, b.warning),
      warningContainer: c(a.warningContainer, b.warningContainer),
      onWarningContainer: c(a.onWarningContainer, b.onWarningContainer),
      danger: c(a.danger, b.danger),
      dangerContainer: c(a.dangerContainer, b.dangerContainer),
      onDangerContainer: c(a.onDangerContainer, b.onDangerContainer),
      info: c(a.info, b.info),
      infoContainer: c(a.infoContainer, b.infoContainer),
      onInfoContainer: c(a.onInfoContainer, b.onInfoContainer),
      overlayScrim: c(a.overlayScrim, b.overlayScrim),
      skeletonBase: c(a.skeletonBase, b.skeletonBase),
      skeletonSheen: c(a.skeletonSheen, b.skeletonSheen),
    );
  }
}

/// The AMDS [ThemeExtension]. Read it with `context.amds`.
@immutable
class AmdsThemeExt extends ThemeExtension<AmdsThemeExt> {
  const AmdsThemeExt({required this.colors, required this.brightness});

  final AmdsColors colors;
  final Brightness brightness;

  bool get isDark => brightness == Brightness.dark;

  List<BoxShadow> elevation(int level) =>
      AmdsElevation.level(level, brightness: brightness);

  @override
  AmdsThemeExt copyWith({AmdsColors? colors, Brightness? brightness}) =>
      AmdsThemeExt(
          colors: colors ?? this.colors,
          brightness: brightness ?? this.brightness);

  @override
  AmdsThemeExt lerp(ThemeExtension<AmdsThemeExt>? other, double t) {
    if (other is! AmdsThemeExt) return this;
    return AmdsThemeExt(
      colors: AmdsColors.lerp(colors, other.colors, t),
      brightness: t < 0.5 ? brightness : other.brightness,
    );
  }
}

/// Ergonomic access: `context.amds.colors.primary`, `context.text.titleLarge`.
extension AmdsContextX on BuildContext {
  AmdsThemeExt get amds => Theme.of(this).extension<AmdsThemeExt>()!;
  TextTheme get text => Theme.of(this).textTheme;
}
