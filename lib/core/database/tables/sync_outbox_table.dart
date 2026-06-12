import 'package:drift/drift.dart';

/// The sync outbox: every syncable mutation is written here in the SAME
/// Drift transaction as its domain write, then drained in batches by the
/// SyncWorker. The row id (client uuid) is the server-side idempotency key.
@DataClassName('SyncOutboxRow')
class SyncOutbox extends Table {
  TextColumn get id => text()();

  /// SyncEntityType enum name: runCompleted | coinTxn | achievementUnlock |
  /// challengeResult | statsDelta | scoreSubmit | streakUpdate |
  /// accountLinked.
  TextColumn get entityType => text()();
  TextColumn get operation => text().withDefault(const Constant('create'))();
  TextColumn get payload => text()();
  IntColumn get createdAt => integer()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  /// pending | inFlight | done | failed
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get nextRetryAt => integer().nullable()();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
