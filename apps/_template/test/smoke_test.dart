import 'package:amds_ui/amds_ui.dart';
import 'package:app_config/app_config.dart';
import 'package:app_template/app/app.dart';
import 'package:app_template/core/di.dart';
import 'package:app_template/features/auth/data/mock_auth_repository.dart';
import 'package:app_template/features/items/data/mock_items_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> _pump(WidgetTester tester, {MockItemsRepository? items}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(
          AppConfig.fromEnv(appName: 'Test', deepLinkScheme: 'test'),
        ),
        authRepositoryProvider
            .overrideWithValue(MockAuthRepository(latency: Duration.zero)),
        itemsRepositoryProvider.overrideWithValue(
          items ?? MockItemsRepository(latency: Duration.zero),
        ),
      ],
      child: const TemplateApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).first, 'sam@example.com');
  await tester.enterText(find.byType(TextField).last, 'super-secret');
  await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(initializeDateFormatting);

  testWidgets('unauthenticated boot lands on the login screen', (tester) async {
    await _pump(tester);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('[MODULE_NAME]'), findsNothing);
  });

  testWidgets('signing in reaches the list with mock data', (tester) async {
    await _pump(tester);
    await _signIn(tester);
    expect(find.text('[MODULE_NAME]'), findsOneWidget);
    expect(find.byType(AmdsCard), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the list shows the offline state when the repository fails',
      (tester) async {
    final repo = MockItemsRepository(latency: Duration.zero)
      ..failNextRead = true;
    await _pump(tester, items: repo);
    await _signIn(tester);
    expect(find.text("You're offline"), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
