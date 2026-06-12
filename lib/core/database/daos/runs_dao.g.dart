// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'runs_dao.dart';

// ignore_for_file: type=lint
mixin _$RunsDaoMixin on DatabaseAccessor<AppDatabase> {
  $RunsTable get runs => attachedDatabase.runs;
  RunsDaoManager get managers => RunsDaoManager(this);
}

class RunsDaoManager {
  final _$RunsDaoMixin _db;
  RunsDaoManager(this._db);
  $$RunsTableTableManager get runs =>
      $$RunsTableTableManager(_db.attachedDatabase, _db.runs);
}
