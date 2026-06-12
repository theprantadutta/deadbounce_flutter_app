import 'package:drift/drift.dart';

/// Append-only coin ledger: every coin change is a transaction row, never
/// a mutated integer. The cached balance lives in [CoinBalances] and is
/// updated in the SAME transaction as each insert here.
@DataClassName('CoinLedgerRow')
class CoinLedgerEntries extends Table {
  @override
  String get tableName => 'coin_ledger';

  /// Client-generated uuid v4 — also the sync idempotency key.
  TextColumn get id => text()();

  /// Signed: positive = earned, negative = spent.
  IntColumn get amount => integer()();

  /// CoinReason enum name: runReward | coinPickup | waveBonus | chainBonus |
  /// dailyLogin | dailyChallenge | achievementClaim | snapshotRestore |
  /// adjustment.
  TextColumn get reason => text()();
  TextColumn get runId => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
