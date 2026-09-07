import 'package:amds_core/amds_core.dart';

import '../domain/item.dart';
import '../domain/items_repository.dart';

/// In-memory fake with artificial latency. Lets the whole app run — and every
/// state (loading / empty / error / offline) be demoed — with no backend.
/// Delete once a real [ItemsRepository] impl exists.
class MockItemsRepository implements ItemsRepository {
  MockItemsRepository({this.latency = const Duration(milliseconds: 600)});

  final Duration latency;

  final List<Item> _store = List.generate(
    8,
    (i) => Item(
      id: 'itm_${i + 1}',
      title: '[DATA_NAME] ${i + 1}',
      subtitle: 'Owned by [ROLE_NAME] · ref #${1000 + i}',
      updatedAt: DateTime(2026, 9, 7).subtract(Duration(hours: i * 5)),
    ),
  );

  /// Flip to true in a demo to exercise the error/offline states.
  bool failNextRead = false;

  @override
  Future<Result<List<Item>>> list({bool forceRefresh = false}) async {
    await Future<void>.delayed(latency);
    if (failNextRead) {
      failNextRead = false;
      return const Result.failure(OfflineFailure());
    }
    return Result.success(
      _store.where((it) => !it.archived).toList(growable: false),
    );
  }

  @override
  Future<Result<Item>> getById(String id) async {
    await Future<void>.delayed(latency);
    final match = _store.where((it) => it.id == id).firstOrNull;
    return match == null
        ? const Result.failure(NotFoundFailure())
        : Result.success(match);
  }

  @override
  Future<Result<Item>> setArchived(String id, {required bool archived}) async {
    await Future<void>.delayed(latency);
    final idx = _store.indexWhere((it) => it.id == id);
    if (idx < 0) return const Result.failure(NotFoundFailure());
    final updated = _store[idx].copyWith(archived: archived);
    _store[idx] = updated;
    return Result.success(updated);
  }
}
