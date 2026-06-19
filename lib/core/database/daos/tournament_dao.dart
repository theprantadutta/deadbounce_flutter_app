import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tournament_table.dart';

part 'tournament_dao.g.dart';

@DriftAccessor(tables: [Tournaments, TournamentLeaderboardCache])
class TournamentDao extends DatabaseAccessor<AppDatabase>
    with _$TournamentDaoMixin {
  TournamentDao(super.db);

  Stream<List<TournamentRow>> watchAll() => (select(tournaments)
        ..orderBy([
          (t) => OrderingTerm.asc(t.cadence),
          (t) => OrderingTerm.desc(t.endsAt),
        ]))
      .watch();

  Future<TournamentRow?> getById(String id) =>
      (select(tournaments)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Caches the server's tournament list, MERGING with local state so offline
  /// progress survives: `bestScore` keeps the max, `joined`/`rewardClaimed`
  /// stay true once set locally. Tournaments no longer returned by the server
  /// are pruned.
  Future<void> cacheList(List<TournamentRow> serverRows) => transaction(() async {
        final existing = {for (final r in await select(tournaments).get()) r.id: r};
        final keep = <String>{};
        for (final row in serverRows) {
          keep.add(row.id);
          final local = existing[row.id];
          final merged = row.copyWith(
            bestScore: math.max(row.bestScore, local?.bestScore ?? 0),
            joined: row.joined || (local?.joined ?? false),
            rewardClaimed: row.rewardClaimed || (local?.rewardClaimed ?? false),
          );
          await into(tournaments).insertOnConflictUpdate(merged);
        }
        // Drop tournaments the server no longer lists.
        await (delete(tournaments)..where((t) => t.id.isNotIn(keep.toList()))).go();
      });

  /// Upserts a single tournament (e.g. from the join response) and marks the
  /// player joined, preserving any higher local best score.
  Future<void> upsertJoined(TournamentRow row) => transaction(() async {
        final local = await getById(row.id);
        await into(tournaments).insertOnConflictUpdate(row.copyWith(
          joined: true,
          bestScore: math.max(row.bestScore, local?.bestScore ?? 0),
        ));
      });

  /// Records a tournament run's best score locally (keep max).
  Future<void> recordBest(String id, int score) => transaction(() async {
        final local = await getById(id);
        if (local == null) return;
        if (score > local.bestScore) {
          await (update(tournaments)..where((t) => t.id.equals(id)))
              .write(TournamentsCompanion(bestScore: Value(score)));
        }
      });

  Future<void> markRewardClaimed(String id) =>
      (update(tournaments)..where((t) => t.id.equals(id)))
          .write(const TournamentsCompanion(rewardClaimed: Value(true)));

  // ---- per-tournament leaderboard cache ----

  Future<void> replaceBoard(
    String tournamentId,
    List<TournamentLeaderboardRow> rows,
  ) =>
      transaction(() async {
        await (delete(tournamentLeaderboardCache)
              ..where((e) => e.tournamentId.equals(tournamentId)))
            .go();
        await batch((b) => b.insertAll(tournamentLeaderboardCache, rows));
      });

  Future<List<TournamentLeaderboardRow>> getBoard(String tournamentId) =>
      (select(tournamentLeaderboardCache)
            ..where((e) => e.tournamentId.equals(tournamentId))
            ..orderBy([(e) => OrderingTerm.asc(e.rank)]))
          .get();
}
