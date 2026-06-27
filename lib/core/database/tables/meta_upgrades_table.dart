import 'package:drift/drift.dart';

/// Player-owned permanent ("Gunsmith") upgrades. Definitions live in Dart
/// (the meta catalog), NOT the database — this table only holds the owned
/// LEVEL per perk id (0 = not owned; perks are tiered). Ownership syncs as a
/// `metaState` aggregate (last-writer-wins) and restores from the snapshot on
/// reinstall; the coin spend rides the ledger outbox as `shopPurchase`.
@DataClassName('MetaUpgradeRow')
class MetaUpgrades extends Table {
  TextColumn get perkId => text()();
  IntColumn get level => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {perkId};
}
