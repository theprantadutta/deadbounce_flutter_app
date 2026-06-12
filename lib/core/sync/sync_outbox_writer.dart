import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/daos/sync_outbox_dao.dart';
import 'sync_event.dart';

/// Writes outbox rows. The load-bearing invariant of the offline-first
/// design: [enqueue] must be called INSIDE the same `db.transaction(...)`
/// as the domain write it describes. Drift transactions are zone-scoped,
/// so DAO calls inside the callback automatically join it — domain row and
/// outbox row commit or roll back together.
class SyncOutboxWriter {
  SyncOutboxWriter(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  /// [eventId] defaults to a fresh uuid v4; pass one explicitly when the
  /// domain row's own id doubles as the event id (e.g. coin transactions).
  Future<void> enqueue(
    SyncEntityType type,
    Map<String, dynamic> payload, {
    String? eventId,
  }) {
    return _db.syncOutboxDao.enqueue(
      SyncOutboxRow(
        id: eventId ?? _uuid.v4(),
        entityType: type.name,
        operation: 'create',
        payload: jsonEncode(payload),
        createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        attempts: 0,
        status: SyncOutboxDao.statusPending,
        nextRetryAt: null,
        lastError: null,
      ),
    );
  }
}
