import 'package:amds_ui/amds_ui.dart';
import 'package:app_config/app_config.dart';
import 'package:app_template/app/app.dart';
import 'package:app_template/core/di.dart';
import 'package:app_template/features/items/data/mock_items_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(initializeDateFormatting);

  testWidgets('boots to the list and renders items on mock data',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            AppConfig.fromEnv(appName: 'Test', deepLinkScheme: 'test'),
          ),
          itemsRepositoryProvider.overrideWithValue(
            MockItemsRepository(latency: Duration.zero),
          ),
        ],
        child: const TemplateApp(),
      ),
    );

    // loading first
    expect(find.byType(AmdsSkeletonList), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('[MODULE_NAME]'), findsOneWidget);
    expect(find.byType(AmdsCard), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the offline state when the repository fails',
      (tester) async {
    final repo = MockItemsRepository(latency: Duration.zero)
      ..failNextRead = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            AppConfig.fromEnv(appName: 'Test', deepLinkScheme: 'test'),
          ),
          itemsRepositoryProvider.overrideWithValue(repo),
        ],
        child: const TemplateApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("You're offline"), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}
