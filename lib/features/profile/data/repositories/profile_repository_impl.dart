import 'package:drift/drift.dart' show Value;

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/stats_dao.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/sync/sync_event.dart';
import '../../../../core/sync/sync_outbox_writer.dart';
import '../../domain/entities/profile_data.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._db, this._outbox);

  final AppDatabase _db;
  final SyncOutboxWriter _outbox;

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

  @override
  Future<void> markAccountLinked({
    required String provider,
    String? displayName,
    String? photoUrl,
  }) async {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    // One transaction: the profile flip and the outbox row commit together or
    // not at all. This is the load-bearing invariant of the offline-first
    // design — a profile that says "linked" with no queued event would never
    // tell the backend, and an event with no local flip would keep calling the
    // player a guest until the next sign-in.
    await _db.transaction(() async {
      final existing = await _db.profileDao.getProfile();
      await _db.profileDao.upsertProfile(
        PlayerProfilesCompanion(
          isGuest: const Value(false),
          // Only overwrite display fields when Google actually gave us one —
          // never blank out a name the player already had.
          displayName: displayName == null || displayName.isEmpty
              ? const Value.absent()
              : Value(displayName),
          photoUrl: photoUrl == null || photoUrl.isEmpty
              ? const Value.absent()
              : Value(photoUrl),
          createdAt: Value(existing?.createdAt ?? now),
          updatedAt: Value(now),
        ),
      );
      await _outbox.enqueue(
        SyncEntityType.accountLinked,
        {'provider': provider, 'linked_at': now},
      );
    });

    AppLogger.talker.info('[auth] account link recorded locally ($provider)');
  }
}
