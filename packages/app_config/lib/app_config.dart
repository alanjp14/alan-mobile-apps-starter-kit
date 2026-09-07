/// AMDS app configuration — flavor, environment, feature flags, brand theme.
///
/// Each product app defines one `AppConfig` per flavor and passes it at the
/// composition root. Values come from `--dart-define` / a bundled config file —
/// never hard-coded secrets. See docs/starter-template/project-structure.md.
library;

import 'package:amds_tokens/amds_tokens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color, ThemeData;

enum Flavor { dev, staging, prod }

@immutable
class AppConfig {
  const AppConfig({
    required this.appName,
    required this.flavor,
    required this.apiBaseUrl,
    required this.deepLinkScheme,
    this.universalLinkHost,
    this.brand = const BrandTheme(),
    this.flags = const FeatureFlags(),
    this.sentryDsn,
  });

  final String appName;
  final Flavor flavor;
  final String apiBaseUrl;
  final String deepLinkScheme; // e.g. "myapp"
  final String? universalLinkHost; // e.g. "myapp.company.example"
  final BrandTheme brand;
  final FeatureFlags flags;
  final String? sentryDsn;

  bool get isProd => flavor == Flavor.prod;
  bool get showFlavorBanner => flavor != Flavor.prod;

  /// Read from compile-time `--dart-define` values. Override per flavor entrypoint.
  factory AppConfig.fromEnv({
    required String appName,
    required String deepLinkScheme,
    Flavor flavor = Flavor.dev,
    BrandTheme brand = const BrandTheme(),
    FeatureFlags flags = const FeatureFlags(),
  }) {
    return AppConfig(
      appName: appName,
      flavor: flavor,
      deepLinkScheme: deepLinkScheme,
      apiBaseUrl: const String.fromEnvironment('API_BASE_URL',
          defaultValue: 'https://api.example.test'),
      universalLinkHost: const bool.hasEnvironment('UNIVERSAL_LINK_HOST')
          ? const String.fromEnvironment('UNIVERSAL_LINK_HOST')
          : null,
      sentryDsn: const bool.hasEnvironment('SENTRY_DSN')
          ? const String.fromEnvironment('SENTRY_DSN')
          : null,
      brand: brand,
      flags: flags,
    );
  }
}

/// White-label overlay. Recolors **semantic** tokens only; spacing / radius /
/// type scale stay shared. See docs/design-system/theme-architecture.md §4.
@immutable
class BrandTheme {
  const BrandTheme({
    this.name = 'AMDS',
    this.primary,
    this.primaryContainer,
    this.secondary,
    this.accent,
    this.logoAsset,
    this.fontFamily,
  });

  final String name;
  final Color? primary;
  final Color? primaryContainer;
  final Color? secondary;
  final Color? accent;
  final String? logoAsset;
  final String? fontFamily;

  AmdsColors _apply(AmdsColors base) => base.copyWith(
        primary: primary,
        primaryContainer: primaryContainer,
        secondary: secondary,
        accent: accent,
        brand: primary,
      );

  ThemeData light() => AmdsTheme.light(colors: _apply(AmdsColors.light));
  ThemeData dark() => AmdsTheme.dark(colors: _apply(AmdsColors.dark));
}

@immutable
class FeatureFlags {
  const FeatureFlags([this._flags = const {}]);

  final Map<String, bool> _flags;

  /// `flags['feature.approvals.bulk']`
  bool operator [](String key) => _flags[key] ?? false;

  bool isOn(String key) => this[key];

  FeatureFlags copyWith(Map<String, bool> overrides) =>
      FeatureFlags({..._flags, ...overrides});
}
