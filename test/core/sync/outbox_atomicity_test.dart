import 'package:deadbounce_flutter_app/core/database/app_database.dart';
import 'package:deadbounce_flutter_app/core/sync/sync_event.dart';
import 'package:deadbounce_flutter_app/core/sync/sync_outbox_writer.dart';
import 'package:deadbounce_flutter_app/features/runs/data/repositories/runs_repository_impl.dart';
import 'package:deadbounce_flutter_app/features/runs/domain/entities/run_result.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SyncOutboxWriter writer;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    writer = SyncOutboxWriter(db);
  });

  tearDown(() => db.close());

  test('domain write and outbox event roll back together on failure',
      () async {
    await expectLater(
      db.transaction(() async {
        await db.coinLedgerDao.insertTransaction(const CoinLedgerRow(
          id: 'txn-1',
          amount: 50,
          reason: 'runReward',
          runId: null,
          createdAt: 1,
        ));
        await writer.enqueue(
          SyncEntityType.coinTxn,
          const {'txn_id': 'txn-1'},
          eventId: 'txn-1',
        );
        throw StateError('boom');
      }),
      throwsStateError,
    );

    expect(await db.select(db.coinLedgerEntries).get(), isEmpty);
    expect(await db.select(db.syncOutbox).get(), isEmpty);
    expect(await db.coinLedgerDao.getBalance(), 0);
  });

  test('recordCompletedRun commits run, ledger, stats, and outbox events '
      'atomically', () async {
    final repo = RunsRepositoryImpl(db: db, outboxWriter: writer);

    await repo.recordCompletedRun(RunResult(
      id: 'run-1',
      score: 4200,
      waveReached: 7,
      kills: 38,
      bestChain: 3,
      maxBounceKill: 5,
      duration: const Duration(minutes: 3),
      coinsEarned: 95,
      arenaId: 'arena_clean',
      upgradesPicked: const ['quickdraw', 'rubber_walls'],
      endedAt: DateTime.utc(2026, 6, 12, 12),
      enemyKills: const {'drifter': 30, 'charger': 8},
    ));

    expect(await db.select(db.runs).get(), hasLength(1));
    expect(await db.coinLedgerDao.getBalance(), 95);

    final stats = await db.statsDao.getStats();
    expect(stats!.runsPlayed, 1);
    expect(stats.totalKills, 38);
    expect(stats.bestScore, 4200);

    final counters = await db.statsDao.getCounters('enemyKill');
    expect(counters['drifter'], 30);

    final outbox = await db.select(db.syncOutbox).get();
    final types = outbox.map((e) => e.entityType).toSet();
    expect(types, {
      'runCompleted',
      'coinTxn',
      'statsDelta',
      'scoreSubmit',
    });
    // Run id doubles as the runCompleted event id.
    expect(outbox.any((e) => e.id == 'run-1'), isTrue);
  });

  test('best fields fold with MAX across runs', () async {
    final repo = RunsRepositoryImpl(db: db, outboxWriter: writer);

    Future<void> run(String id, int score, int chain) =>
        repo.recordCompletedRun(RunResult(
          id: id,
          score: score,
          waveReached: 3,
          kills: 10,
          bestChain: chain,
          maxBounceKill: 2,
          duration: const Duration(minutes: 1),
          coinsEarned: 10,
          arenaId: 'arena_clean',
          upgradesPicked: const [],
          endedAt: DateTime.utc(2026, 6, 12),
        ));

    await run('r1', 1000, 4);
    await run('r2', 500, 6);

    final stats = await db.statsDao.getStats();
    expect(stats!.bestScore, 1000);
    expect(stats.bestChain, 6);
    expect(stats.runsPlayed, 2);
  });
}
