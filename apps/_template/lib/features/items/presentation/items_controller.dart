// Presentation state for the items list. `AsyncNotifier` gives us
// loading / data / error for free; we translate domain [Failure]s into it.
// See docs/starter-template/state-management.md §async.

import 'package:amds_core/amds_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di.dart';
import '../domain/item.dart';
import '../domain/items_repository.dart';

class ItemsController extends AsyncNotifier<List<Item>> {
  @override
  Future<List<Item>> build() => _load();

  Future<List<Item>> _load({bool forceRefresh = false}) async {
    final repo = ref.read(itemsRepositoryProvider);
    final result = await repo.list(forceRefresh: forceRefresh);
    return result.fold(
      onSuccess: (items) => items,
      onFailure: (f) => throw FailureException(f),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<Item>>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _load(forceRefresh: true));
  }

  /// Returns null on success or a user-facing message on failure.
  Future<String?> create(ItemDraft draft) => _mutate(
        (repo) => repo.create(draft),
      );

  Future<String?> edit(String id, {String? title, String? subtitle}) => _mutate(
        (repo) => repo.update(id, title: title, subtitle: subtitle),
      );

  Future<String?> approve(String id) =>
      _mutate((repo) => repo.setStatus(id, ItemStatus.approved));

  Future<String?> archive(String id) =>
      _mutate((repo) => repo.setStatus(id, ItemStatus.archived));

  Future<String?> _mutate(
    Future<Result<Item>> Function(ItemsRepository repo) op,
  ) async {
    final repo = ref.read(itemsRepositoryProvider);
    final result = await op(repo);
    return result.fold(
      onSuccess: (_) {
        ref.invalidateSelf();
        return null;
      },
      onFailure: (f) => f.message,
    );
  }
}

/// Carries a domain [Failure] through `AsyncValue.error` so the UI can render
/// the matching AMDS state widget.
class FailureException implements Exception {
  const FailureException(this.failure);
  final Failure failure;
  @override
  String toString() => failure.message;
}

final itemsControllerProvider =
    AsyncNotifierProvider<ItemsController, List<Item>>(ItemsController.new);

/// Single-item read for the detail / edit routes. Throws [FailureException] on
/// failure so the screen renders the matching AMDS state.
final itemByIdProvider = FutureProvider.family<Item, String>((ref, id) async {
  // depend on the list so an edit/approve refreshes the detail too
  ref.watch(itemsControllerProvider);
  final result = await ref.read(itemsRepositoryProvider).getById(id);
  return result.fold(
    onSuccess: (item) => item,
    onFailure: (f) => throw FailureException(f),
  );
});
