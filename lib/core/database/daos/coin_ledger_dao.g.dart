// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_ledger_dao.dart';

// ignore_for_file: type=lint
mixin _$CoinLedgerDaoMixin on DatabaseAccessor<AppDatabase> {
  $CoinLedgerEntriesTable get coinLedgerEntries =>
      attachedDatabase.coinLedgerEntries;
  $CoinBalancesTable get coinBalances => attachedDatabase.coinBalances;
  CoinLedgerDaoManager get managers => CoinLedgerDaoManager(this);
}

class CoinLedgerDaoManager {
  final _$CoinLedgerDaoMixin _db;
  CoinLedgerDaoManager(this._db);
  $$CoinLedgerEntriesTableTableManager get coinLedgerEntries =>
      $$CoinLedgerEntriesTableTableManager(
        _db.attachedDatabase,
        _db.coinLedgerEntries,
      );
  $$CoinBalancesTableTableManager get coinBalances =>
      $$CoinBalancesTableTableManager(_db.attachedDatabase, _db.coinBalances);
}
