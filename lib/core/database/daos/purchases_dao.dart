import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/purchase_tables.dart';

part 'purchases_dao.g.dart';

@DriftAccessor(tables: [Entitlements, ProcessedPurchases])
class PurchasesDao extends DatabaseAccessor<AppDatabase>
    with _$PurchasesDaoMixin {
  PurchasesDao(super.db);

  // ---- Entitlements (server-owned, replaced wholesale) ----

  Future<List<EntitlementRow>> allEntitlements() => select(entitlements).get();

  Stream<List<EntitlementRow>> watchEntitlements() => select(entitlements).watch();

  /// Replaces the entire cached set in one transaction.
  ///
  /// Wholesale replacement rather than upsert-per-row is deliberate: the server
  /// response is the complete truth, so a REVOKED entitlement (refund,
  /// chargeback, lapsed subscription) has to disappear locally too. Merging
  /// would leave a refunded purchase working forever.
  Future<void> replaceEntitlements(List<EntitlementsCompanion> rows) {
    return transaction(() async {
      await delete(entitlements).go();
      if (rows.isEmpty) return;
      await batch((b) => b.insertAll(entitlements, rows));
    });
  }

  // ---- Processed purchases (local dedup for the coin mirror) ----

  Future<bool> isPurchaseProcessed(String purchaseToken) async {
    final row = await (select(processedPurchases)
          ..where((p) => p.purchaseToken.equals(purchaseToken)))
        .getSingleOrNull();
    return row != null;
  }

  Future<void> markPurchaseProcessed(ProcessedPurchasesCompanion row) =>
      into(processedPurchases).insertOnConflictUpdate(row);

  Future<List<ProcessedPurchaseRow>> allProcessedPurchases() =>
      select(processedPurchases).get();
}
