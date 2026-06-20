import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/cosmetics_table.dart';

part 'cosmetics_dao.g.dart';

@DriftAccessor(tables: [CosmeticOwned, CosmeticEquipped])
class CosmeticsDao extends DatabaseAccessor<AppDatabase>
    with _$CosmeticsDaoMixin {
  CosmeticsDao(super.db);

  // --- Ownership ---
  Future<List<CosmeticOwnedRow>> getOwned() => select(cosmeticOwned).get();

  Stream<List<CosmeticOwnedRow>> watchOwned() => select(cosmeticOwned).watch();

  Future<bool> isOwned(String id) async =>
      await (select(cosmeticOwned)..where((c) => c.cosmeticId.equals(id)))
          .getSingleOrNull() !=
      null;

  /// Records ownership. Call inside the caller's transaction.
  Future<void> addOwned(String id, int nowMs) =>
      into(cosmeticOwned).insertOnConflictUpdate(
        CosmeticOwnedRow(cosmeticId: id, updatedAt: nowMs),
      );

  // --- Equipped ---
  Future<List<CosmeticEquippedRow>> getEquipped() =>
      select(cosmeticEquipped).get();

  Stream<List<CosmeticEquippedRow>> watchEquipped() =>
      select(cosmeticEquipped).watch();

  Future<void> setEquipped(String slot, String id, int nowMs) =>
      into(cosmeticEquipped).insertOnConflictUpdate(
        CosmeticEquippedRow(slot: slot, cosmeticId: id, updatedAt: nowMs),
      );
}
