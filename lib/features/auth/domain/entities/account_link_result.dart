import 'auth_user.dart';

/// Outcome of a guest → permanent-account link.
///
/// Returned rather than thrown because the caller (the Profile CTA) has to
/// render four genuinely different UIs, and because **a failed link must never
/// look like a sign-out** — the guest is still signed in and still owns their
/// progress no matter which of these comes back.
sealed class AccountLinkResult {
  const AccountLinkResult();
}

/// Linked. The Firebase UID — and therefore the local database — is unchanged.
final class AccountLinkSuccess extends AccountLinkResult {
  const AccountLinkSuccess(this.user);

  final AuthUser user;
}

/// The user dismissed the account picker. Not an error; show nothing.
final class AccountLinkCancelled extends AccountLinkResult {
  const AccountLinkCancelled();
}

/// That Google account already backs a different Deadbounce account.
///
/// Unresolvable automatically: this device's guest progress and the existing
/// account's progress both exist, and we cannot merge them. The UI must ask
/// which one the player wants to keep.
final class AccountLinkCredentialInUse extends AccountLinkResult {
  const AccountLinkCredentialInUse({this.email});

  final String? email;
}

/// Anything else — offline, Firebase rejection, backend refusal.
final class AccountLinkFailed extends AccountLinkResult {
  const AccountLinkFailed(this.message);

  /// Already user-presentable.
  final String message;
}
