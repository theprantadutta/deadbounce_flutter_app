import 'dart:async';
import 'dart:math';

import '../database/app_database.dart';
import '../database/daos/sync_outbox_dao.dart';
import '../logging/app_logger.dart';
import '../network/api_client.dart';
import 'backoff.dart';
import 'sync_api.dart';
import 'sync_status.dart';
import 'sync_trigger_source.dart';

/// Drains the sync outbox: claims due pending events in createdAt order,
/// batches up to [batchSize] into ONE POST /sync/batch, and settles each
/// item from the per-event results. Single-flight — triggers landing
/// mid-drain coalesce into one rerun instead of overlapping drains.
class SyncWorker {
  SyncWorker({
    required this._db,
    required this._api,
    required this._status,
    required this._triggers,
    Random? random,
  }) : _random = random ?? Random();

  static const int batchSize = 50;
  static const int maxAttempts = 8;
  static const Duration _doneRetention = Duration(days: 7);

  final AppDatabase _db;
  final SyncApi _api;
  final SyncStatusNotifier _status;
  final SyncTriggerSource _triggers;
  final Random _random;

  StreamSubscription<SyncTrigger>? _triggerSub;
  bool _draining = false;
  bool _rerunRequested = false;
  bool _disposed = false;

  Future<void> start() async {
    // Crash recovery: a batch stuck inFlight from a killed app goes back
    // to pending — safe because the server dedupes by event id.
    await _db.syncOutboxDao.recoverInFlight();
    await _db.syncOutboxDao.pruneDone(
      olderThanMs: DateTime.now()
          .toUtc()
          .subtract(_doneRetention)
          .millisecondsSinceEpoch,
    );

    _triggerSub = _triggers.triggers.listen((_) => requestSync());
    await _refreshCounts();
    AppLogger.talker.info(
        '[sync] worker started (${_status.value.pendingCount} pending, '
        '${_status.value.failedCount} failed)');
    requestSync();
  }

  /// Coalescing entry point: starts a drain, or flags a rerun if one is
  /// already running.
  void requestSync() {
    if (_disposed) return;
    if (_draining) {
      _rerunRequested = true;
      return;
    }
    unawaited(_drainLoop());
  }

  /// Flips failed events back to pending (the Profile/Settings "Retry
  /// sync" action) and drains.
  Future<void> retryFailed() async {
    await _db.syncOutboxDao.retryFailed();
    requestSync();
  }

  Future<void> _drainLoop() async {
    _draining = true;
    _status.value = SyncStatus(
      pendingCount: _status.value.pendingCount,
      failedCount: _status.value.failedCount,
      lastSyncedAt: _status.value.lastSyncedAt,
      isSyncing: true,
    );

    try {
      do {
        _rerunRequested = false;
        var drainedFullBatch = true;

        while (drainedFullBatch && !_disposed) {
          final claimed = await _db.syncOutboxDao.claimBatch(
            limit: batchSize,
            nowMs: DateTime.now().toUtc().millisecondsSinceEpoch,
          );
          if (claimed.isEmpty) break;

          drainedFullBatch = claimed.length == batchSize;
          await _sendBatch(claimed);
        }
      } while (_rerunRequested && !_disposed);
    } finally {
      _draining = false;
      await _refreshCounts(markSynced: true);
    }
  }

  Future<void> _sendBatch(List<SyncOutboxRow> batch) async {
    List<SyncEventResult> results;
    AppLogger.talker.debug('[sync] sending batch (${batch.length} events)');
    try {
      results = await _api.sendBatch(batch);
    } on ApiException catch (e) {
      AppLogger.talker
          .warning('[sync] batch send failed (${e.message}) — rescheduling');
      await _rescheduleBatch(batch);
      return;
    } catch (e, st) {
      AppLogger.talker
          .handle(e, st, '[sync] batch send failed (unexpected) — rescheduling');
      await _rescheduleBatch(batch);
      return;
    }

    final byId = {for (final r in results) r.id: r};
    final settled = <String>[];
    final retry = <String>[];
    var rejected = 0;

    for (final row in batch) {
      final result = byId[row.id];
      if (result == null) {
        // Server didn't mention it — treat as transient.
        retry.add(row.id);
      } else if (result.isSettled) {
        settled.add(row.id);
      } else if (result.isRejected) {
        rejected++;
        AppLogger.talker.warning(
            '[sync] event ${row.id} rejected: ${result.error ?? 'rejected by server'}');
        await _db.syncOutboxDao.markFailed(
          row.id,
          result.error ?? 'rejected by server',
        );
      } else {
        retry.add(row.id);
      }
    }

    await _db.syncOutboxDao.markDone(settled);
    AppLogger.talker.info('[sync] batch settled: ${settled.length} done, '
        '$rejected rejected, ${retry.length} retry');
    if (retry.isNotEmpty) {
      await _rescheduleRows(retry, attemptsHint: batch.first.attempts);
    }
  }

  Future<void> _rescheduleBatch(List<SyncOutboxRow> batch) =>
      _rescheduleRows(batch.map((r) => r.id).toList(),
          attemptsHint: batch.first.attempts);

  Future<void> _rescheduleRows(List<String> ids,
      {required int attemptsHint}) async {
    final delay = syncBackoff(attemptsHint + 1, _random);
    await _db.syncOutboxDao.reschedule(
      ids,
      nextRetryAtMs:
          DateTime.now().toUtc().add(delay).millisecondsSinceEpoch,
    );
    await _db.syncOutboxDao.failExhausted(maxAttempts: maxAttempts);
  }

  Future<void> _refreshCounts({bool markSynced = false}) async {
    if (_disposed) return;
    final pending =
        await _db.syncOutboxDao.countWithStatus(SyncOutboxDao.statusPending);
    final failed =
        await _db.syncOutboxDao.countWithStatus(SyncOutboxDao.statusFailed);
    _status.value = SyncStatus(
      pendingCount: pending,
      failedCount: failed,
      lastSyncedAt:
          markSynced ? DateTime.now().toUtc() : _status.value.lastSyncedAt,
      isSyncing: false,
    );
  }

  Future<void> dispose() async {
    _disposed = true;
    await _triggerSub?.cancel();
  }
}
