import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../logging/app_logger.dart';
import '../network/api_client.dart';
import 'sync_api.dart';

/// The ONE-TIME restore pull. On sign-in, if this account's local Drift
/// flag `initialSyncCompleted` is false, fetch GET /sync/snapshot once and
/// hydrate everything in a single transaction; from then on this device
/// only pushes via the outbox. New accounts hydrate from an empty
/// snapshot through the same path.
class SnapshotRestorer {
  SnapshotRestorer({required this._db, required this._api, Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final SyncApi _api;
  final Uuid _uuid;

  /// Returns true when a restore ran (the boot screen shows
  /// "Restoring your gunslinger…" for that case). Throws [ApiException]
  /// on network failure — the caller decides whether to retry or block;
  /// a fresh device cannot safely proceed without its state.
  Future<bool> restoreIfNeeded() async {
    final profile = await _db.profileDao.getProfile();
    if (profile?.initialSyncCompleted ?? false) return false;

    AppLogger.talker.info('[snapshot] restoring account state…');
    try {
      final snapshot = await _api.fetchSnapshot();
      final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;

      await _db.transaction(() async {
        final profileJson =
            (snapshot['profile'] as Map<String, dynamic>?) ?? const {};
        await _db.profileDao.upsertProfile(
          PlayerProfilesCompanion.insert(
            userId: Value(profileJson['user_id'] as String? ?? ''),
            username: Value(profileJson['username'] as String?),
            displayName: Value(profileJson['display_name'] as String?),
            photoUrl: Value(profileJson['photo_url'] as String?),
            isGuest: Value(profileJson['is_anonymous'] as bool? ?? false),
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );

        final stats = (snapshot['stats'] as Map<String, dynamic>?) ?? const {};
        await _db.statsDao.overwriteFromSnapshot(
          PlayerStatsTableCompanion.insert(
            runsPlayed: Value(_asInt(stats['runs_played'])),
            totalKills: Value(_asInt(stats['total_kills'])),
            bestScore: Value(_asInt(stats['best_score'])),
            bestChain: Value(_asInt(stats['best_chain'])),
            bestBounceKill: Value(_asInt(stats['best_bounce_kill'])),
            totalWavesCleared: Value(_asInt(stats['total_waves_cleared'])),
            totalCoinsEarned: Value(_asInt(stats['total_coins_earned'])),
            bestWave: Value(_asInt(stats['best_wave'])),
            totalPlayMs: Value(_asInt(stats['total_play_ms'])),
            updatedAt: nowMs,
          ),
        );

        for (final entry
            in ((stats['enemy_kills'] as Map<String, dynamic>?) ?? const {})
                .entries) {
          await _db.statsDao.overwriteCounter(
            'enemyKill',
            entry.key,
            _asInt(entry.value),
          );
        }
        for (final entry
            in ((stats['upgrade_picks'] as Map<String, dynamic>?) ?? const {})
                .entries) {
          await _db.statsDao.overwriteCounter(
            'upgradePick',
            entry.key,
            _asInt(entry.value),
          );
        }

        // Wallet: one synthetic ledger entry equal to the server balance.
        final balance = _asInt(snapshot['coin_balance']);
        if (balance != 0) {
          await _db.coinLedgerDao.insertTransaction(
            CoinLedgerRow(
              id: _uuid.v4(),
              amount: balance,
              reason: 'snapshotRestore',
              runId: null,
              createdAt: nowMs,
            ),
          );
        }

        // Achievements arrive unlocked AND claimed — their coin rewards are
        // already inside the snapshot balance.
        for (final a
            in (snapshot['achievements'] as List? ?? const [])
                .cast<Map<String, dynamic>>()) {
          final unlockedAt =
              DateTime.tryParse(
                a['unlocked_at'] as String? ?? '',
              )?.toUtc().millisecondsSinceEpoch ??
              nowMs;
          await _db.achievementsDao.upsertState(
            AchievementStateRow(
              achievementId: a['achievement_id'] as String,
              progress: 0,
              unlockedAt: unlockedAt,
              claimedAt: unlockedAt,
            ),
          );
        }

        // Streak: seed the latest claim so the local consecutive-day rule
        // picks up where the account left off.
        final streak =
            (snapshot['streak'] as Map<String, dynamic>?) ?? const {};
        final lastClaimDate = streak['last_claim_date'] as String?;
        final currentStreak = _asInt(streak['current_streak']);
        if (lastClaimDate != null && currentStreak > 0) {
          await _db.streakDao.insertClaim(
            DailyLoginClaimRow(
              claimDate: lastClaimDate,
              dayIndex: ((currentStreak - 1) % 7) + 1,
              coinsAwarded: 0,
              claimedAt: nowMs,
            ),
          );
        }

        // Challenge history (best scores only — enough for "your best").
        for (final c
            in (snapshot['challenge_results'] as List? ?? const [])
                .cast<Map<String, dynamic>>()) {
          await _db.challengeDao.insertAttempt(
            ChallengeAttemptRow(
              id: _uuid.v4(),
              challengeDate: c['challenge_date'] as String,
              seed: 0,
              score: _asInt(c['score']),
              runId: null,
              completedAt: nowMs,
            ),
          );
        }

        await _db.profileDao.setInitialSyncCompleted();
      });

      AppLogger.talker.info('[snapshot] restore complete');
      return true;
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[snapshot] restore failed');
      rethrow;
    }
  }

  static int _asInt(dynamic v) => switch (v) {
    int i => i,
    num n => n.toInt(),
    _ => 0,
  };
}
