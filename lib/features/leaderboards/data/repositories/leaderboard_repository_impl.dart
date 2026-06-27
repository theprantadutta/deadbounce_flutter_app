import 'package:deadbounce_flutter_app/core/logging/app_logger.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/leaderboard_board.dart';
import '../../domain/leaderboard_period.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../datasources/leaderboard_api.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  LeaderboardRepositoryImpl({
    required this._db,
    required this._api,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final LeaderboardApi _api;
  final DateTime Function() _now;

  @override
  Future<LeaderboardBoard?> getCached(LeaderboardTab tab) async {
    final meta = await _db.leaderboardCacheDao.getMeta(tab.cacheKey);
    if (meta == null) return null;

    // Period-aware: a cached board from a previous period (the UTC day / ISO
    // week / challenge date rolled over since the last sync) is NOT today's
    // board, so don't surface it as current — treat it as no cache, so the
    // cubit re-fetches (or shows the offline-empty state).
    if (meta.periodKey != leaderboardPeriodKey(tab, _now())) return null;

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
    final nowMs = _now().toUtc().millisecondsSinceEpoch;
    final periodKey = leaderboardPeriodKey(tab, _now());

    final cacheRows = [
      for (final r in dto.rows)
        LeaderboardCacheRow(
          boardType: tab.cacheKey,
          periodKey: periodKey,
          rank: r.rank,
          userId: r.userId,
          username: r.username,
          score: r.score,
          isPlayer: myId != null && r.userId == myId,
        ),
    ];

    await _db.leaderboardCacheDao.replaceBoard(
      boardType: tab.cacheKey,
      periodKey: periodKey,
      rows: cacheRows,
      meta: LeaderboardSyncMetaRow(
        boardType: tab.cacheKey,
        periodKey: periodKey,
        lastSyncedAt: nowMs,
        playerRank: dto.playerRank,
        playerScore: dto.playerScore,
      ),
    );

    AppLogger.talker.info(
      '[leaderboard] refreshed ${tab.cacheKey} (${dto.rows.length} rows)',
    );
    return (await getCached(tab))!;
  }
}
