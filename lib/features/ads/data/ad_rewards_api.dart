import '../../../core/network/api_client.dart';

/// One SSV-credited payout the server has for this player.
class PendingAdRewardDto {
  const PendingAdRewardDto({
    required this.transactionId,
    required this.rewardItem,
    required this.coins,
  });

  factory PendingAdRewardDto.fromJson(Map<String, dynamic> j) =>
      PendingAdRewardDto(
        transactionId: j['transaction_id'] as String? ?? '',
        rewardItem: j['reward_item'] as String? ?? '',
        coins: (j['coins'] as num?)?.toInt() ?? 0,
      );

  final String transactionId;
  final String rewardItem;
  final int coins;
}

class AdRewardsApi {
  AdRewardsApi(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PendingAdRewardDto>> pending() async {
    final json = await _apiClient.get('/ads/rewards/pending');
    return (json['rewards'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(PendingAdRewardDto.fromJson)
        .toList();
  }

  Future<void> acknowledge(List<String> transactionIds) =>
      _apiClient.post(
        '/ads/rewards/acknowledge',
        body: {'transaction_ids': transactionIds},
      );
}
