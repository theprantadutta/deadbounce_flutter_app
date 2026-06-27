import 'package:drift/drift.dart';

/// Local-only progress for the Trick-Shot Gallery (a single-player puzzle mode):
/// the per-level cleared flag + best (fewest) shots. Definitions live in the
/// Dart catalog; this only holds progress. Not synced — re-clearable puzzle
/// progress lives on-device (offline-first).
@DataClassName('TrickShotProgressRow')
class TrickShotProgress extends Table {
  TextColumn get levelId => text()();
  BoolColumn get cleared => boolean().withDefault(const Constant(false))();

  /// Fewest shots used to clear (null until first cleared).
  IntColumn get bestShots => integer().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {levelId};
}
