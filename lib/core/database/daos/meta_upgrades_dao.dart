import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/meta_upgrades_table.dart';

part 'meta_upgrades_dao.g.dart';

@DriftAccessor(tables: [MetaUpgrades])
class MetaUpgradesDao extends DatabaseAccessor<AppDatabase>
    with _$MetaUpgradesDaoMixin {
  MetaUpgradesDao(super.db);

  Future<List<MetaUpgradeRow>> getOwned() => select(metaUpgrades).get();

  Stream<List<MetaUpgradeRow>> watchOwned() => select(metaUpgrades).watch();

  Future<int> levelOf(String perkId) async {
    final row = await (select(metaUpgrades)
          ..where((m) => m.perkId.equals(perkId)))
        .getSingleOrNull();
    return row?.level ?? 0;
  }

  /// Sets a perk's owned level. Call inside the caller's transaction.
  Future<void> setLevel(String perkId, int level, int nowMs) =>
      into(metaUpgrades).insertOnConflictUpdate(
        MetaUpgradeRow(perkId: perkId, level: level, updatedAt: nowMs),
      );
}
