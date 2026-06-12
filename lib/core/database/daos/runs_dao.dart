import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/runs_table.dart';

part 'runs_dao.g.dart';

@DriftAccessor(tables: [Runs])
class RunsDao extends DatabaseAccessor<AppDatabase> with _$RunsDaoMixin {
  RunsDao(super.db);

  Future<void> insertRun(RunRow row) => into(runs).insert(row);

  Future<List<RunRow>> recentRuns({int limit = 20}) => (select(runs)
        ..orderBy([(r) => OrderingTerm.desc(r.endedAt)])
        ..limit(limit))
      .get();

  Future<RunRow?> bestRun() => (select(runs)
        ..orderBy([(r) => OrderingTerm.desc(r.score)])
        ..limit(1))
      .getSingleOrNull();
}
