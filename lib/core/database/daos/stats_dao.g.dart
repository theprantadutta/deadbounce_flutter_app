// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_dao.dart';

// ignore_for_file: type=lint
mixin _$StatsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlayerStatsTableTable get playerStatsTable =>
      attachedDatabase.playerStatsTable;
  $StatCountersTable get statCounters => attachedDatabase.statCounters;
  StatsDaoManager get managers => StatsDaoManager(this);
}

class StatsDaoManager {
  final _$StatsDaoMixin _db;
  StatsDaoManager(this._db);
  $$PlayerStatsTableTableTableManager get playerStatsTable =>
      $$PlayerStatsTableTableTableManager(
        _db.attachedDatabase,
        _db.playerStatsTable,
      );
  $$StatCountersTableTableManager get statCounters =>
      $$StatCountersTableTableManager(_db.attachedDatabase, _db.statCounters);
}
