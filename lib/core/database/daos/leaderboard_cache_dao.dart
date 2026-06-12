import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/leaderboard_cache_table.dart';

part 'leaderboard_cache_dao.g.dart';

@DriftAccessor(tables: [LeaderboardCacheEntries, LeaderboardSyncMeta])
class LeaderboardCacheDao extends DatabaseAccessor<AppDatabase>
    with _$LeaderboardCacheDaoMixin {
  LeaderboardCacheDao(super.db);

  /// Atomically replaces a board's cached standings + metadata.
  Future<void> replaceBoard({
    required String boardType,
    required String periodKey,
    required List<LeaderboardCacheRow> rows,
    required LeaderboardSyncMetaRow meta,
  }) =>
      transaction(() async {
        await (delete(leaderboardCacheEntries)
              ..where((e) => e.boardType.equals(boardType)))
            .go();
        await batch((b) => b.insertAll(leaderboardCacheEntries, rows));
        await into(leaderboardSyncMeta).insertOnConflictUpdate(meta);
      });

  Future<List<LeaderboardCacheRow>> getBoard(String boardType) =>
      (select(leaderboardCacheEntries)
            ..where((e) => e.boardType.equals(boardType))
            ..orderBy([(e) => OrderingTerm.asc(e.rank)]))
          .get();

  Future<LeaderboardSyncMetaRow?> getMeta(String boardType) =>
      (select(leaderboardSyncMeta)
            ..where((m) => m.boardType.equals(boardType)))
          .getSingleOrNull();
}
