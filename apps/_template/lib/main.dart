import 'package:app_config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'core/di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load ICU date symbols so AmdsFormatters can format weekdays/months.
  await initializeDateFormatting();

  // Swap `Flavor.dev` per build flavor (see FLUTTER.md §flavors). API base URL,
  // Sentry DSN etc. come from `--dart-define` — never hard-code secrets.
  final config = AppConfig.fromEnv(
    appName: '[APP_NAME]',
    deepLinkScheme: 'apptemplate',
    flavor: Flavor.dev,
  );

  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const TemplateApp(),
    ),
  );
}
