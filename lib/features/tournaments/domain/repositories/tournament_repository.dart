import '../entities/tournament.dart';

/// Surfaced when a tournament action can't proceed (e.g. not enough coins).
class TournamentException implements Exception {
  const TournamentException(this.message);
  final String message;
  @override
  String toString() => 'TournamentException: $message';
}

abstract interface class TournamentRepository {
  /// Cache-first stream of all known tournaments (active + recently ended).
  Stream<List<Tournament>> watchAll();

  Future<Tournament?> getById(String id);

  /// Pulls the latest tournament list from the server into the cache.
  /// Throws on network error (the cubit keeps showing cache).
  Future<void> refresh();

  /// Pays the entry fee and joins. Online-only (POST). Throws
  /// [TournamentException] when the player can't afford it, or on network
  /// error. Caches the tournament so it can then be played offline.
  Future<Tournament> join(String id);

  /// The locally-cached standings for instant (cache-first) paint. Returns an
  /// empty board when nothing is cached yet.
  Future<TournamentBoard> cachedBoard(String id);

  /// Fetches the per-tournament board from the server and refreshes the cache,
  /// falling back to [cachedBoard] when offline. Pair with [cachedBoard] to
  /// paint cache immediately, then update with this.
  Future<TournamentBoard> leaderboard(String id);

  /// Claims the finalized rank reward. Offline-capable: it credits the local
  /// ledger and enqueues a `coinTxn` (reason `tournamentReward`) carrying the
  /// tournament id; the server re-validates the amount against the finalized
  /// payout and enforces single-claim when the event eventually syncs.
  Future<void> claimReward(Tournament tournament);
}
