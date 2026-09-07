import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';

import 'app/showcase_screen.dart';

void main() => runApp(const StarterApp());

/// Holds the runtime theme choice (device-local in a real app — see
/// docs/design-system/theme-architecture.md §5).
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

class StarterApp extends StatelessWidget {
  const StarterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) {
        return AmdsMotionScope(
          settings: const AmdsMotionSettings(),
          child: MaterialApp(
            title: 'AMDS Starter',
            debugShowCheckedModeBanner: false,
            theme: AmdsTheme.light(),
            darkTheme: AmdsTheme.dark(),
            themeMode: mode,
            // clamp text scale to the AMDS range while honoring the user
            builder: (context, child) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  textScaler: mq.textScaler
                      .clamp(minScaleFactor: 0.85, maxScaleFactor: 2.0),
                ),
                child: child!,
              );
            },
            home: const ShowcaseScreen(),
          ),
        );
      },
    );
  }
}
