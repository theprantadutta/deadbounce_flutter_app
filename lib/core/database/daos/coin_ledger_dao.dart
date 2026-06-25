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
    // Use customUpdate (NOT customStatement) and declare the affected table so
    // Drift fires a change notification for `coin_balances`. customStatement
    // runs raw SQL that Drift can't analyze, so it notifies NO query streams —
    // which left watchBalance() (the home/HUD coin readout) stuck at its last
    // value after a daily-login claim or run payout until its cubit was
    // recreated. The balance was always written correctly; only the live
    // stream went stale.
    await customUpdate(
      'INSERT INTO coin_balances (id, balance, last_ledger_created_at) '
      'VALUES (0, ?, ?) '
      'ON CONFLICT (id) DO UPDATE SET '
      'balance = balance + ?, last_ledger_created_at = ?',
      variables: [
        Variable<int>(row.amount),
        Variable<int>(row.createdAt),
        Variable<int>(row.amount),
        Variable<int>(row.createdAt),
      ],
      updates: {coinBalances},
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
