import 'package:drift/drift.dart';

/// Single-row table (id is always 0): the account this database belongs to.
/// The database FILE is already per-account (`deadbounce_<uid>.sqlite`);
/// this row carries display data and the one-time-restore flag.
@DataClassName('PlayerProfileRow')
class PlayerProfiles extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();

  /// Backend user id (Guid) — set after first auth/snapshot.
  TextColumn get userId => text().withDefault(const Constant(''))();
  TextColumn get username => text().nullable()();
  TextColumn get displayName => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  BoolColumn get isGuest => boolean().withDefault(const Constant(false))();

  /// True once the one-time GET /sync/snapshot hydration ran for this
  /// account on this device. Never reset.
  BoolColumn get initialSyncCompleted =>
      boolean().withDefault(const Constant(false))();

  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
