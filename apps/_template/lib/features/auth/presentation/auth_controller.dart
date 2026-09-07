import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di.dart';
import '../domain/session.dart';

/// Holds the auth state for the whole app. `null` data = signed out.
/// The router watches this to gate routes.
class AuthController extends AsyncNotifier<Session?> {
  @override
  Future<Session?> build() => ref.read(authRepositoryProvider).restore();

  bool get isSignedIn => state.valueOrNull != null;

  /// Returns null on success, or a user-facing message on failure.
  Future<String?> signIn(String email, String password) async {
    state = const AsyncLoading<Session?>().copyWithPrevious(state);
    final result = await ref
        .read(authRepositoryProvider)
        .signIn(email: email.trim(), password: password);
    return result.fold(
      onSuccess: (session) {
        state = AsyncData(session);
        return null;
      },
      onFailure: (f) {
        state = const AsyncData(null);
        return f.message;
      },
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, Session?>(AuthController.new);
