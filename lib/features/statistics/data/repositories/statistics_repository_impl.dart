import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/stats_dao.dart';
import '../../domain/entities/game_statistics.dart';
import '../../domain/repositories/statistics_repository.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  StatisticsRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<GameStatistics> getStatistics() async {
    final stats = await _db.statsDao.getStats();
    final enemyKills = await _db.statsDao.getCounters(StatsDao.kindEnemyKill);
    final upgradePicks =
        await _db.statsDao.getCounters(StatsDao.kindUpgradePick);

    if (stats == null) return const GameStatistics.empty();

    String? favorite;
    if (upgradePicks.isNotEmpty) {
      favorite = upgradePicks.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    return GameStatistics(
      runsPlayed: stats.runsPlayed,
      totalKills: stats.totalKills,
      totalWavesCleared: stats.totalWavesCleared,
      totalCoinsEarned: stats.totalCoinsEarned,
      totalPlayMs: stats.totalPlayMs,
      bestScore: stats.bestScore,
      bestChain: stats.bestChain,
      bestBounceKill: stats.bestBounceKill,
      bestWave: stats.bestWave,
      enemyKills: enemyKills,
      favoriteUpgradeId: favorite,
    );
  }
}
