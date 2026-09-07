import 'package:amds_motion/amds_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {AmdsMotionSettings? settings}) => MaterialApp(
      home: AmdsMotionScope(
        settings: settings ?? const AmdsMotionSettings(),
        child: Scaffold(body: Center(child: child)),
      ),
    );

void main() {
  group('AmdsMotionScope', () {
    testWidgets('defaults when no scope present', (tester) async {
      late bool reduce;
      late Duration scaled;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            reduce = context.reduceMotion;
            scaled = amdsDuration(context, const Duration(milliseconds: 200));
            return const SizedBox();
          }),
        ),
      );
      expect(reduce, isFalse);
      expect(scaled, const Duration(milliseconds: 200));
    });

    testWidgets('forceReduceMotion short-circuits', (tester) async {
      late bool reduce;
      await tester.pumpWidget(
        _wrap(
          Builder(builder: (context) {
            reduce = context.reduceMotion;
            return const SizedBox();
          }),
          settings: const AmdsMotionSettings(forceReduceMotion: true),
        ),
      );
      expect(reduce, isTrue);
    });

    testWidgets('speed multiplier scales durations', (tester) async {
      late Duration d;
      await tester.pumpWidget(
        _wrap(
          Builder(builder: (context) {
            d = amdsDuration(context, const Duration(milliseconds: 200));
            return const SizedBox();
          }),
          settings: const AmdsMotionSettings(speed: 0.5),
        ),
      );
      expect(d, const Duration(milliseconds: 100));
    });
  });

  group('AmdsFadeSlideIn', () {
    testWidgets('ends fully opaque and un-translated', (tester) async {
      await tester.pumpWidget(_wrap(const AmdsFadeSlideIn(child: Text('hi'))));
      await tester.pumpAndSettle();
      final opacity = tester.widget<Opacity>(
        find.ancestor(of: find.text('hi'), matching: find.byType(Opacity)),
      );
      expect(opacity.opacity, 1.0);
    });

    testWidgets('reduced motion renders final frame on first pump',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AmdsFadeSlideIn(index: 5, child: Text('hi')),
          settings: const AmdsMotionSettings(forceReduceMotion: true),
        ),
      );
      await tester.pump();
      final opacity = tester.widget<Opacity>(
        find.ancestor(of: find.text('hi'), matching: find.byType(Opacity)),
      );
      expect(opacity.opacity, 1.0);
    });
  });

  group('AmdsAnimatedCount', () {
    testWidgets('animates toward the target then lands on it', (tester) async {
      await tester.pumpWidget(_wrap(const AmdsAnimatedCount(100)));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('100'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('reduced motion shows the value immediately', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AmdsAnimatedCount(100),
          settings: const AmdsMotionSettings(forceReduceMotion: true),
        ),
      );
      expect(find.text('100'), findsOneWidget);
    });
  });

  group('AmdsPageRoute', () {
    testWidgets('pushes and pops without exceptions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    AmdsPageRoute<void>(
                      builder: (_) => const Scaffold(body: Text('page 2')),
                    ),
                  ),
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text('page 2'), findsOneWidget);

      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.pop();
      await tester.pumpAndSettle();
      expect(find.text('go'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('AmdsSwitcher', () {
    testWidgets('swaps children by key', (tester) async {
      await tester.pumpWidget(
        _wrap(const AmdsSwitcher(child: Text('a', key: ValueKey('a')))),
      );
      await tester.pumpWidget(
        _wrap(const AmdsSwitcher(child: Text('b', key: ValueKey('b')))),
      );
      await tester.pumpAndSettle();
      expect(find.text('b'), findsOneWidget);
      expect(find.text('a'), findsNothing);
    });
  });
}
