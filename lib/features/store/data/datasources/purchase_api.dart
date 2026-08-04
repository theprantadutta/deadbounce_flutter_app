import '../../../../core/network/api_client.dart';

/// One capability the server says the player owns.
class EntitlementDto {
  const EntitlementDto({
    required this.key,
    required this.productId,
    required this.grantedAt,
    this.expiresAt,
  });

  factory EntitlementDto.fromJson(Map<String, dynamic> j) => EntitlementDto(
        key: j['key'] as String,
        productId: j['product_id'] as String? ?? '',
        grantedAt: DateTime.parse(j['granted_at'] as String).toUtc(),
        expiresAt: j['expires_at'] == null
            ? null
            : DateTime.parse(j['expires_at'] as String).toUtc(),
      );

  final String key;
  final String productId;
  final DateTime grantedAt;
  final DateTime? expiresAt;
}

/// The server's verdict on one purchase.
class VerifyPurchaseDto {
  const VerifyPurchaseDto({
    required this.productId,
    required this.coinsGranted,
    required this.cosmeticsGranted,
    required this.entitlements,
    required this.alreadyProcessed,
  });

  factory VerifyPurchaseDto.fromJson(Map<String, dynamic> j) => VerifyPurchaseDto(
        productId: j['product_id'] as String? ?? '',
        coinsGranted: (j['coins_granted'] as num?)?.toInt() ?? 0,
        cosmeticsGranted: (j['cosmetics_granted'] as List? ?? const [])
            .cast<String>()
            .toList(),
        entitlements: (j['entitlements'] as List? ?? const [])
            .cast<Map<String, dynamic>>()
            .map(EntitlementDto.fromJson)
            .toList(),
        alreadyProcessed: j['already_processed'] as bool? ?? false,
      );

  final String productId;

  /// Coins the SERVER credited. The client mirrors exactly this into its local
  /// ledger for display and never computes its own figure.
  final int coinsGranted;
  final List<String> cosmeticsGranted;

  /// The player's FULL entitlement set after this purchase.
  final List<EntitlementDto> entitlements;

  /// True when this receipt had already been redeemed — success, but do NOT
  /// credit the coins locally again.
  final bool alreadyProcessed;
}

class PurchaseApi {
  PurchaseApi(this._apiClient);

  final ApiClient _apiClient;

  /// Redeems a Play purchase token. Note what is NOT sent: no price, no coin
  /// amount, no entitlement name — the server decides all of that from its own
  /// catalog after Google confirms the token.
  Future<VerifyPurchaseDto> verify({
    required String productId,
    required String purchaseToken,
  }) async {
    final json = await _apiClient.post(
      '/purchases/verify',
      body: {'product_id': productId, 'purchase_token': purchaseToken},
    );
    return VerifyPurchaseDto.fromJson(json);
  }

  /// Everything the player owns — backs "Restore purchases".
  Future<List<EntitlementDto>> entitlements() async {
    final json = await _apiClient.get('/purchases/entitlements');
    return (json['entitlements'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(EntitlementDto.fromJson)
        .toList();
  }
}
