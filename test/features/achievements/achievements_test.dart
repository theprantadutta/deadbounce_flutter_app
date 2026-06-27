import 'package:deadbounce_flutter_app/core/database/app_database.dart';
import 'package:deadbounce_flutter_app/core/database/daos/stats_dao.dart';
import 'package:deadbounce_flutter_app/core/sync/sync_outbox_writer.dart';
import 'package:deadbounce_flutter_app/features/achievements/data/repositories/achievements_repository_impl.dart';
import 'package:deadbounce_flutter_app/features/achievements/domain/repositories/achievements_repository.dart';
import 'package:deadbounce_flutter_app/features/streak/data/repositories/login_streak_repository_impl.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late AchievementsRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = AchievementsRepositoryImpl(
      db: db,
      outboxWriter: SyncOutboxWriter(db),
      streakRepository:
          LoginStreakRepositoryImpl(db: db, outboxWriter: SyncOutboxWriter(db)),
    );
  });

  tearDown(() => db.close());

  RunAchievementInput run({
    int score = 0,
    int wave = 1,
    int bestChain = 0,
    int maxBounceKill = 0,
    int upgrades = 0,
    int hits = 1,
    bool daily = false,
  }) =>
      RunAchievementInput(
        score: score,
        wave: wave,
        bestChain: bestChain,
        maxBounceKill: maxBounceKill,
        upgradesPicked: upgrades,
        hitsTaken: hits,
        isDailyChallenge: daily,
      );

  Future<void> seedStats({
    int totalKills = 0,
    int runsPlayed = 0,
    int bestScore = 0,
    int bestWave = 0,
    int bestBounceKill = 0,
    int totalCoinsEarned = 0,
  }) async {
    await db.statsDao.ensureRow();
    await db.customStatement(
      'UPDATE player_stats SET total_kills=?, runs_played=?, best_score=?, '
      'best_wave=?, best_bounce_kill=?, total_coins_earned=? WHERE id=0',
      [totalKills, runsPlayed, bestScore, bestWave, bestBounceKill, totalCoinsEarned],
    );
  }

  test('first kill unlocks First Blood; first run unlocks First Dance',
      () async {
    await seedStats(totalKills: 1, runsPlayed: 1);
    final unlocked = await repo.evaluateRun(run());
    final ids = unlocked.map((d) => d.id).toSet();
    expect(ids, containsAll(['first_blood', 'first_dance']));
  });

  test('progress accumulates without unlocking until the target', () async {
    await seedStats(totalCoinsEarned: 4000);
    await repo.evaluateRun(run());
    var views = await repo.getAll();
    final collector = views.firstWhere((v) => v.definition.id == 'collector');
    expect(collector.isUnlocked, isFalse);
    expect(collector.progress, 4000);

    await seedStats(totalCoinsEarned: 10000, runsPlayed: 1);
    await repo.evaluateRun(run());
    views = await repo.getAll();
    expect(
      views.firstWhere((v) => v.definition.id == 'collector').isUnlocked,
      isTrue,
    );
  });

  test('a run-scoped achievement unlocks from this run\'s stats', () async {
    await seedStats(bestBounceKill: 3, runsPlayed: 1);
    final unlocked = await repo.evaluateRun(run(maxBounceKill: 3));
    expect(unlocked.map((d) => d.id), contains('bank_shot'));
  });

  test('warden kills counter drives Warden Slayer', () async {
    await seedStats(runsPlayed: 1);
    await db.statsDao.bumpCounter(StatsDao.kindEnemyKill, 'warden', by: 1);
    final unlocked = await repo.evaluateRun(run());
    expect(unlocked.map((d) => d.id), contains('warden_slayer'));
  });

  test('claim grants coins once, enqueues events, and is idempotent',
      () async {
    await seedStats(totalKills: 1, runsPlayed: 1);
    await repo.evaluateRun(run());

    expect(await db.coinLedgerDao.getBalance(), 0);
    await repo.claim('first_blood');

    // first_blood reward is 10.
    expect(await db.coinLedgerDao.getBalance(), 10);
    final views = await repo.getAll();
    expect(
      views.firstWhere((v) => v.definition.id == 'first_blood').isClaimed,
      isTrue,
    );

    final outbox = await db.select(db.syncOutbox).get();
    final types = outbox.map((e) => e.entityType).toList();
    // The reward is credited server-side via the validated achievementUnlock
    // event — no separate (unvalidated) coinTxn is synced for it.
    expect(types, contains('achievementUnlock'));
    expect(types, isNot(contains('coinTxn')));

    // Claiming again does nothing (local balance unchanged, no new events).
    await repo.claim('first_blood');
    expect(await db.coinLedgerDao.getBalance(), 10);
  });

  test('claiming a locked achievement is a no-op', () async {
    await repo.claim('ricochet_royalty');
    expect(await db.coinLedgerDao.getBalance(), 0);
  });
}
