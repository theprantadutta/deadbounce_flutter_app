import 'package:deadbounce_flutter_app/core/logging/app_logger.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/sync/sync_event.dart';
import '../../../../core/sync/sync_outbox_writer.dart';
import '../../../../core/util/calendar_day.dart';
import '../../../economy/domain/entities/coin_transaction.dart';
import '../../domain/entities/streak_state.dart';
import '../../domain/login_rewards.dart';
import '../../domain/repositories/login_streak_repository.dart';

class LoginStreakRepositoryImpl implements LoginStreakRepository {
  LoginStreakRepositoryImpl({
    required this._db,
    required this._outboxWriter,
    Uuid? uuid,
    DateTime Function()? clock,
  })  : _uuid = uuid ?? const Uuid(),
        _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final SyncOutboxWriter _outboxWriter;
  final Uuid _uuid;
  final DateTime Function() _now;

  @override
  Future<StreakState> getState() async {
    final now = _now();
    final today = CalendarDay.local(now);
    final claims = await _db.streakDao.recentClaims(limit: 60);

    final currentStreak = _walkStreak(claims, now);
    final claimedToday = claims.isNotEmpty && claims.first.claimDate == today;

    final projectedStreak = claimedToday ? currentStreak : currentStreak + 1;
    final calendarDay = LoginRewards.calendarDay(projectedStreak);

    return StreakState(
      currentStreak: currentStreak,
      canClaimToday: !claimedToday,
      todayCalendarDay: calendarDay,
      todayReward: LoginRewards.coinsForDay(calendarDay),
    );
  }

  @override
  Future<StreakClaimResult> claimToday() async {
    final now = _now();
    final today = CalendarDay.local(now);
    final nowMs = now.toUtc().millisecondsSinceEpoch;

    final claims = await _db.streakDao.recentClaims(limit: 60);
    if (claims.isNotEmpty && claims.first.claimDate == today) {
      throw const AlreadyClaimedToday();
    }

    // Continues only if the most recent prior claim was yesterday (local).
    final continues = claims.isNotEmpty &&
        CalendarDay.isLocalYesterdayOf(claims.first.claimDate, now);
    final newStreak = continues ? _walkStreak(claims, now) + 1 : 1;
    final calendarDay = LoginRewards.calendarDay(newStreak);
    final coins = LoginRewards.coinsForDay(calendarDay);
    final txnId = _uuid.v4();

    await _db.transaction(() async {
      await _db.streakDao.insertClaim(DailyLoginClaimRow(
        claimDate: today,
        dayIndex: calendarDay,
        coinsAwarded: coins,
        claimedAt: nowMs,
      ));

      await _db.coinLedgerDao.insertTransaction(CoinLedgerRow(
        id: txnId,
        amount: coins,
        reason: CoinReason.dailyLogin.name,
        runId: null,
        createdAt: nowMs,
      ));

      await _outboxWriter.enqueue(
        SyncEntityType.coinTxn,
        {
          'txn_id': txnId,
          'amount': coins,
          'reason': CoinReason.dailyLogin.name,
          'run_id': null,
          'created_at': now.toUtc().toIso8601String(),
        },
        eventId: txnId,
      );

      await _outboxWriter.enqueue(SyncEntityType.streakUpdate, {
        'claim_date': today,
        'day_index': calendarDay,
        'coins_awarded': coins,
        'streak': newStreak,
        'tz_offset_minutes': now.timeZoneOffset.inMinutes,
        'claimed_at': now.toUtc().toIso8601String(),
      });
    });

    AppLogger.talker.info('[streak] daily claim: streak=$newStreak coins=$coins');
    return StreakClaimResult(
      calendarDay: calendarDay,
      coinsAwarded: coins,
      newStreak: newStreak,
    );
  }

  /// Walks the trailing run of consecutive local days to get the ABSOLUTE
  /// current streak. Counts only when the most recent claim is today or
  /// yesterday (otherwise the streak has lapsed → 0).
  ///
  /// [claims] must be newest-first (as StreakDao.recentClaims returns).
  int _walkStreak(List<DailyLoginClaimRow> claims, DateTime now) {
    if (claims.isEmpty) return 0;

    final today = CalendarDay.local(now);
    final latest = claims.first.claimDate;
    final stillAlive =
        latest == today || CalendarDay.isLocalYesterdayOf(latest, now);
    if (!stillAlive) return 0;

    var streak = 1;
    for (var i = 1; i < claims.length; i++) {
      final gap =
          CalendarDay.dayGap(claims[i].claimDate, claims[i - 1].claimDate);
      if (gap == 1) {
        streak++;
      } else {
        break; // gap > 1 (missed a day) or duplicate — run ends
      }
    }
    return streak;
  }
}
