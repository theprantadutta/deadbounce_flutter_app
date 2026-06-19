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

/// Result of a silent session-token refresh.
enum SessionRefreshOutcome {
  /// A fresh JWT was minted and stored.
  refreshed,

  /// The server/Firebase explicitly rejected the identity (account disabled or
  /// deleted) — the session should be ended.
  identityRejected,

  /// Couldn't refresh right now (offline, no Firebase user yet, server down) —
  /// keep the current session and try again later.
  unavailable,
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

  /// Restores a previous session from local storage WITHOUT a network call,
  /// so the app stays logged in offline. Returns null when there is no stored
  /// session (first login requires internet).
  Future<AuthUser?> restoreSession();

  /// Silently mints a fresh Deadbounce JWT by re-exchanging the current
  /// Firebase identity (works even if the old JWT has expired). See
  /// [SessionRefreshOutcome] for how callers should react.
  Future<SessionRefreshOutcome> refreshSessionToken();

  Future<void> signOut();
}
