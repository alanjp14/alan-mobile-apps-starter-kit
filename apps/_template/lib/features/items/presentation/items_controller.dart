// Presentation state for the items list. `AsyncNotifier` gives us
// loading / data / error for free; we translate domain [Failure]s into it.
// See docs/starter-template/state-management.md §async.

import 'package:amds_core/amds_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di.dart';
import '../domain/item.dart';

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

  Future<void> archive(String id) async {
    final repo = ref.read(itemsRepositoryProvider);
    final result = await repo.setArchived(id, archived: true);
    if (result.isSuccess) {
      state = AsyncData(
        (state.valueOrNull ?? const []).where((it) => it.id != id).toList(),
      );
    }
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

/// Single-item read for the detail route. Throws [FailureException] on failure
/// so the screen renders the matching AMDS state.
final itemByIdProvider = FutureProvider.family<Item, String>((ref, id) async {
  final result = await ref.watch(itemsRepositoryProvider).getById(id);
  return result.fold(
    onSuccess: (item) => item,
    onFailure: (f) => throw FailureException(f),
  );
});
