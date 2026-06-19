import 'package:drift/drift.dart';

/// History of completed runs.
@DataClassName('RunRow')
class Runs extends Table {
  /// Client-generated uuid v4 — also the backend GameRun PK.
  TextColumn get id => text()();
  IntColumn get score => integer()();
  IntColumn get waveReached => integer()();
  IntColumn get kills => integer()();
  IntColumn get bestChain => integer()();
  IntColumn get maxBounceKill => integer()();
  IntColumn get durationMs => integer()();
  IntColumn get coinsEarned => integer()();
  BoolColumn get isDailyChallenge =>
      boolean().withDefault(const Constant(false))();

  /// UTC date yyyy-MM-dd when this run was a daily challenge attempt.
  TextColumn get challengeDate => text().nullable()();

  /// Tournament id when this run was a tournament entry.
  TextColumn get tournamentId => text().nullable()();
  TextColumn get arenaId => text()();

  /// JSON array of upgrade card ids picked during the run, in order.
  TextColumn get upgradesPicked => text().withDefault(const Constant('[]'))();
  IntColumn get endedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
