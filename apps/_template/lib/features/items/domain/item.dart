import 'package:flutter/foundation.dart';

/// Where an item sits in its lifecycle. Rename to your real workflow states.
enum ItemStatus { pending, approved, archived }

/// A domain entity — plain, immutable, framework-free. Rename to your real
/// aggregate ([DATA_NAME]). Keep JSON mapping in the data layer, not here.
@immutable
class Item {
  const Item({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.updatedAt,
    this.status = ItemStatus.pending,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime updatedAt;
  final ItemStatus status;

  bool get isArchived => status == ItemStatus.archived;

  Item copyWith({
    String? title,
    String? subtitle,
    DateTime? updatedAt,
    ItemStatus? status,
  }) =>
      Item(
        id: id,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        updatedAt: updatedAt ?? this.updatedAt,
        status: status ?? this.status,
      );

  @override
  bool operator ==(Object other) =>
      other is Item &&
      other.id == id &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.updatedAt == updatedAt &&
      other.status == status;

  @override
  int get hashCode => Object.hash(id, title, subtitle, updatedAt, status);
}

/// The fields a user supplies when creating an item. Separate from [Item] so
/// the server owns id/timestamps.
@immutable
class ItemDraft {
  const ItemDraft({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}
