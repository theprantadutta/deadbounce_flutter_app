import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/player_stats_table.dart';
import '../tables/stat_counters_table.dart';

part 'stats_dao.g.dart';

/// Deltas a completed run applies to the lifetime aggregates.
class RunStatDeltas {
  const RunStatDeltas({
    required this.kills,
    required this.wavesCleared,
    required this.coinsEarned,
    required this.playMs,
    required this.score,
    required this.chain,
    required this.bounceKill,
    required this.wave,
    this.enemyKills = const {},
    this.upgradePicks = const {},
  });

  final int kills;
  final int wavesCleared;
  final int coinsEarned;
  final int playMs;

  /// Candidates for the "best" fields — folded with MAX.
  final int score;
  final int chain;
  final int bounceKill;
  final int wave;

  final Map<String, int> enemyKills;
  final Map<String, int> upgradePicks;
}

@DriftAccessor(tables: [PlayerStatsTable, StatCounters])
class StatsDao extends DatabaseAccessor<AppDatabase> with _$StatsDaoMixin {
  StatsDao(super.db);

  static const String kindEnemyKill = 'enemyKill';
  static const String kindUpgradePick = 'upgradePick';

  Future<PlayerStatsRow?> getStats() =>
      (select(playerStatsTable)..where((s) => s.id.equals(0)))
          .getSingleOrNull();

  Stream<PlayerStatsRow?> watchStats() =>
      (select(playerStatsTable)..where((s) => s.id.equals(0)))
          .watchSingleOrNull();

  /// Ensures the singleton row exists (no-op when present).
  Future<void> ensureRow() => into(playerStatsTable).insert(
        PlayerStatsTableCompanion.insert(
          id: const Value(0),
          updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        ),
        mode: InsertMode.insertOrIgnore,
      );

  /// Applies a completed run's deltas. Caller wraps in a transaction with
  /// the rest of the run-end writes.
  Future<void> applyRunDeltas(RunStatDeltas d) async {
    await ensureRow();
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await customStatement(
      'UPDATE player_stats SET '
      'runs_played = runs_played + 1, '
      'total_kills = total_kills + ?, '
      'total_waves_cleared = total_waves_cleared + ?, '
      'total_coins_earned = total_coins_earned + ?, '
      'total_play_ms = total_play_ms + ?, '
      'best_score = MAX(best_score, ?), '
      'best_chain = MAX(best_chain, ?), '
      'best_bounce_kill = MAX(best_bounce_kill, ?), '
      'best_wave = MAX(best_wave, ?), '
      'updated_at = ? '
      'WHERE id = 0',
      [
        d.kills,
        d.wavesCleared,
        d.coinsEarned,
        d.playMs,
        d.score,
        d.chain,
        d.bounceKill,
        d.wave,
        now,
      ],
    );

    for (final e in d.enemyKills.entries) {
      await bumpCounter(kindEnemyKill, e.key, by: e.value);
    }
    for (final e in d.upgradePicks.entries) {
      await bumpCounter(kindUpgradePick, e.key, by: e.value);
    }
  }

  Future<void> bumpCounter(String kind, String key, {int by = 1}) =>
      customStatement(
        'INSERT INTO stat_counters (kind, key, count) VALUES (?, ?, ?) '
        'ON CONFLICT (kind, key) DO UPDATE SET count = count + ?',
        [kind, key, by, by],
      );

  Future<Map<String, int>> getCounters(String kind) async {
    final rows = await (select(statCounters)
          ..where((c) => c.kind.equals(kind)))
        .get();
    return {for (final r in rows) r.key: r.count};
  }

  /// Overwrites stats from a snapshot restore. Caller's transaction.
  Future<void> overwriteFromSnapshot(PlayerStatsTableCompanion stats) =>
      into(playerStatsTable).insertOnConflictUpdate(
        stats.copyWith(id: const Value(0)),
      );

  Future<void> overwriteCounter(String kind, String key, int count) =>
      into(statCounters).insertOnConflictUpdate(
        StatCountersCompanion.insert(kind: kind, key: key, count: Value(count)),
      );
}
