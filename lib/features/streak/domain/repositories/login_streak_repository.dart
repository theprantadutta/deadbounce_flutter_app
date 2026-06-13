import '../entities/streak_state.dart';

/// Already claimed today — the cubit surfaces this as a no-op, not an error.
class AlreadyClaimedToday implements Exception {
  const AlreadyClaimedToday();
}

abstract interface class LoginStreakRepository {
  /// Computes the current streak standing under the local-calendar-day
  /// rule (see CLAUDE.md).
  Future<StreakState> getState();

  /// Claims today's reward: streak row + coin ledger entry + outbox event,
  /// all in one Drift transaction. Throws [AlreadyClaimedToday] when the
  /// local day was already claimed.
  Future<StreakClaimResult> claimToday();
}
