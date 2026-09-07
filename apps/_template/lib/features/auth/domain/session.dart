import 'package:flutter/foundation.dart';

/// The signed-in user. In a real app this also carries tokens (kept in secure
/// storage, never in memory longer than needed) — see
/// docs/starter-template/security.md.
@immutable
class Session {
  const Session({
    required this.userId,
    required this.email,
    required this.displayName,
  });

  final String userId;
  final String email;
  final String displayName;
}
