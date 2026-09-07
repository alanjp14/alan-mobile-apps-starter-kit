// The 3 core end-to-end flows — the release gate (docs/starter-template/testing.md §1).
//
//   1. login → dashboard → approve
//   2. list → edit → save
//   3. create via form
//
// These drive the *whole* app (real router, DI, widgets); only the repositories
// are mocked (zero latency), so they run under `flutter test` on any host — no
// emulator. For on-device runs, add platform folders (`flutter create .`) and
// move this file under `integration_test/` with an
// `IntegrationTestWidgetsFlutterBinding`.

import 'package:app_config/app_config.dart';
import 'package:app_template/app/app.dart';
import 'package:app_template/core/di.dart';
import 'package:app_template/features/auth/data/mock_auth_repository.dart';
import 'package:app_template/features/items/data/mock_items_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> _boot(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(
          AppConfig.fromEnv(appName: 'Template', deepLinkScheme: 'tpl'),
        ),
        authRepositoryProvider
            .overrideWithValue(MockAuthRepository(latency: Duration.zero)),
        itemsRepositoryProvider
            .overrideWithValue(MockItemsRepository(latency: Duration.zero)),
      ],
      child: const TemplateApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _signIn(WidgetTester tester) async {
  expect(find.text('Welcome back'), findsOneWidget);
  await tester.enterText(find.byType(TextField).first, 'sam@example.com');
  await tester.enterText(find.byType(TextField).last, 'super-secret');
  await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
  await tester.pumpAndSettle();
  expect(find.text('[MODULE_NAME]'), findsOneWidget);
}

void main() {
  setUpAll(initializeDateFormatting);

  testWidgets('flow 1 · login → dashboard → approve', (tester) async {
    await _boot(tester);
    await _signIn(tester);

    // open the first pending item
    await tester.tap(find.text('Pending').first);
    await tester.pumpAndSettle();

    expect(find.text('Approve'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Approve'));
    await tester.pumpAndSettle();

    // the status flipped and the Approve button is gone
    expect(find.text('Approve'), findsNothing);
    expect(find.text('Approved'), findsWidgets);
  });

  testWidgets('flow 2 · list → edit → save', (tester) async {
    await _boot(tester);
    await _signIn(tester);

    // open a known item (mock seeds '[DATA_NAME] 1'…'[DATA_NAME] 6')
    await tester.tap(find.text('[DATA_NAME] 1'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Edit [DATA_NAME]'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Renamed by e2e');
    await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
    await tester.pumpAndSettle();

    // back on the detail screen with the new title
    expect(find.text('Renamed by e2e'), findsOneWidget);

    // and back on the list
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Renamed by e2e'), findsOneWidget);
    expect(find.text('[DATA_NAME] 1'), findsNothing);
  });

  testWidgets('flow 3 · create via form', (tester) async {
    await _boot(tester);
    await _signIn(tester);

    await tester.tap(find.widgetWithText(FloatingActionButton, 'New'));
    await tester.pumpAndSettle();
    expect(find.text('New [DATA_NAME]'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Created by e2e');
    await tester.enterText(find.byType(TextField).last, 'Owned by QA');
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();

    // lands back on the list with the new row on top
    expect(find.text('[MODULE_NAME]'), findsOneWidget);
    expect(find.text('Created by e2e'), findsOneWidget);
  });
}
