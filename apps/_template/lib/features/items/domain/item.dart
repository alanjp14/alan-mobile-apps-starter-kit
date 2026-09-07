import 'package:flutter/foundation.dart';

/// A domain entity — plain, immutable, framework-free. Rename to your real
/// aggregate ([DATA_NAME]). Keep JSON mapping in the data layer, not here.
@immutable
class Item {
  const Item({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.updatedAt,
    this.archived = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime updatedAt;
  final bool archived;

  Item copyWith({String? title, String? subtitle, bool? archived}) => Item(
        id: id,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        updatedAt: updatedAt,
        archived: archived ?? this.archived,
      );

  @override
  bool operator ==(Object other) =>
      other is Item &&
      other.id == id &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.updatedAt == updatedAt &&
      other.archived == archived;

  @override
  int get hashCode => Object.hash(id, title, subtitle, updatedAt, archived);
}
