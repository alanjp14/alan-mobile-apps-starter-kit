import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:starter/app/showcase_screen.dart';

void main() {
  testWidgets('showcase renders in light and dark without exceptions', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AmdsTheme.light(),
          darkTheme: AmdsTheme.dark(),
          themeMode: mode,
          home: const ShowcaseScreen(),
        ),
      );
      await tester.pump(const Duration(seconds: 1)); // let entrance + count-up settle

      expect(find.text('AMDS Starter'), findsOneWidget);
      expect(find.byType(AmdsButton), findsWidgets);
      expect(find.byType(AmdsTextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('theme toggle button flips brightness', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AmdsTheme.light(), darkTheme: AmdsTheme.dark(), home: const ShowcaseScreen()),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
  });
}
