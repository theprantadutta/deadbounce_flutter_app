import 'package:drift/drift.dart';

/// Generic keyed counters: per-enemy kill counts and per-upgrade pick
/// counts. kind ∈ {enemyKill, upgradePick}, key = enemy/upgrade id.
@DataClassName('StatCounterRow')
class StatCounters extends Table {
  TextColumn get kind => text()();
  TextColumn get key => text()();
  IntColumn get count => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {kind, key};
}
