import 'package:amds_core/amds_core.dart';
import 'package:app_template/core/di.dart';
import 'package:app_template/features/items/data/mock_items_repository.dart';
import 'package:app_template/features/items/domain/item.dart';
import 'package:app_template/features/items/domain/items_repository.dart';
import 'package:app_template/features/items/presentation/items_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A repo that always fails `list()` — for the error-mapping test.
class _FailingRepo implements ItemsRepository {
  const _FailingRepo(this.failure);
  final Failure failure;

  @override
  Future<Result<List<Item>>> list({bool forceRefresh = false}) async =>
      Result.failure(failure);
  @override
  Future<Result<Item>> getById(String id) async => Result.failure(failure);
  @override
  Future<Result<Item>> create(ItemDraft draft) async => Result.failure(failure);
  @override
  Future<Result<Item>> update(String id,
          {String? title, String? subtitle}) async =>
      Result.failure(failure);
  @override
  Future<Result<Item>> setStatus(String id, ItemStatus status) async =>
      Result.failure(failure);
}

ProviderContainer _container(ItemsRepository repo) {
  final c = ProviderContainer(
    overrides: [itemsRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  test('exposes repository data as AsyncData', () async {
    final c = _container(MockItemsRepository(latency: Duration.zero));
    final value = await c.read(itemsControllerProvider.future);
    expect(value, isNotEmpty);
    expect(value.every((it) => !it.isArchived), isTrue);
  });

  test('maps a Failure to AsyncError carrying the Failure', () async {
    final c = _container(const _FailingRepo(OfflineFailure()));
    await expectLater(
      c.read(itemsControllerProvider.future),
      throwsA(isA<FailureException>()
          .having((e) => e.failure, 'failure', isA<OfflineFailure>())),
    );
  });

  test('create adds a row and refreshes the list', () async {
    final c = _container(MockItemsRepository(latency: Duration.zero));
    final before = await c.read(itemsControllerProvider.future);

    final err = await c
        .read(itemsControllerProvider.notifier)
        .create(const ItemDraft(title: 'Fresh', subtitle: 'by test'));
    expect(err, isNull);

    final after = await c.read(itemsControllerProvider.future);
    expect(after.length, before.length + 1);
    expect(after.first.title, 'Fresh');
  });

  test('approve flips the status', () async {
    final c = _container(MockItemsRepository(latency: Duration.zero));
    final list = await c.read(itemsControllerProvider.future);
    final pending = list.firstWhere((it) => it.status == ItemStatus.pending);

    await c.read(itemsControllerProvider.notifier).approve(pending.id);

    final after = await c.read(itemsControllerProvider.future);
    expect(
      after.firstWhere((it) => it.id == pending.id).status,
      ItemStatus.approved,
    );
  });

  test('archive drops the row from the list', () async {
    final c = _container(MockItemsRepository(latency: Duration.zero));
    final list = await c.read(itemsControllerProvider.future);
    final target = list.first;

    await c.read(itemsControllerProvider.notifier).archive(target.id);

    final after = await c.read(itemsControllerProvider.future);
    expect(after.any((it) => it.id == target.id), isFalse);
  });
}
