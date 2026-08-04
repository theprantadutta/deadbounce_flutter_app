import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/consumable_stock_table.dart';

part 'consumables_dao.g.dart';

@DriftAccessor(tables: [ConsumableStock])
class ConsumablesDao extends DatabaseAccessor<AppDatabase>
    with _$ConsumablesDaoMixin {
  ConsumablesDao(super.db);

  Future<List<ConsumableStockRow>> getStock() => select(consumableStock).get();

  Stream<List<ConsumableStockRow>> watchStock() =>
      select(consumableStock).watch();

  Future<int> countOf(String itemId) async {
    final row = await (select(consumableStock)
          ..where((c) => c.itemId.equals(itemId)))
        .getSingleOrNull();
    return row?.count ?? 0;
  }

  Future<void> setCount(String itemId, int count, int nowMs) =>
      into(consumableStock).insertOnConflictUpdate(
        ConsumableStockCompanion(
          itemId: Value(itemId),
          // Never let a bug write a negative stock — it would read as "owed"
          // and could underflow the aggregate the server trusts.
          count: Value(count < 0 ? 0 : count),
          updatedAt: Value(nowMs),
        ),
      );
}
