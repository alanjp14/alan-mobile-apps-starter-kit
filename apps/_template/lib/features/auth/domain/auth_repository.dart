import 'package:amds_core/amds_core.dart';

import 'session.dart';

abstract interface class AuthRepository {
  /// The session restored from storage on cold start, or null.
  Future<Session?> restore();

  Future<Result<Session>> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
