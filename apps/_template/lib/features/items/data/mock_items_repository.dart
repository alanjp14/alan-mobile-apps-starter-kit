import 'package:amds_core/amds_core.dart';

import '../domain/item.dart';
import '../domain/items_repository.dart';

/// In-memory fake with artificial latency. Lets the whole app run — and every
/// state (loading / empty / error / offline) be demoed — with no backend.
/// Delete once a real [ItemsRepository] impl exists.
class MockItemsRepository implements ItemsRepository {
  MockItemsRepository({this.latency = const Duration(milliseconds: 400)});

  final Duration latency;
  var _seq = 100;

  final List<Item> _store = List.generate(
    6,
    (i) => Item(
      id: 'itm_${i + 1}',
      title: '[DATA_NAME] ${i + 1}',
      subtitle: 'Owned by [ROLE_NAME] · ref #${1000 + i}',
      updatedAt: DateTime(2026, 9, 7).subtract(Duration(hours: i * 5)),
      status: i.isEven ? ItemStatus.pending : ItemStatus.approved,
    ),
  );

  /// Flip to true in a demo to exercise the error/offline states.
  bool failNextRead = false;

  Future<void> get _tick => Future<void>.delayed(latency);

  @override
  Future<Result<List<Item>>> list({bool forceRefresh = false}) async {
    await _tick;
    if (failNextRead) {
      failNextRead = false;
      return const Result.failure(OfflineFailure());
    }
    return Result.success(
      _store.where((it) => !it.isArchived).toList(growable: false),
    );
  }

  @override
  Future<Result<Item>> getById(String id) async {
    await _tick;
    final match = _store.where((it) => it.id == id).firstOrNull;
    return match == null
        ? const Result.failure(NotFoundFailure())
        : Result.success(match);
  }

  @override
  Future<Result<Item>> create(ItemDraft draft) async {
    await _tick;
    final item = Item(
      id: 'itm_${++_seq}',
      title: draft.title,
      subtitle: draft.subtitle,
      updatedAt: DateTime.now(),
    );
    _store.insert(0, item);
    return Result.success(item);
  }

  @override
  Future<Result<Item>> update(
    String id, {
    String? title,
    String? subtitle,
  }) async {
    await _tick;
    final idx = _store.indexWhere((it) => it.id == id);
    if (idx < 0) return const Result.failure(NotFoundFailure());
    final updated = _store[idx].copyWith(
      title: title,
      subtitle: subtitle,
      updatedAt: DateTime.now(),
    );
    _store[idx] = updated;
    return Result.success(updated);
  }

  @override
  Future<Result<Item>> setStatus(String id, ItemStatus status) async {
    await _tick;
    final idx = _store.indexWhere((it) => it.id == id);
    if (idx < 0) return const Result.failure(NotFoundFailure());
    final updated =
        _store[idx].copyWith(status: status, updatedAt: DateTime.now());
    _store[idx] = updated;
    return Result.success(updated);
  }
}
