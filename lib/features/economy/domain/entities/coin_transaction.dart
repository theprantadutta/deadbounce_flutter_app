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

  /// Coin entry fee paid to join a tournament (negative).
  tournamentEntry,

  /// Coins awarded for a tournament final rank (positive).
  tournamentReward,

  /// In-run coin sink: rerolling the upgrade draft (negative, escalating).
  draftReroll,

  /// In-run coin sink: buying back from death, once per run (negative).
  continueRun,

  /// Coins from a verified real-money purchase.
  ///
  /// **Server-credited.** This entry is written locally ONLY so the balance
  /// updates instantly and reads correctly offline — it is never synced. The
  /// backend already credited its own ledger during receipt verification and
  /// explicitly REJECTS this reason arriving over the sync channel, because a
  /// client that could mint IAP coins would devalue every pack sold.
  iapCoinPack,
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
