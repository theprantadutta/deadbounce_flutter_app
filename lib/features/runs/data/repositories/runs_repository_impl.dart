import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/stats_dao.dart';
import '../../../../core/sync/sync_event.dart';
import '../../../../core/sync/sync_outbox_writer.dart';
import '../../../economy/domain/entities/coin_transaction.dart';
import '../../domain/entities/run_result.dart';
import '../../domain/repositories/runs_repository.dart';

class RunsRepositoryImpl implements RunsRepository {
  RunsRepositoryImpl({
    required this._db,
    required this._outboxWriter,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final SyncOutboxWriter _outboxWriter;
  final Uuid _uuid;

  @override
  Future<void> recordCompletedRun(RunResult r) async {
    final endedAtMs = r.endedAt.toUtc().millisecondsSinceEpoch;
    final upgradePicks = <String, int>{};
    for (final id in r.upgradesPicked) {
      upgradePicks[id] = (upgradePicks[id] ?? 0) + 1;
    }

    await _db.transaction(() async {
      // 1. The run itself.
      await _db.runsDao.insertRun(RunRow(
        id: r.id,
        score: r.score,
        waveReached: r.waveReached,
        kills: r.kills,
        bestChain: r.bestChain,
        maxBounceKill: r.maxBounceKill,
        durationMs: r.duration.inMilliseconds,
        coinsEarned: r.coinsEarned,
        isDailyChallenge: r.isDailyChallenge,
        challengeDate: r.challengeDate,
        arenaId: r.arenaId,
        upgradesPicked: jsonEncode(r.upgradesPicked),
        endedAt: endedAtMs,
      ));

      // 2. Run earnings into the ledger (one txn per run, not per pickup).
      String? coinTxnId;
      if (r.coinsEarned != 0) {
        coinTxnId = _uuid.v4();
        await _db.coinLedgerDao.insertTransaction(CoinLedgerRow(
          id: coinTxnId,
          amount: r.coinsEarned,
          reason: CoinReason.runReward.name,
          runId: r.id,
          createdAt: endedAtMs,
        ));
      }

      // 3. Lifetime stats + counters.
      await _db.statsDao.applyRunDeltas(RunStatDeltas(
        kills: r.kills,
        wavesCleared: r.waveReached,
        coinsEarned: r.coinsEarned,
        playMs: r.duration.inMilliseconds,
        score: r.score,
        chain: r.bestChain,
        bounceKill: r.maxBounceKill,
        wave: r.waveReached,
        enemyKills: r.enemyKills,
        upgradePicks: upgradePicks,
      ));

      // 4. Challenge attempt, when this run was one.
      String? attemptId;
      if (r.isDailyChallenge && r.challengeDate != null) {
        attemptId = _uuid.v4();
        await _db.challengeDao.insertAttempt(ChallengeAttemptRow(
          id: attemptId,
          challengeDate: r.challengeDate!,
          seed: r.challengeSeed ?? 0,
          score: r.score,
          runId: r.id,
          completedAt: endedAtMs,
        ));
      }

      // 5. Outbox events — same transaction, so the backend eventually
      // sees exactly what was committed locally.
      await _outboxWriter.enqueue(
        SyncEntityType.runCompleted,
        {
          'run_id': r.id,
          'score': r.score,
          'wave_reached': r.waveReached,
          'kills': r.kills,
          'best_chain': r.bestChain,
          'max_bounce_kill': r.maxBounceKill,
          'duration_ms': r.duration.inMilliseconds,
          'coins_earned': r.coinsEarned,
          'arena_id': r.arenaId,
          'upgrades_picked': r.upgradesPicked,
          'is_daily_challenge': r.isDailyChallenge,
          'challenge_date': r.challengeDate,
          'ended_at': r.endedAt.toUtc().toIso8601String(),
        },
        eventId: r.id,
      );

      if (coinTxnId != null) {
        await _outboxWriter.enqueue(
          SyncEntityType.coinTxn,
          {
            'txn_id': coinTxnId,
            'amount': r.coinsEarned,
            'reason': CoinReason.runReward.name,
            'run_id': r.id,
            'created_at': r.endedAt.toUtc().toIso8601String(),
          },
          eventId: coinTxnId,
        );
      }

      await _outboxWriter.enqueue(SyncEntityType.statsDelta, {
        'runs_played': 1,
        'kills': r.kills,
        'waves_cleared': r.waveReached,
        'coins_earned': r.coinsEarned,
        'play_ms': r.duration.inMilliseconds,
        'best_score': r.score,
        'best_chain': r.bestChain,
        'best_bounce_kill': r.maxBounceKill,
        'best_wave': r.waveReached,
        'enemy_kills': r.enemyKills,
        'upgrade_picks': upgradePicks,
      });

      await _outboxWriter.enqueue(SyncEntityType.scoreSubmit, {
        'run_id': r.id,
        'score': r.score,
        'wave_reached': r.waveReached,
        'duration_ms': r.duration.inMilliseconds,
        'kills': r.kills,
        'ended_at': r.endedAt.toUtc().toIso8601String(),
      });

      if (attemptId != null) {
        await _outboxWriter.enqueue(
          SyncEntityType.challengeResult,
          {
            'attempt_id': attemptId,
            'challenge_date': r.challengeDate,
            'seed': r.challengeSeed ?? 0,
            'score': r.score,
            'run_id': r.id,
            'completed_at': r.endedAt.toUtc().toIso8601String(),
          },
          eventId: attemptId,
        );
      }
    });
  }

  @override
  Future<List<RunResult>> recentRuns({int limit = 20}) async {
    final rows = await _db.runsDao.recentRuns(limit: limit);
    return rows.map(_fromRow).toList();
  }

  @override
  Future<RunResult?> bestRun() async {
    final row = await _db.runsDao.bestRun();
    return row == null ? null : _fromRow(row);
  }

  static RunResult _fromRow(RunRow r) => RunResult(
        id: r.id,
        score: r.score,
        waveReached: r.waveReached,
        kills: r.kills,
        bestChain: r.bestChain,
        maxBounceKill: r.maxBounceKill,
        duration: Duration(milliseconds: r.durationMs),
        coinsEarned: r.coinsEarned,
        arenaId: r.arenaId,
        upgradesPicked: (jsonDecode(r.upgradesPicked) as List).cast<String>(),
        endedAt: DateTime.fromMillisecondsSinceEpoch(r.endedAt, isUtc: true),
        isDailyChallenge: r.isDailyChallenge,
        challengeDate: r.challengeDate,
      );
}
