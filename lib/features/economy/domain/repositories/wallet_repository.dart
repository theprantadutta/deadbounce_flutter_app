import '../entities/coin_transaction.dart';

/// The single surface for coin movement. Every change is a ledger
/// transaction (Drift first, synced via outbox); balance is derived.
abstract interface class WalletRepository {
  Stream<int> watchBalance();

  Future<int> getBalance();

  /// Records a coin movement: ledger row + cached balance + outbox event,
  /// all in one transaction. Returns the created transaction.
  Future<CoinTransaction> addTransaction({
    required int amount,
    required CoinReason reason,
    String? runId,
  });

  Future<List<CoinTransaction>> recentTransactions({int limit});
}
