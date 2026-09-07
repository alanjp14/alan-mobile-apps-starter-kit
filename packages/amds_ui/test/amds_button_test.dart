import 'package:amds_ui/amds_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {ThemeMode mode = ThemeMode.light}) => MaterialApp(
      theme: AmdsTheme.light(),
      darkTheme: AmdsTheme.dark(),
      themeMode: mode,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('fires onPressed when enabled', (tester) async {
    var taps = 0;
    await tester
        .pumpWidget(_host(AmdsButton(label: 'Go', onPressed: () => taps++)));
    await tester.tap(find.text('Go'));
    expect(taps, 1);
  });

  testWidgets('does not fire when disabled or loading', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
        _host(AmdsButton(label: 'Go', loading: true, onPressed: () => taps++)));
    await tester.tap(find.byType(AmdsButton));
    expect(taps, 0);
  });

  testWidgets('exposes a button in the semantics tree with its label',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester
        .pumpWidget(_host(AmdsButton(label: 'Save asset', onPressed: () {})));
    expect(find.bySemanticsLabel('Save asset'), findsOneWidget);
    expect(
      tester.getSemantics(find.byType(FilledButton)),
      isSemantics(isButton: true, isEnabled: true, label: 'Save asset'),
    );
    handle.dispose();
  });

  testWidgets('renders every variant in light and dark without exceptions',
      (tester) async {
    for (final mode in ThemeMode.values) {
      await tester.pumpWidget(
        _host(
          Wrap(children: [
            for (final v in AmdsButtonVariant.values)
              AmdsButton(label: v.name, onPressed: () {}, variant: v)
          ]),
          mode: mode,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    }
  });
}
