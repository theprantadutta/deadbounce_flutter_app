import 'package:drift/drift.dart';

/// Per-achievement progress/unlock state. Definitions live in Dart code
/// (the achievement catalog), NOT in the database — this table only holds
/// the player's state keyed by the catalog id.
@DataClassName('AchievementStateRow')
class AchievementStates extends Table {
  TextColumn get achievementId => text()();
  IntColumn get progress => integer().withDefault(const Constant(0))();

  /// Set when the requirement is met. Claiming (coin reward granted) is a
  /// separate step so the awards screen can run its claim animation.
  IntColumn get unlockedAt => integer().nullable()();
  IntColumn get claimedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {achievementId};
}
