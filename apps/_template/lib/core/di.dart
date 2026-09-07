// Composition root. Every dependency is a provider so features stay testable —
// override any of these in a ProviderScope for tests or Widgetbook.
// See docs/starter-template/state-management.md + .../architecture.md.

import 'package:app_config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/mock_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/items/data/mock_items_repository.dart';
import '../features/items/domain/items_repository.dart';

/// Supplied at the composition root in `main()` via `overrideWithValue`.
final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('appConfigProvider must be overridden'),
);

/// Swap the mock impls for HTTP-backed ones when the API is ready — nothing
/// above the domain interfaces changes.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => MockAuthRepository(),
);

final itemsRepositoryProvider = Provider<ItemsRepository>(
  (ref) => MockItemsRepository(),
);
