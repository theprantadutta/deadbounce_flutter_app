import 'package:deadbounce_flutter_app/core/database/app_database.dart';
import 'package:deadbounce_flutter_app/core/sync/sync_outbox_writer.dart';
import 'package:deadbounce_flutter_app/features/streak/data/repositories/login_streak_repository_impl.dart';
import 'package:deadbounce_flutter_app/features/streak/domain/login_rewards.dart';
import 'package:deadbounce_flutter_app/features/streak/domain/repositories/login_streak_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DateTime fakeNow;

  LoginStreakRepositoryImpl repoAt(DateTime when) {
    fakeNow = when;
    return LoginStreakRepositoryImpl(
      db: db,
      outboxWriter: SyncOutboxWriter(db),
      clock: () => fakeNow,
    );
  }

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('first claim starts the streak at day 1', () async {
    final repo = repoAt(DateTime(2026, 6, 13, 9));

    final before = await repo.getState();
    expect(before.currentStreak, 0);
    expect(before.canClaimToday, isTrue);
    expect(before.todayReward, LoginRewards.coinsForDay(1));

    final result = await repo.claimToday();
    expect(result.newStreak, 1);
    expect(result.coinsAwarded, LoginRewards.coinsForDay(1));

    final after = await repo.getState();
    expect(after.currentStreak, 1);
    expect(after.canClaimToday, isFalse);
  });

  test('consecutive days continue the streak', () async {
    await repoAt(DateTime(2026, 6, 13, 9)).claimToday();
    final day2 = await repoAt(DateTime(2026, 6, 14, 9)).claimToday();
    expect(day2.newStreak, 2);
    final day3 = await repoAt(DateTime(2026, 6, 15, 9)).claimToday();
    expect(day3.newStreak, 3);
  });

  test('a missed day resets the streak to 1', () async {
    await repoAt(DateTime(2026, 6, 13, 9)).claimToday(); // day 1
    await repoAt(DateTime(2026, 6, 14, 9)).claimToday(); // day 2
    // Skip the 15th entirely.
    final resumed = await repoAt(DateTime(2026, 6, 16, 9)).claimToday();
    expect(resumed.newStreak, 1);
  });

  test('claiming twice in one local day is rejected', () async {
    final repo = repoAt(DateTime(2026, 6, 13, 9));
    await repo.claimToday();
    expect(
      repoAt(DateTime(2026, 6, 13, 21)).claimToday,
      throwsA(isA<AlreadyClaimedToday>()),
    );
  });

  test('streak survives a month boundary', () async {
    await repoAt(DateTime(2026, 6, 30, 9)).claimToday();
    final july1 = await repoAt(DateTime(2026, 7, 1, 9)).claimToday();
    expect(july1.newStreak, 2);
  });

  test('the 7-day calendar wraps and keeps the absolute streak', () async {
    for (var day = 13; day <= 20; day++) {
      await repoAt(DateTime(2026, 6, day, 9)).claimToday();
    }
    // 8 consecutive days → absolute streak 8, calendar day 1 again.
    final state = await repoAt(DateTime(2026, 6, 20, 12)).getState();
    expect(state.currentStreak, 8);
    final day9 = await repoAt(DateTime(2026, 6, 21, 9)).claimToday();
    expect(day9.newStreak, 9);
    expect(day9.calendarDay, 2);
    expect(day9.coinsAwarded, LoginRewards.coinsForDay(2));
  });

  test('claiming enqueues coinTxn and streakUpdate outbox events', () async {
    await repoAt(DateTime(2026, 6, 13, 9)).claimToday();
    final outbox = await db.select(db.syncOutbox).get();
    final types = outbox.map((e) => e.entityType).toSet();
    expect(types, containsAll(['coinTxn', 'streakUpdate']));
  });
}
