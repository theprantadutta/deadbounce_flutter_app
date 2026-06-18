import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/stats_dao.dart';
import '../../domain/entities/profile_data.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<ProfileData> getProfile() async {
    final profile = await _db.profileDao.getProfile();
    final stats = await _db.statsDao.getStats();
    final upgradePicks =
        await _db.statsDao.getCounters(StatsDao.kindUpgradePick);

    String? favorite;
    if (upgradePicks.isNotEmpty) {
      favorite = upgradePicks.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    return ProfileData(
      displayName: profile?.displayName ??
          profile?.username ??
          (profile?.isGuest ?? false ? 'Stranger' : 'Gunslinger'),
      isGuest: profile?.isGuest ?? false,
      runsPlayed: stats?.runsPlayed ?? 0,
      totalKills: stats?.totalKills ?? 0,
      bestScore: stats?.bestScore ?? 0,
      bestChain: stats?.bestChain ?? 0,
      bestBounceKill: stats?.bestBounceKill ?? 0,
      bestWave: stats?.bestWave ?? 0,
      totalCoinsEarned: stats?.totalCoinsEarned ?? 0,
      totalPlayMs: stats?.totalPlayMs ?? 0,
      favoriteUpgradeId: favorite,
    );
  }
}
