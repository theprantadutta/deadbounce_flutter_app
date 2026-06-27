import 'dart:convert';

import 'package:deadbounce_flutter_app/core/logging/app_logger.dart';
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

    // Daily-challenge and tournament runs are seeded/constrained (forced
    // enemies, heart caps, score multipliers, perks off), so their results
    // aren't comparable to standard runs: they never set lifetime PERSONAL
    // BESTS (local stats AND the synced statsDelta) and never feed the global
    // leaderboards. Activity counters (runs/kills/waves/play time/coins) still
    // count — the player really did play.
    final isConstrained = r.tournamentId != null || r.isDailyChallenge;

    AppLogger.talker.info(
      '[run] recordCompletedRun score=${r.score} wave=${r.waveReached} '
      'kills=${r.kills}',
    );

    try {
      await _db.transaction(() async {
        // 1. The run itself.
        await _db.runsDao.insertRun(
          RunRow(
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
            tournamentId: r.tournamentId,
            arenaId: r.arenaId,
            upgradesPicked: jsonEncode(r.upgradesPicked),
            endedAt: endedAtMs,
          ),
        );

        // 2. Run earnings into the ledger (one txn per run, not per pickup).
        String? coinTxnId;
        if (r.coinsEarned != 0) {
          coinTxnId = _uuid.v4();
          await _db.coinLedgerDao.insertTransaction(
            CoinLedgerRow(
              id: coinTxnId,
              amount: r.coinsEarned,
              reason: CoinReason.runReward.name,
              runId: r.id,
              createdAt: endedAtMs,
            ),
          );
        }

        // 3. Lifetime stats + counters.
        await _db.statsDao.applyRunDeltas(
          RunStatDeltas(
            kills: r.kills,
            wavesCleared: r.waveReached,
            playMs: r.duration.inMilliseconds,
            score: isConstrained ? 0 : r.score,
            chain: isConstrained ? 0 : r.bestChain,
            bounceKill: isConstrained ? 0 : r.maxBounceKill,
            wave: isConstrained ? 0 : r.waveReached,
            enemyKills: r.enemyKills,
            upgradePicks: upgradePicks,
          ),
        );

        // 4. Tournament best (local), when this run was a tournament entry.
        if (r.tournamentId != null) {
          await _db.tournamentDao.recordBest(r.tournamentId!, r.score);
        }

        // 4b. Challenge attempt, when this run was one.
        String? attemptId;
        if (r.isDailyChallenge && r.challengeDate != null) {
          attemptId = _uuid.v4();
          await _db.challengeDao.insertAttempt(
            ChallengeAttemptRow(
              id: attemptId,
              challengeDate: r.challengeDate!,
              seed: r.challengeSeed ?? 0,
              score: r.score,
              runId: r.id,
              completedAt: endedAtMs,
            ),
          );
        }

        // 5. Outbox events — same transaction, so the backend eventually
        // sees exactly what was committed locally.
        await _outboxWriter.enqueue(SyncEntityType.runCompleted, {
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
        }, eventId: r.id);

        if (coinTxnId != null) {
          await _outboxWriter.enqueue(SyncEntityType.coinTxn, {
            'txn_id': coinTxnId,
            'amount': r.coinsEarned,
            'reason': CoinReason.runReward.name,
            'run_id': r.id,
            'created_at': r.endedAt.toUtc().toIso8601String(),
          }, eventId: coinTxnId);
        }

        await _outboxWriter.enqueue(SyncEntityType.statsDelta, {
          'runs_played': 1,
          'kills': r.kills,
          'waves_cleared': r.waveReached,
          'coins_earned': r.coinsEarned,
          'play_ms': r.duration.inMilliseconds,
          'best_score': isConstrained ? 0 : r.score,
          'best_chain': isConstrained ? 0 : r.bestChain,
          'best_bounce_kill': isConstrained ? 0 : r.maxBounceKill,
          'best_wave': isConstrained ? 0 : r.waveReached,
          'enemy_kills': r.enemyKills,
          'upgrade_picks': upgradePicks,
        });

        if (r.tournamentId != null) {
          // Tournament runs score the tournament board only — a seeded,
          // constrained board must not pollute the global leaderboards.
          await _outboxWriter.enqueue(SyncEntityType.tournamentScore, {
            'tournament_id': r.tournamentId,
            'run_id': r.id,
            'score': r.score,
            'wave_reached': r.waveReached,
            'duration_ms': r.duration.inMilliseconds,
            'kills': r.kills,
            'ended_at': r.endedAt.toUtc().toIso8601String(),
          });
        } else if (!r.isDailyChallenge) {
          // Standard runs only — daily-challenge runs feed the dc board via
          // challengeResult below, never the global daily/weekly/all-time boards.
          await _outboxWriter.enqueue(SyncEntityType.scoreSubmit, {
            'run_id': r.id,
            'score': r.score,
            'wave_reached': r.waveReached,
            'duration_ms': r.duration.inMilliseconds,
            'kills': r.kills,
            'ended_at': r.endedAt.toUtc().toIso8601String(),
          });
        }

        if (attemptId != null) {
          // Carry wave/duration/kills so the server can sanity-validate the
          // score and show real wave counts on the daily-challenge board.
          await _outboxWriter.enqueue(SyncEntityType.challengeResult, {
            'attempt_id': attemptId,
            'challenge_date': r.challengeDate,
            'seed': r.challengeSeed ?? 0,
            'score': r.score,
            'wave_reached': r.waveReached,
            'duration_ms': r.duration.inMilliseconds,
            'kills': r.kills,
            'run_id': r.id,
            'completed_at': r.endedAt.toUtc().toIso8601String(),
          }, eventId: attemptId);
        }
      });
      AppLogger.talker.info('[run] run recorded (${r.id})');
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[run] recordCompletedRun failed');
      rethrow;
    }
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
    tournamentId: r.tournamentId,
  );
}
