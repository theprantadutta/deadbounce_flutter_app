import 'package:drift/drift.dart';

/// Cached leaderboard standings for offline viewing.
/// boardType ∈ {daily, weekly, alltime, dailyChallenge}.
@DataClassName('LeaderboardCacheRow')
class LeaderboardCacheEntries extends Table {
  @override
  String get tableName => 'leaderboard_cache';

  TextColumn get boardType => text()();
  TextColumn get periodKey => text()();
  IntColumn get rank => integer()();
  TextColumn get userId => text()();
  TextColumn get username => text()();
  IntColumn get score => integer()();
  BoolColumn get isPlayer => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {boardType, periodKey, rank};
}

/// Per-board sync metadata: when the cache was refreshed and where the
/// player ranked (the player may be far outside the cached top-N).
@DataClassName('LeaderboardSyncMetaRow')
class LeaderboardSyncMeta extends Table {
  TextColumn get boardType => text()();
  TextColumn get periodKey => text()();
  IntColumn get lastSyncedAt => integer()();
  IntColumn get playerRank => integer().nullable()();
  IntColumn get playerScore => integer().nullable()();

  @override
  Set<Column> get primaryKey => {boardType};
}
