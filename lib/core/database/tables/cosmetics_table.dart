import 'package:drift/drift.dart';

/// Cosmetics the player OWNS — presence of a row means owned. Definitions
/// (name, cost, colors) live in Dart (the cosmetics catalog), NOT the DB.
/// The coin spend syncs via the ledger; ownership + equip sync as a
/// `cosmeticState` aggregate event (last-writer-wins).
@DataClassName('CosmeticOwnedRow')
class CosmeticOwned extends Table {
  TextColumn get cosmeticId => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {cosmeticId};
}

/// The currently EQUIPPED cosmetic per slot — one row per slot
/// (`bulletTrail` | `gunslinger` | `arenaTheme`).
@DataClassName('CosmeticEquippedRow')
class CosmeticEquipped extends Table {
  TextColumn get slot => text()();
  TextColumn get cosmeticId => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {slot};
}
