import 'package:equatable/equatable.dart';

/// Why coins moved. Names are stored in the ledger and sent over the wire
/// verbatim — do not rename existing values.
enum CoinReason {
  runReward,
  coinPickup,
  waveBonus,
  chainBonus,
  dailyLogin,
  dailyChallenge,
  achievementClaim,
  snapshotRestore,
  adjustment,
  shopPurchase,
}

/// One ledger entry. Balance is never a mutated integer — it is the sum
/// of these.
class CoinTransaction extends Equatable {
  const CoinTransaction({
    required this.id,
    required this.amount,
    required this.reason,
    required this.createdAt,
    this.runId,
  });

  final String id;

  /// Signed: positive = earned, negative = spent.
  final int amount;
  final CoinReason reason;
  final DateTime createdAt;
  final String? runId;

  @override
  List<Object?> get props => [id, amount, reason, createdAt, runId];
}
