import 'package:deadbounce_flutter_app/core/logging/app_logger.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/stats_dao.dart';
import '../../../../core/sync/sync_event.dart';
import '../../../../core/sync/sync_outbox_writer.dart';
import '../../../economy/domain/entities/coin_transaction.dart';
import '../../../streak/domain/repositories/login_streak_repository.dart';
import '../../domain/achievement_catalog.dart';
import '../../domain/entities/achievement_view.dart';
import '../../domain/repositories/achievements_repository.dart';

class AchievementsRepositoryImpl implements AchievementsRepository {
  AchievementsRepositoryImpl({
    required this._db,
    required this._outboxWriter,
    required this._streakRepository,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final SyncOutboxWriter _outboxWriter;
  final LoginStreakRepository _streakRepository;
  final Uuid _uuid;

  @override
  Future<List<AchievementView>> getAll() async {
    final states = {
      for (final s in await _db.achievementsDao.getAll()) s.achievementId: s,
    };
    return [
      for (final def in AchievementCatalog.all)
        _view(def, states[def.id]),
    ];
  }

  @override
  Stream<List<AchievementView>> watchAll() {
    return _db.achievementsDao.watchAll().map((rows) {
      final states = {for (final s in rows) s.achievementId: s};
      return [
        for (final def in AchievementCatalog.all) _view(def, states[def.id]),
      ];
    });
  }

  @override
  Future<List<AchievementDefinition>> evaluateRun(
      RunAchievementInput run) async {
    final context = await _buildContext(run);
    final existing = {
      for (final s in await _db.achievementsDao.getAll()) s.achievementId: s,
    };

    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    final newlyUnlocked = <AchievementDefinition>[];

    await _db.transaction(() async {
      for (final def in AchievementCatalog.all) {
        final progress = def.progress(context);
        await _db.achievementsDao.raiseProgress(def.id, progress);

        final wasUnlocked = existing[def.id]?.unlockedAt != null;
        if (!wasUnlocked && progress >= def.target) {
          await _db.achievementsDao.markUnlocked(def.id, nowMs);
          AppLogger.talker.info('[achievements] unlocked ${def.id}');
          newlyUnlocked.add(def);
        }
      }
    });

    return newlyUnlocked;
  }

  @override
  Future<void> claim(String achievementId) async {
    final state = await _db.achievementsDao.getState(achievementId);
    if (state == null || state.unlockedAt == null || state.claimedAt != null) {
      return; // not unlocked, or already claimed
    }

    final def = AchievementCatalog.byId(achievementId);
    final now = DateTime.now().toUtc();
    final nowMs = now.millisecondsSinceEpoch;
    final txnId = _uuid.v4();

    await _db.transaction(() async {
      await _db.achievementsDao.markClaimed(achievementId, nowMs);

      if (def.coinReward > 0) {
        await _db.coinLedgerDao.insertTransaction(CoinLedgerRow(
          id: txnId,
          amount: def.coinReward,
          reason: CoinReason.achievementClaim.name,
          runId: null,
          createdAt: nowMs,
        ));
        await _outboxWriter.enqueue(
          SyncEntityType.coinTxn,
          {
            'txn_id': txnId,
            'amount': def.coinReward,
            'reason': CoinReason.achievementClaim.name,
            'run_id': null,
            'created_at': now.toIso8601String(),
          },
          eventId: txnId,
        );
      }

      // The unlock event carries the reward; the backend dedupes by
      // (user, achievementId) and validates id+reward against its catalog.
      final unlockedAtMs = state.unlockedAt ?? nowMs;
      await _outboxWriter.enqueue(SyncEntityType.achievementUnlock, {
        'achievement_id': achievementId,
        'coin_reward': def.coinReward,
        'unlocked_at': DateTime.fromMillisecondsSinceEpoch(unlockedAtMs,
                isUtc: true)
            .toIso8601String(),
      });
    });

    AppLogger.talker.info(
      '[achievements] claimed $achievementId (reward ${def.coinReward})',
    );
  }

  Future<AchievementContext> _buildContext(RunAchievementInput run) async {
    final stats = await _db.statsDao.getStats();
    final enemyKills = await _db.statsDao.getCounters(StatsDao.kindEnemyKill);
    final streak = await _streakRepository.getState();

    return AchievementContext(
      runScore: run.score,
      runWave: run.wave,
      runBestChain: run.bestChain,
      runMaxBounceKill: run.maxBounceKill,
      runUpgradesPicked: run.upgradesPicked,
      runHitsTaken: run.hitsTaken,
      runIsDailyChallenge: run.isDailyChallenge,
      lifetimeKills: stats?.totalKills ?? 0,
      lifetimeCoinsEarned: stats?.totalCoinsEarned ?? 0,
      runsPlayed: stats?.runsPlayed ?? 0,
      bestScore: stats?.bestScore ?? 0,
      bestWave: stats?.bestWave ?? 0,
      bestChain: stats?.bestChain ?? 0,
      bestBounceKill: stats?.bestBounceKill ?? 0,
      currentStreak: streak.currentStreak,
      lifetimeEnemyKills: enemyKills,
    );
  }

  AchievementView _view(AchievementDefinition def, AchievementStateRow? state) {
    return AchievementView(
      definition: def,
      progress: state?.progress ?? 0,
      unlockedAt: state?.unlockedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(state!.unlockedAt!,
              isUtc: true),
      claimedAt: state?.claimedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(state!.claimedAt!, isUtc: true),
    );
  }
}
