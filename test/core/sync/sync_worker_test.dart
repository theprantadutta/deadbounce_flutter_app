import 'dart:math';

import 'package:deadbounce_flutter_app/core/database/app_database.dart';
import 'package:deadbounce_flutter_app/core/database/daos/sync_outbox_dao.dart';
import 'package:deadbounce_flutter_app/core/network/api_client.dart';
import 'package:deadbounce_flutter_app/core/sync/sync_api.dart';
import 'package:deadbounce_flutter_app/core/sync/sync_status.dart';
import 'package:deadbounce_flutter_app/core/sync/sync_trigger_source.dart';
import 'package:deadbounce_flutter_app/core/sync/sync_worker.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSyncApi implements SyncApi {
  final List<List<SyncOutboxRow>> sentBatches = [];

  /// Per-call behaviors; falls back to "apply everything".
  final List<dynamic Function(List<SyncOutboxRow>)> scripts = [];
  int _call = 0;

  /// Gates the worker's drain; flip to false to simulate a down backend.
  bool healthy = true;
  int healthChecks = 0;

  @override
  Future<List<SyncEventResult>> sendBatch(List<SyncOutboxRow> events) async {
    sentBatches.add(events);
    if (_call < scripts.length) {
      final result = scripts[_call++](events);
      if (result is Exception) throw result;
      return result as List<SyncEventResult>;
    }
    return [
      for (final e in events) SyncEventResult(id: e.id, status: 'applied'),
    ];
  }

  @override
  Future<Map<String, dynamic>> fetchSnapshot() async => const {};

  @override
  Future<bool> isHealthy() async {
    healthChecks++;
    return healthy;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late FakeSyncApi api;
  late SyncWorker worker;
  late SyncStatusNotifier status;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    api = FakeSyncApi();
    status = SyncStatusNotifier();
    worker = SyncWorker(
      db: db,
      api: api,
      status: status,
      triggers: SyncTriggerSource(),
      random: Random(1),
    );
  });

  tearDown(() async {
    await worker.dispose();
    await db.close();
  });

  Future<void> seed(int count, {int startAt = 1}) async {
    for (var i = 0; i < count; i++) {
      await db.syncOutboxDao.enqueue(SyncOutboxRow(
        id: 'evt-${startAt + i}',
        entityType: 'coinTxn',
        operation: 'create',
        payload: '{"amount": 1}',
        createdAt: startAt + i,
        attempts: 0,
        status: SyncOutboxDao.statusPending,
        nextRetryAt: null,
        lastError: null,
      ));
    }
  }

  Future<List<SyncOutboxRow>> allRows() => db.select(db.syncOutbox).get();

  test('drains in createdAt order, batching at most 50 per request',
      () async {
    await seed(120);

    await worker.start();
    await pumpEventQueue(times: 50);

    expect(api.sentBatches, hasLength(3));
    expect(api.sentBatches[0], hasLength(50));
    expect(api.sentBatches[0].first.id, 'evt-1');
    expect(api.sentBatches[0].last.id, 'evt-50');
    expect(api.sentBatches[2], hasLength(20));

    final rows = await allRows();
    expect(rows.every((r) => r.status == SyncOutboxDao.statusDone), isTrue);
    expect(status.value.pendingCount, 0);
  });

  test('per-item results: applied/duplicate settle, rejected fails '
      'permanently', () async {
    await seed(3);
    api.scripts.add((events) => [
          SyncEventResult(id: events[0].id, status: 'applied'),
          SyncEventResult(id: events[1].id, status: 'duplicate'),
          SyncEventResult(
              id: events[2].id, status: 'rejected', error: 'implausible'),
        ]);

    await worker.start();
    await pumpEventQueue(times: 50);

    final rows = await allRows();
    final byId = {for (final r in rows) r.id: r};
    expect(byId['evt-1']!.status, SyncOutboxDao.statusDone);
    expect(byId['evt-2']!.status, SyncOutboxDao.statusDone);
    expect(byId['evt-3']!.status, SyncOutboxDao.statusFailed);
    expect(byId['evt-3']!.lastError, 'implausible');
    expect(status.value.failedCount, 1);
  });

  test('transport failure reschedules the whole batch with backoff',
      () async {
    await seed(2);
    api.scripts.add((_) => ApiException('offline'));

    await worker.start();
    await pumpEventQueue(times: 50);

    final rows = await allRows();
    expect(rows.every((r) => r.status == SyncOutboxDao.statusPending), isTrue);
    expect(rows.every((r) => r.attempts == 1), isTrue);
    expect(rows.every((r) => r.nextRetryAt != null), isTrue);
    // Backoff means not immediately due — a new drain skips them.
    expect(api.sentBatches, hasLength(1));
  });

  test('health gate: does not drain or burn attempts while backend is down',
      () async {
    await seed(2);
    api.healthy = false;

    await worker.start();
    await pumpEventQueue(times: 50);

    // Nothing sent; events stay pending with zero attempts consumed.
    expect(api.sentBatches, isEmpty);
    expect(api.healthChecks, greaterThan(0));
    final rows = await allRows();
    expect(rows.every((r) => r.status == SyncOutboxDao.statusPending), isTrue);
    expect(rows.every((r) => r.attempts == 0), isTrue);
  });

  test('transport failure never permanently fails — retries indefinitely',
      () async {
    // An event that has already failed many times under the old 8-attempt cap.
    await db.syncOutboxDao.enqueue(SyncOutboxRow(
      id: 'evt-old',
      entityType: 'coinTxn',
      operation: 'create',
      payload: '{"amount": 1}',
      createdAt: 1,
      attempts: 50,
      status: SyncOutboxDao.statusPending,
      nextRetryAt: null,
      lastError: null,
    ));
    api.scripts.add((_) => ApiException('still offline'));

    await worker.start();
    await pumpEventQueue(times: 50);

    final row = (await allRows()).single;
    // Stays pending (rescheduled), never flips to failed.
    expect(row.status, SyncOutboxDao.statusPending);
    expect(row.attempts, 51);
    expect(row.nextRetryAt, isNotNull);
  });

  test('start() recovers events stuck inFlight from a killed app',
      () async {
    await seed(1);
    await db.customStatement(
        "UPDATE sync_outbox SET status = 'inFlight' WHERE id = 'evt-1'");

    await worker.start();
    await pumpEventQueue(times: 50);

    final rows = await allRows();
    expect(rows.single.status, SyncOutboxDao.statusDone);
  });

  test('retryFailed flips failed events back to pending and drains',
      () async {
    await seed(1);
    api.scripts.add((events) => [
          SyncEventResult(id: events[0].id, status: 'rejected', error: 'bad'),
        ]);

    await worker.start();
    await pumpEventQueue(times: 50);
    expect((await allRows()).single.status, SyncOutboxDao.statusFailed);

    await worker.retryFailed();
    await pumpEventQueue(times: 50);

    expect((await allRows()).single.status, SyncOutboxDao.statusDone);
  });
}
