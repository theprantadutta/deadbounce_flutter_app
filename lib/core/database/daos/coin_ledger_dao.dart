import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/coin_balance_table.dart';
import '../tables/coin_ledger_table.dart';

part 'coin_ledger_dao.g.dart';

@DriftAccessor(tables: [CoinLedgerEntries, CoinBalances])
class CoinLedgerDao extends DatabaseAccessor<AppDatabase>
    with _$CoinLedgerDaoMixin {
  CoinLedgerDao(super.db);

  /// Inserts a ledger row AND bumps the cached balance. Must be called
  /// inside the caller's transaction so ledger + balance + outbox commit
  /// together.
  Future<void> insertTransaction(CoinLedgerRow row) async {
    await into(coinLedgerEntries).insert(row);
    await customStatement(
      'INSERT INTO coin_balances (id, balance, last_ledger_created_at) '
      'VALUES (0, ?, ?) '
      'ON CONFLICT (id) DO UPDATE SET '
      'balance = balance + ?, last_ledger_created_at = ?',
      [row.amount, row.createdAt, row.amount, row.createdAt],
    );
  }

  Future<int> getBalance() async {
    final row = await (select(coinBalances)..where((b) => b.id.equals(0)))
        .getSingleOrNull();
    return row?.balance ?? 0;
  }

  Stream<int> watchBalance() =>
      (select(coinBalances)..where((b) => b.id.equals(0)))
          .watchSingleOrNull()
          .map((row) => row?.balance ?? 0);

  /// Full re-derivation from the ledger — repair/assert path only.
  Future<int> deriveBalance() async {
    final sum = coinLedgerEntries.amount.sum();
    final query = selectOnly(coinLedgerEntries)..addColumns([sum]);
    final row = await query.getSingle();
    return row.read(sum) ?? 0;
  }

  Future<List<CoinLedgerRow>> recentTransactions({int limit = 50}) =>
      (select(coinLedgerEntries)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit))
          .get();
}
