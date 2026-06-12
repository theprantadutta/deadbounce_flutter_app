import 'package:drift/drift.dart';

/// Single-row (id 0) cached wallet balance. Maintained incrementally in
/// the same transaction as every ledger insert; full SUM-derivation from
/// the ledger is a repair/assert path, never the hot path.
@DataClassName('CoinBalanceRow')
class CoinBalances extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  IntColumn get balance => integer().withDefault(const Constant(0))();
  IntColumn get lastLedgerCreatedAt =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
