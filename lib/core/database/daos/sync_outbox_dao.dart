import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/sync_outbox_table.dart';

part 'sync_outbox_dao.g.dart';

@DriftAccessor(tables: [SyncOutbox])
class SyncOutboxDao extends DatabaseAccessor<AppDatabase>
    with _$SyncOutboxDaoMixin {
  SyncOutboxDao(super.db);

  static const String statusPending = 'pending';
  static const String statusInFlight = 'inFlight';
  static const String statusDone = 'done';
  static const String statusFailed = 'failed';

  Future<void> enqueue(SyncOutboxRow row) => into(syncOutbox).insert(row);

  /// Claims up to [limit] due pending events: selects them in createdAt
  /// order and flips them to inFlight in one transaction so a concurrent
  /// drain can't double-send.
  Future<List<SyncOutboxRow>> claimBatch({
    required int limit,
    required int nowMs,
  }) =>
      transaction(() async {
        final rows = await (select(syncOutbox)
              ..where((o) =>
                  o.status.equals(statusPending) &
                  (o.nextRetryAt.isNull() |
                      o.nextRetryAt.isSmallerOrEqualValue(nowMs)))
              ..orderBy([(o) => OrderingTerm.asc(o.createdAt)])
              ..limit(limit))
            .get();

        if (rows.isNotEmpty) {
          final ids = rows.map((r) => r.id).toList();
          await (update(syncOutbox)..where((o) => o.id.isIn(ids))).write(
            const SyncOutboxCompanion(status: Value(statusInFlight)),
          );
        }
        return rows;
      });

  Future<void> markDone(List<String> ids) async {
    if (ids.isEmpty) return;
    await (update(syncOutbox)..where((o) => o.id.isIn(ids))).write(
      const SyncOutboxCompanion(status: Value(statusDone)),
    );
  }

  Future<void> markFailed(String id, String error) =>
      (update(syncOutbox)..where((o) => o.id.equals(id))).write(
        SyncOutboxCompanion(
          status: const Value(statusFailed),
          lastError: Value(error),
        ),
      );

  /// Returns a transport-failed batch to pending with backoff scheduling.
  Future<void> reschedule(List<String> ids, {required int nextRetryAtMs}) async {
    if (ids.isEmpty) return;
    await customStatement(
      'UPDATE sync_outbox SET status = ?, attempts = attempts + 1, '
      'next_retry_at = ? WHERE id IN (${List.filled(ids.length, '?').join(',')})',
      [statusPending, nextRetryAtMs, ...ids],
    );
  }

  /// Crash recovery: anything stuck inFlight goes back to pending. Safe
  /// because the server dedupes by event id.
  Future<void> recoverInFlight() => customStatement(
        'UPDATE sync_outbox SET status = ? WHERE status = ?',
        [statusPending, statusInFlight],
      );

  /// Failed events back to pending for a manual "Retry sync".
  Future<void> retryFailed() => customStatement(
        'UPDATE sync_outbox SET status = ?, attempts = 0, next_retry_at = NULL '
        'WHERE status = ?',
        [statusPending, statusFailed],
      );

  Future<int> countWithStatus(String status) async {
    final count = syncOutbox.id.count();
    final query = selectOnly(syncOutbox)
      ..addColumns([count])
      ..where(syncOutbox.status.equals(status));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> pruneDone({required int olderThanMs}) =>
      (delete(syncOutbox)
            ..where((o) =>
                o.status.equals(statusDone) &
                o.createdAt.isSmallerThanValue(olderThanMs)))
          .go();
}
