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

  /// Cache-first per-tournament leaderboard; refreshes from the server when
  /// online.
  Future<TournamentBoard> leaderboard(String id);

  /// Claims the finalized rank reward (writes the reward coin txn). Online
  /// fetch of the authoritative amount happens in [refresh]/the result fetch.
  Future<void> claimReward(Tournament tournament);
}
