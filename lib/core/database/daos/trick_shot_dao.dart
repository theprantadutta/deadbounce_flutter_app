import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/trick_shot_progress_table.dart';

part 'trick_shot_dao.g.dart';

@DriftAccessor(tables: [TrickShotProgress])
class TrickShotDao extends DatabaseAccessor<AppDatabase>
    with _$TrickShotDaoMixin {
  TrickShotDao(super.db);

  Stream<List<TrickShotProgressRow>> watchAll() =>
      select(trickShotProgress).watch();

  Future<List<TrickShotProgressRow>> getAll() => select(trickShotProgress).get();

  /// Marks [levelId] cleared, keeping the FEWEST shots across attempts.
  Future<void> recordClear(String levelId, int shots, int nowMs) =>
      transaction(() async {
        final existing = await (select(trickShotProgress)
              ..where((t) => t.levelId.equals(levelId)))
            .getSingleOrNull();
        final prevBest = existing?.bestShots;
        final best = prevBest == null || shots < prevBest ? shots : prevBest;
        await into(trickShotProgress).insertOnConflictUpdate(
          TrickShotProgressRow(
            levelId: levelId,
            cleared: true,
            bestShots: best,
            updatedAt: nowMs,
          ),
        );
      });
}
