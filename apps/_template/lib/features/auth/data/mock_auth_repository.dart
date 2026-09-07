import 'package:amds_core/amds_core.dart';

import '../domain/auth_repository.dart';
import '../domain/session.dart';

/// Accepts any well-formed email with a password of 8+ characters. Anything
/// else fails the way the real API would. No persistence.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({this.latency = const Duration(milliseconds: 400)});

  final Duration latency;
  Session? _session;

  @override
  Future<Session?> restore() async => _session;

  @override
  Future<Result<Session>> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(latency);

    final errors = <String, String>{};
    if (!email.contains('@')) errors['email'] = 'Enter a valid email.';
    if (password.length < 8) {
      errors['password'] = 'Password must be at least 8 characters.';
    }
    if (errors.isNotEmpty) {
      return Result.failure(ValidationFailure(errors));
    }
    if (password == 'wrong-password') {
      return const Result.failure(
        ValidationFailure({'form': 'Incorrect email or password.'}),
      );
    }

    _session = Session(
      userId: 'usr_1',
      email: email,
      displayName: email.split('@').first,
    );
    return Result.success(_session!);
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(latency);
    _session = null;
  }
}
