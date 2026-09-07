import 'package:amds_core/amds_core.dart';
import 'package:app_template/core/di.dart';
import 'package:app_template/features/items/domain/item.dart';
import 'package:app_template/features/items/domain/items_repository.dart';
import 'package:app_template/features/items/presentation/items_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements ItemsRepository {
  _FakeRepo(this._result);
  final Result<List<Item>> _result;
  int listCalls = 0;

  @override
  Future<Result<List<Item>>> list({bool forceRefresh = false}) async {
    listCalls++;
    return _result;
  }

  @override
  Future<Result<Item>> getById(String id) async =>
      const Result.failure(NotFoundFailure());

  @override
  Future<Result<Item>> setArchived(String id, {required bool archived}) async {
    final it = Item(
        id: id,
        title: 't',
        subtitle: 's',
        updatedAt: DateTime(2026),
        archived: archived);
    return Result.success(it);
  }
}

ProviderContainer _container(ItemsRepository repo) {
  final c = ProviderContainer(
    overrides: [itemsRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(c.dispose);
  return c;
}

void main() {
  final sample = [
    Item(id: 'a', title: 'A', subtitle: '-', updatedAt: DateTime(2026, 1, 1)),
  ];

  test('exposes repository data as AsyncData', () async {
    final c = _container(_FakeRepo(Result.success(sample)));
    final value = await c.read(itemsControllerProvider.future);
    expect(value, sample);
  });

  test('maps a Failure to AsyncError carrying the Failure', () async {
    final c = _container(_FakeRepo(const Result.failure(OfflineFailure())));
    await expectLater(
      c.read(itemsControllerProvider.future),
      throwsA(isA<FailureException>()
          .having((e) => e.failure, 'failure', isA<OfflineFailure>())),
    );
  });

  test('archive removes the row optimistically', () async {
    final repo = _FakeRepo(Result.success([
      Item(id: 'a', title: 'A', subtitle: '-', updatedAt: DateTime(2026)),
      Item(id: 'b', title: 'B', subtitle: '-', updatedAt: DateTime(2026)),
    ]));
    final c = _container(repo);
    await c.read(itemsControllerProvider.future);

    await c.read(itemsControllerProvider.notifier).archive('a');

    final rows = c.read(itemsControllerProvider).value!;
    expect(rows.map((it) => it.id), ['b']);
  });
}
