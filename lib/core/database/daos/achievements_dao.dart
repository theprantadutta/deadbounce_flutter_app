import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/achievement_states_table.dart';

part 'achievements_dao.g.dart';

@DriftAccessor(tables: [AchievementStates])
class AchievementsDao extends DatabaseAccessor<AppDatabase>
    with _$AchievementsDaoMixin {
  AchievementsDao(super.db);

  Future<List<AchievementStateRow>> getAll() =>
      select(achievementStates).get();

  Stream<List<AchievementStateRow>> watchAll() =>
      select(achievementStates).watch();

  Future<AchievementStateRow?> getState(String achievementId) =>
      (select(achievementStates)
            ..where((a) => a.achievementId.equals(achievementId)))
          .getSingleOrNull();

  Future<void> upsertState(AchievementStateRow row) =>
      into(achievementStates).insertOnConflictUpdate(row);

  /// Sets progress to MAX(current, value); returns nothing — unlock
  /// decisions live in the repository (it knows the catalog thresholds).
  Future<void> raiseProgress(String achievementId, int value) =>
      customStatement(
        'INSERT INTO achievement_states (achievement_id, progress) '
        'VALUES (?, ?) '
        'ON CONFLICT (achievement_id) DO UPDATE SET '
        'progress = MAX(progress, ?)',
        [achievementId, value, value],
      );

  Future<void> markUnlocked(String achievementId, int unlockedAtMs) =>
      customStatement(
        'UPDATE achievement_states SET unlocked_at = ? '
        'WHERE achievement_id = ? AND unlocked_at IS NULL',
        [unlockedAtMs, achievementId],
      );

  Future<void> markClaimed(String achievementId, int claimedAtMs) =>
      (update(achievementStates)
            ..where((a) =>
                a.achievementId.equals(achievementId) &
                a.claimedAt.isNull()))
          .write(AchievementStatesCompanion(claimedAt: Value(claimedAtMs)));
}
