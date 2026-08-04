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

  /// Mirrors coins the SERVER has already credited (a verified purchase, later
  /// a rewarded-ad payout) into the local ledger — **without** an outbox event.
  ///
  /// The missing sync is the entire point. These reasons are server-authoritative
  /// and the backend rejects them over the sync channel; writing one locally is
  /// purely so the balance updates instantly and reads correctly offline.
  ///
  /// [id] must be stable for the granting event (e.g. derived from the Play
  /// purchase token) so a replay collides on the ledger primary key instead of
  /// crediting twice.
  Future<void> creditServerGranted({
    required String id,
    required int amount,
    required CoinReason reason,
  });

  Future<List<CoinTransaction>> recentTransactions({int limit});
}
