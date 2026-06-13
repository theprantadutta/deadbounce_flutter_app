import '../../../../core/database/app_database.dart';
import '../../domain/entities/leaderboard_board.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../datasources/leaderboard_api.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  LeaderboardRepositoryImpl({
    required this._db,
    required this._api,
  });

  final AppDatabase _db;
  final LeaderboardApi _api;

  // We only ever cache the CURRENT period of each board, so one constant
  // period key per board keeps the cache replace-in-place.
  static const String _periodKey = 'current';

  @override
  Future<LeaderboardBoard?> getCached(LeaderboardTab tab) async {
    final meta = await _db.leaderboardCacheDao.getMeta(tab.cacheKey);
    if (meta == null) return null;

    final rows = await _db.leaderboardCacheDao.getBoard(tab.cacheKey);
    return LeaderboardBoard(
      tab: tab,
      rows: rows
          .map((r) => LeaderboardRow(
                rank: r.rank,
                userId: r.userId,
                username: r.username,
                score: r.score,
                isPlayer: r.isPlayer,
              ))
          .toList(),
      playerRank: meta.playerRank,
      playerScore: meta.playerScore,
      lastSynced:
          DateTime.fromMillisecondsSinceEpoch(meta.lastSyncedAt, isUtc: true),
    );
  }

  @override
  Future<LeaderboardBoard> refresh(LeaderboardTab tab) async {
    final dto = await _api.fetch(tab);
    final myId = (await _db.profileDao.getProfile())?.userId;
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;

    final cacheRows = [
      for (final r in dto.rows)
        LeaderboardCacheRow(
          boardType: tab.cacheKey,
          periodKey: _periodKey,
          rank: r.rank,
          userId: r.userId,
          username: r.username,
          score: r.score,
          isPlayer: myId != null && r.userId == myId,
        ),
    ];

    await _db.leaderboardCacheDao.replaceBoard(
      boardType: tab.cacheKey,
      periodKey: _periodKey,
      rows: cacheRows,
      meta: LeaderboardSyncMetaRow(
        boardType: tab.cacheKey,
        periodKey: _periodKey,
        lastSyncedAt: nowMs,
        playerRank: dto.playerRank,
        playerScore: dto.playerScore,
      ),
    );

    return (await getCached(tab))!;
  }
}
