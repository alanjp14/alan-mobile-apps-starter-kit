import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di.dart';
import 'router.dart';
import 'theme_controller.dart';

class TemplateApp extends ConsumerWidget {
  const TemplateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return AmdsMotionScope(
      // One place to globally slow, speed, or disable animation (accessibility
      // preference, low-power mode, demos). The OS "reduce motion" setting is
      // always respected on top of this.
      settings: const AmdsMotionSettings(),
      child: MaterialApp.router(
        title: config.appName,
        debugShowCheckedModeBanner: false,
        theme: config.brand.light(),
        darkTheme: config.brand.dark(),
        themeMode: themeMode,
        routerConfig: router,
        builder: (context, child) {
          // Honor the user's text-size setting but clamp to the AMDS range.
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(
              textScaler: mq.textScaler
                  .clamp(minScaleFactor: 0.85, maxScaleFactor: 2.0),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
