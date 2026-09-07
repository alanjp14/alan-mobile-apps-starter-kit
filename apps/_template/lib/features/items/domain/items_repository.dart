import 'package:amds_core/amds_core.dart';

import 'item.dart';

/// The boundary the presentation layer depends on. Implementations live in
/// `data/` (mock now, HTTP later) and must never throw to callers — they
/// return [Result]. See docs/starter-template/networking.md.
abstract interface class ItemsRepository {
  Future<Result<List<Item>>> list({bool forceRefresh = false});

  Future<Result<Item>> getById(String id);

  Future<Result<Item>> create(ItemDraft draft);

  Future<Result<Item>> update(String id, {String? title, String? subtitle});

  Future<Result<Item>> setStatus(String id, ItemStatus status);
}
