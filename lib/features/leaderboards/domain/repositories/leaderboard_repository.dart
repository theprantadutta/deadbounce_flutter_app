import '../entities/leaderboard_board.dart';

abstract interface class LeaderboardRepository {
  /// The cached standings for [tab] (offline-friendly), or null if this
  /// board has never been fetched on this device.
  Future<LeaderboardBoard?> getCached(LeaderboardTab tab);

  /// Fetches fresh standings from the server, writes them through to the
  /// Drift cache, and returns them. Throws on network/server failure —
  /// the cubit falls back to the cache.
  Future<LeaderboardBoard> refresh(LeaderboardTab tab);
}
