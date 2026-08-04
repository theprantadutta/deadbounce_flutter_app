import '../entities/profile_data.dart';

abstract interface class ProfileRepository {
  Future<ProfileData> getProfile();

  /// Records that the guest upgraded to a permanent account: flips the local
  /// profile off guest status and enqueues the `accountLinked` sync event in
  /// the SAME transaction, so the local truth and the outbox row can never
  /// disagree.
  ///
  /// [provider] is sent verbatim to the backend, which parses it into its
  /// `AuthProvider` enum (`google`, `apple`, …).
  Future<void> markAccountLinked({
    required String provider,
    String? displayName,
    String? photoUrl,
  });
}
