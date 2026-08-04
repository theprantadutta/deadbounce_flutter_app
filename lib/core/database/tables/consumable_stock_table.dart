import 'package:drift/drift.dart';

/// How many of each pre-run consumable the player holds.
///
/// Definitions (name, cost, effect) live in Dart; this is stock only. The coin
/// SPEND syncs through the ledger as a `shopPurchase`; the stock itself syncs
/// as a `consumableState` aggregate (last-writer-wins), so items a player paid
/// for survive a reinstall.
///
/// Rows are kept at count 0 rather than deleted so the synced aggregate can
/// express "I now hold none of these" — a missing key and a zero would
/// otherwise be indistinguishable to the server.
@DataClassName('ConsumableStockRow')
class ConsumableStock extends Table {
  TextColumn get itemId => text()();
  IntColumn get count => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {itemId};
}
