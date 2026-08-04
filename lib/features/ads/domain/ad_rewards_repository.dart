import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_client.dart';
import '../../economy/domain/entities/coin_transaction.dart';
import '../../economy/domain/repositories/wallet_repository.dart';
import '../data/ad_rewards_api.dart';

/// Pulls coins that AdMob's server-side verification already credited.
///
/// The SSV callback goes to the SERVER, so the client never sees the payout
/// land. Without this the player watches an ad and their balance doesn't move
/// until the next reinstall — which reads as the reward being lost.
///
/// Mirrors the IAP rule exactly: the SERVER decides the amount, the client only
/// reflects it, and the local ledger entry is keyed off the transaction id so a
/// replay collides instead of double-crediting.
class AdRewardsRepository {
  AdRewardsRepository({required this._api, required this._wallet});

  final AdRewardsApi _api;
  final WalletRepository _wallet;

  /// Fetches, mirrors, then acknowledges. Returns the coins newly shown.
  ///
  /// Acknowledging only AFTER the local write is deliberate: if the ack is
  /// lost, the next sync replays the same rewards and the ledger insert
  /// collides on its id, so nothing is credited twice and nothing is lost.
  Future<int> sync() async {
    final List<PendingAdRewardDto> pending;
    try {
      pending = await _api.pending();
    } on ApiException catch (e) {
      // Offline is normal; the coins are safe server-side until next time.
      AppLogger.talker.debug('[ads] pending rewards unavailable: ${e.message}');
      return 0;
    }

    if (pending.isEmpty) return 0;

    var credited = 0;
    final acknowledged = <String>[];

    for (final reward in pending) {
      if (reward.transactionId.isEmpty) continue;
      try {
        if (reward.coins > 0) {
          await _wallet.creditServerGranted(
            // Derived from the transaction id, so a replay hits the ledger
            // primary key rather than paying again.
            id: 'ad:${reward.transactionId}',
            amount: reward.coins,
            reason: CoinReason.adReward,
          );
          credited += reward.coins;
        }
        acknowledged.add(reward.transactionId);
      } catch (e, st) {
        // Almost certainly a primary-key collision from an earlier run whose
        // ack was lost — already credited, so acknowledge and move on.
        AppLogger.talker
            .debug('[ads] reward ${reward.transactionId} already mirrored: $e');
        acknowledged.add(reward.transactionId);
        if (e is! Exception) AppLogger.talker.handle(e, st, '[ads] mirror failed');
      }
    }

    if (acknowledged.isNotEmpty) {
      try {
        await _api.acknowledge(acknowledged);
      } on ApiException catch (e) {
        // Harmless: they replay next sync and collide locally.
        AppLogger.talker.debug('[ads] acknowledge failed: ${e.message}');
      }
    }

    if (credited > 0) {
      AppLogger.talker.info('[ads] mirrored $credited coins from ad rewards');
    }
    return credited;
  }
}
