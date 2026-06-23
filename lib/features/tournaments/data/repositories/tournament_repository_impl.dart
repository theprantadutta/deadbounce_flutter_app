import 'package:deadbounce_flutter_app/core/logging/app_logger.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/sync/sync_event.dart';
import '../../../../core/sync/sync_outbox_writer.dart';
import '../../../economy/domain/entities/coin_transaction.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/tournament_repository.dart';
import '../datasources/tournament_api.dart';

class TournamentRepositoryImpl implements TournamentRepository {
  TournamentRepositoryImpl({
    required this._db,
    required this._api,
    required this._outboxWriter,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final TournamentApi _api;
  final SyncOutboxWriter _outboxWriter;
  final Uuid _uuid;

  @override
  Stream<List<Tournament>> watchAll() =>
      _db.tournamentDao.watchAll().map((rows) => rows.map(_toEntity).toList());

  @override
  Future<Tournament?> getById(String id) async {
    final row = await _db.tournamentDao.getById(id);
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<void> refresh() async {
    final dtos = await _api.list();
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _db.tournamentDao.cacheList(
      dtos.map((d) => _toRow(d, nowMs)).toList(),
    );
    AppLogger.talker.info('[tournament] refreshed ${dtos.length}');
  }

  @override
  Future<Tournament> join(String id) async {
    final local = await _db.tournamentDao.getById(id);
    if (local != null && local.joined) return _toEntity(local);

    final fee = local?.entryFeeCoins ?? 0;
    final balance = await _db.coinLedgerDao.getBalance();
    if (balance < fee) {
      throw const TournamentException('Not enough coins to join.');
    }

    // Online — registers participation and returns the seed/config to cache.
    final dto = await _api.join(id);

    final now = DateTime.now().toUtc();
    final nowMs = now.millisecondsSinceEpoch;
    final txnId = _uuid.v4();
    await _db.transaction(() async {
      // Re-check inside the txn (the pre-network balance read is just for fast
      // UX). Guards a double-tap from charging twice and a concurrent spend
      // from driving the balance negative.
      final current = await _db.tournamentDao.getById(id);
      if (current != null && current.joined) return; // already joined + paid
      if (dto.entryFeeCoins > 0) {
        final balanceNow = await _db.coinLedgerDao.getBalance();
        if (balanceNow < dto.entryFeeCoins) {
          throw const TournamentException('Not enough coins to join.');
        }
      }
      await _db.tournamentDao.upsertJoined(_toRow(dto, nowMs));
      if (dto.entryFeeCoins > 0) {
        await _db.coinLedgerDao.insertTransaction(
          CoinLedgerRow(
            id: txnId,
            amount: -dto.entryFeeCoins,
            reason: CoinReason.tournamentEntry.name,
            runId: null,
            createdAt: nowMs,
          ),
        );
        await _outboxWriter.enqueue(SyncEntityType.coinTxn, {
          'txn_id': txnId,
          'amount': -dto.entryFeeCoins,
          'reason': CoinReason.tournamentEntry.name,
          'run_id': null,
          'created_at': now.toIso8601String(),
          'tournament_id': id,
        }, eventId: txnId);
      }
    });

    AppLogger.talker.info('[tournament] joined $id (fee ${dto.entryFeeCoins})');
    final updated = await _db.tournamentDao.getById(id);
    return _toEntity(updated!);
  }

  @override
  Future<TournamentBoard> leaderboard(String id) async {
    try {
      final dto = await _api.leaderboard(id);
      final rows = dto.rows
          .map(
            (r) => TournamentLeaderboardRow(
              tournamentId: id,
              rank: r.rank,
              userId: r.userId,
              username: r.username,
              score: r.score,
              isPlayer: dto.playerRank != null && r.rank == dto.playerRank,
            ),
          )
          .toList();
      await _db.tournamentDao.replaceBoard(id, rows);
      return TournamentBoard(
        standings: rows.map(_toStanding).toList(),
        playerRank: dto.playerRank,
        playerScore: dto.playerScore,
      );
    } on ApiException catch (e) {
      AppLogger.talker.warning('[tournament] board offline: ${e.message}');
      return _cachedBoard(id);
    }
  }

  Future<TournamentBoard> _cachedBoard(String id) async {
    final rows = await _db.tournamentDao.getBoard(id);
    TournamentLeaderboardRow? me;
    for (final r in rows) {
      if (r.isPlayer) {
        me = r;
        break;
      }
    }
    return TournamentBoard(
      standings: rows.map(_toStanding).toList(),
      playerRank: me?.rank,
      playerScore: me?.score,
    );
  }

  @override
  Future<void> claimReward(Tournament tournament) async {
    if (!tournament.hasUnclaimedReward) return;
    final reward = tournament.rewardCoins!;

    final now = DateTime.now().toUtc();
    final nowMs = now.millisecondsSinceEpoch;
    final txnId = _uuid.v4();
    await _db.transaction(() async {
      await _db.coinLedgerDao.insertTransaction(
        CoinLedgerRow(
          id: txnId,
          amount: reward,
          reason: CoinReason.tournamentReward.name,
          runId: null,
          createdAt: nowMs,
        ),
      );
      await _outboxWriter.enqueue(SyncEntityType.coinTxn, {
        'txn_id': txnId,
        'amount': reward,
        'reason': CoinReason.tournamentReward.name,
        'run_id': null,
        'created_at': now.toIso8601String(),
        'tournament_id': tournament.id,
      }, eventId: txnId);
      await _db.tournamentDao.markRewardClaimed(tournament.id);
    });
    AppLogger.talker.info(
      '[tournament] claimed reward $reward for ${tournament.id}',
    );
  }

  // ---- mapping ----

  TournamentRow _toRow(TournamentDto d, int nowMs) => TournamentRow(
    id: d.id,
    cadence: d.cadence.toLowerCase(),
    state: d.state.toLowerCase(),
    name: d.name,
    tagline: d.tagline,
    startsAt: d.startsAt.millisecondsSinceEpoch,
    endsAt: d.endsAt.millisecondsSinceEpoch,
    seed: d.seed,
    configJson: d.configJson,
    entryFeeCoins: d.entryFeeCoins,
    rewardTableJson: d.rewardTableJson,
    joined: d.joined,
    paid: d.paid,
    bestScore: d.bestScore,
    rank: d.rank,
    rewardCoins: d.rewardCoins,
    rewardClaimed: d.rewardClaimed,
    lastSyncedAt: nowMs,
  );

  Tournament _toEntity(TournamentRow r) => Tournament(
    id: r.id,
    cadence: TournamentCadence.fromName(r.cadence),
    state: TournamentState.fromName(r.state),
    name: r.name,
    tagline: r.tagline,
    startsAt: DateTime.fromMillisecondsSinceEpoch(r.startsAt, isUtc: true),
    endsAt: DateTime.fromMillisecondsSinceEpoch(r.endsAt, isUtc: true),
    seed: r.seed,
    configJson: r.configJson,
    entryFeeCoins: r.entryFeeCoins,
    rewardTableJson: r.rewardTableJson,
    joined: r.joined,
    paid: r.paid,
    bestScore: r.bestScore,
    rank: r.rank,
    rewardCoins: r.rewardCoins,
    rewardClaimed: r.rewardClaimed,
  );

  TournamentStanding _toStanding(TournamentLeaderboardRow r) =>
      TournamentStanding(
        rank: r.rank,
        userId: r.userId,
        username: r.username,
        score: r.score,
        isPlayer: r.isPlayer,
      );
}
