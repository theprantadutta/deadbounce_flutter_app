import 'package:drift/drift.dart';

/// Local projection of a server tournament + THIS player's entry state, so the
/// list/detail/board read cache-first offline. The player's `bestScore` and
/// `joined` are merged (kept max / OR'd) on refresh so offline progress isn't
/// clobbered by a stale server fetch.
@DataClassName('TournamentRow')
class Tournaments extends Table {
  TextColumn get id => text()();
  TextColumn get cadence => text()(); // daily | weekly | monthly
  TextColumn get state => text()(); // active | ended | upcoming
  TextColumn get name => text()();
  TextColumn get tagline => text().withDefault(const Constant(''))();
  IntColumn get startsAt => integer()(); // ms since epoch (UTC)
  IntColumn get endsAt => integer()();
  IntColumn get seed => integer()();
  TextColumn get configJson => text().withDefault(const Constant('{}'))();
  IntColumn get entryFeeCoins => integer().withDefault(const Constant(0))();
  TextColumn get rewardTableJson => text().withDefault(const Constant('{}'))();

  // Player entry state.
  BoolColumn get joined => boolean().withDefault(const Constant(false))();
  IntColumn get bestScore => integer().withDefault(const Constant(0))();
  IntColumn get rank => integer().nullable()();
  IntColumn get rewardCoins => integer().nullable()();
  BoolColumn get rewardClaimed => boolean().withDefault(const Constant(false))();

  IntColumn get lastSyncedAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached per-tournament leaderboard standings for offline viewing.
@DataClassName('TournamentLeaderboardRow')
class TournamentLeaderboardCache extends Table {
  @override
  String get tableName => 'tournament_leaderboard_cache';

  TextColumn get tournamentId => text()();
  IntColumn get rank => integer()();
  TextColumn get userId => text()();
  TextColumn get username => text()();
  IntColumn get score => integer()();
  BoolColumn get isPlayer => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {tournamentId, rank};
}
