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

/// Thrown when linking a guest to a credential that ALREADY belongs to another
/// Deadbounce account.
///
/// Deliberately its own type rather than an [AuthFailure] message: it is the
/// one link outcome the app cannot resolve on the user's behalf. Two sets of
/// progress exist (this device's guest run history, and whatever that Google
/// account already has), and merging them is not something we can do — so the
/// UI has to ask which one to keep.
class AccountLinkConflict implements Exception {
  const AccountLinkConflict({this.email});

  /// The conflicting account's email, when Firebase tells us. Shown in the
  /// dialog so the user recognises which account they picked.
  final String? email;

  @override
  String toString() => 'AccountLinkConflict(email: $email)';
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

  /// Upgrades the signed-in GUEST into a permanent Google account, keeping the
  /// Firebase UID — and therefore the whole local database — intact.
  ///
  /// Throws [AccountLinkConflict] when that Google account already belongs to
  /// another Deadbounce account, [AuthCancelled] if the picker is dismissed,
  /// and [AuthFailure] for everything else.
  Future<AuthUser> linkWithGoogle();

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
