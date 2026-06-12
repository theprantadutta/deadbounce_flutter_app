import 'package:drift/drift.dart';

/// Single-row table (id 0): lifetime aggregates. Per-enemy / per-upgrade
/// counters live in [StatCounters] (stat_counters_table.dart).
@DataClassName('PlayerStatsRow')
class PlayerStatsTable extends Table {
  @override
  String get tableName => 'player_stats';

  IntColumn get id => integer().withDefault(const Constant(0))();
  IntColumn get runsPlayed => integer().withDefault(const Constant(0))();
  IntColumn get totalKills => integer().withDefault(const Constant(0))();
  IntColumn get bestScore => integer().withDefault(const Constant(0))();
  IntColumn get bestChain => integer().withDefault(const Constant(0))();
  IntColumn get bestBounceKill => integer().withDefault(const Constant(0))();
  IntColumn get totalWavesCleared => integer().withDefault(const Constant(0))();
  IntColumn get totalCoinsEarned => integer().withDefault(const Constant(0))();
  IntColumn get bestWave => integer().withDefault(const Constant(0))();
  IntColumn get totalPlayMs => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
