import '../entities/auth_user.dart';

/// Failure surfaced from the auth flow with a user-presentable message.
class AuthFailure implements Exception {
  AuthFailure(this.message);

  final String message;

  @override
  String toString() => 'AuthFailure: $message';
}

/// Thrown when the user backs out of an interactive flow (e.g. closes the
/// Google account picker). Cubits treat it as a silent no-op, not an error.
class AuthCancelled implements Exception {
  const AuthCancelled();
}

/// Contract the presentation layer talks to. Implementations live in the
/// data layer (Firebase sign-in + Deadbounce token exchange + storage).
abstract interface class AuthRepository {
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> signInWithGoogle();

  Future<AuthUser> signInAsGuest();

  /// Restores a previous session from the stored token, validating it
  /// against the backend. Returns null when there is no valid session.
  Future<AuthUser?> restoreSession();

  Future<void> signOut();
}
