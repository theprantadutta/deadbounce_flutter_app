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
  static const Duration _doneRetention = Duration(days: 7);
  static const Duration _reconnectPollInterval = Duration(seconds: 30);

  final AppDatabase _db;
  final SyncApi _api;
  final SyncStatusNotifier _status;
  final SyncTriggerSource _triggers;
  final Random _random;

  StreamSubscription<SyncTrigger>? _triggerSub;
  Timer? _reconnectPoll;
  bool _draining = false;
  bool _rerunRequested = false;
  bool _disposed = false;

  /// The in-flight drain, awaited by [dispose] so the DB isn't closed out from
  /// under a settling batch.
  Future<void>? _drainFuture;

  Future<void> start() async {
    if (_disposed) return; // session was torn down before start ran
    // Crash recovery: a batch stuck inFlight from a killed app goes back
    // to pending — safe because the server dedupes by event id.
    await _db.syncOutboxDao.recoverInFlight();
    // Re-queue anything stuck in 'failed' — either transport-stranded events
    // from an older build (when transport errors could exhaust to 'failed') or
    // server-rejected ones. Rejected events were recorded server-side, so they
    // come back as 'duplicate' and settle to 'done'; transport ones finally
    // deliver. Nothing writes 'failed' from transport anymore, so this is
    // effectively a one-time, self-cleaning recovery per event.
    await _db.syncOutboxDao.retryFailed();
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
      '${_status.value.failedCount} failed)',
    );
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
    _drainFuture = _drainLoop();
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

    var didSync = false;
    try {
      do {
        _rerunRequested = false;

        // Health gate: only drain when the backend is actually reachable. If
        // it's down, leave events 'pending' (no attempts burned) and poll
        // /health until it returns, then re-drain — instead of blindly firing
        // batches at a dead server and stranding the queue.
        if (!await _api.isHealthy()) {
          AppLogger.talker.info(
            '[sync] backend unreachable — deferring drain, polling /health',
          );
          await _ensureReconnectPoll();
          break;
        }
        _cancelReconnectPoll();

        var drainedFullBatch = true;
        while (drainedFullBatch && !_disposed) {
          final claimed = await _db.syncOutboxDao.claimBatch(
            limit: batchSize,
            nowMs: DateTime.now().toUtc().millisecondsSinceEpoch,
          );
          if (claimed.isEmpty) break;

          drainedFullBatch = claimed.length == batchSize;
          await _sendBatch(claimed);
          didSync = true;
        }
      } while (_rerunRequested && !_disposed);
    } finally {
      _draining = false;
      // Only stamp lastSyncedAt when we actually reached the server.
      await _refreshCounts(markSynced: didSync);
    }
  }

  /// While the backend is unreachable AND there's queued work, poll /health
  /// every [_reconnectPollInterval]; once it's back, kick a drain and stop.
  /// No polling when the queue is empty.
  Future<void> _ensureReconnectPoll() async {
    if (_reconnectPoll != null || _disposed) return;
    _reconnectPoll = Timer.periodic(_reconnectPollInterval, (_) async {
      if (_disposed) {
        _cancelReconnectPoll();
        return;
      }
      final pending = await _db.syncOutboxDao.countWithStatus(
        SyncOutboxDao.statusPending,
      );
      if (pending == 0) {
        _cancelReconnectPoll();
        return;
      }
      if (await _api.isHealthy()) {
        _cancelReconnectPoll();
        requestSync();
      }
    });
  }

  void _cancelReconnectPoll() {
    _reconnectPoll?.cancel();
    _reconnectPoll = null;
  }

  Future<void> _sendBatch(List<SyncOutboxRow> batch) async {
    List<SyncEventResult> results;
    AppLogger.talker.debug('[sync] sending batch (${batch.length} events)');
    try {
      results = await _api.sendBatch(batch);
    } on ApiException catch (e) {
      AppLogger.talker.warning(
        '[sync] batch send failed (${e.message}) — rescheduling',
      );
      await _rescheduleBatch(batch);
      return;
    } catch (e, st) {
      AppLogger.talker.handle(
        e,
        st,
        '[sync] batch send failed (unexpected) — rescheduling',
      );
      await _rescheduleBatch(batch);
      return;
    }

    final byId = {for (final r in results) r.id: r};
    final settled = <String>[];
    final retry = <SyncOutboxRow>[];
    final rejected = <SyncOutboxRow>[];

    for (final row in batch) {
      final result = byId[row.id];
      if (result == null) {
        // Server didn't mention it — treat as transient.
        retry.add(row);
      } else if (result.isSettled) {
        settled.add(row.id);
      } else if (result.isRejected) {
        rejected.add(row);
        AppLogger.talker.warning(
          '[sync] event ${row.id} rejected: ${result.error ?? 'rejected by server'}',
        );
      } else {
        retry.add(row);
      }
    }

    // Settle the whole batch in ONE transaction so a crash mid-settlement
    // can't leave it half-applied. (recoverInFlight would re-pend stragglers
    // on next boot regardless, but this keeps the three writes consistent.)
    await _db.transaction(() async {
      await _db.syncOutboxDao.markDone(settled);
      for (final row in rejected) {
        await _db.syncOutboxDao.markFailed(
          row.id,
          byId[row.id]?.error ?? 'rejected by server',
        );
      }
      if (retry.isNotEmpty) {
        await _rescheduleRows(retry);
      }
    });

    AppLogger.talker.info(
      '[sync] batch settled: ${settled.length} done, '
      '${rejected.length} rejected, ${retry.length} retry',
    );
  }

  Future<void> _rescheduleBatch(List<SyncOutboxRow> batch) =>
      _rescheduleRows(batch);

  /// Backs off each row by ITS OWN attempt count (a batch can mix a brand-new
  /// event with an old repeatedly-failing one — they must not share a delay),
  /// so group by attempts and reschedule each group with its own backoff.
  ///
  /// Transient/transport failures retry INDEFINITELY (the backoff delay is
  /// capped at 10 min) — they never become permanently 'failed'. Combined with
  /// the /health gate, this guarantees a queued event is eventually delivered
  /// once the server is reachable, instead of being stranded after N attempts.
  /// Only an explicit server 'rejected' is terminal (handled in _sendBatch).
  Future<void> _rescheduleRows(List<SyncOutboxRow> rows) async {
    final byAttempts = <int, List<String>>{};
    for (final row in rows) {
      byAttempts.putIfAbsent(row.attempts, () => []).add(row.id);
    }
    final nowUtc = DateTime.now().toUtc();
    for (final entry in byAttempts.entries) {
      final delay = syncBackoff(entry.key + 1, _random);
      await _db.syncOutboxDao.reschedule(
        entry.value,
        nextRetryAtMs: nowUtc.add(delay).millisecondsSinceEpoch,
      );
    }
  }

  Future<void> _refreshCounts({bool markSynced = false}) async {
    if (_disposed) return;
    final pending = await _db.syncOutboxDao.countWithStatus(
      SyncOutboxDao.statusPending,
    );
    final failed = await _db.syncOutboxDao.countWithStatus(
      SyncOutboxDao.statusFailed,
    );
    _status.value = SyncStatus(
      pendingCount: pending,
      failedCount: failed,
      lastSyncedAt: markSynced
          ? DateTime.now().toUtc()
          : _status.value.lastSyncedAt,
      isSyncing: false,
    );
  }

  Future<void> dispose() async {
    _disposed = true;
    _cancelReconnectPoll();
    await _triggerSub?.cancel();
    // Let the in-flight drain finish settling the current batch before the
    // caller closes the DB — otherwise markDone/reschedule hit a closed DB.
    // The loop exits at its next !_disposed check, so this is bounded.
    try {
      await _drainFuture;
    } catch (_) {
      // A drain error during teardown is irrelevant; we're shutting down.
    }
  }
}
