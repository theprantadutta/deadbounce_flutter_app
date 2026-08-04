/// What kind of Play product a SKU is. Drives consume-vs-acknowledge.
enum StoreProductKind {
  /// Coin packs. Must be CONSUMED so they can be bought again.
  consumable,

  /// Remove-ads, cosmetic bundles. Acknowledged once, owned forever.
  nonConsumable,

  /// The Bounty Pass. Acknowledged; renewal is Play's business.
  subscription,
}

/// A product as the app presents it.
///
/// **There is no price here on purpose.** Price, currency and formatting come
/// from Google Play at runtime (`ProductDetails.price`), already localised —
/// hardcoding one would show the wrong currency to most of the world and go
/// stale the moment you run a sale.
///
/// Likewise no coin amounts are *trusted* from here: this catalog exists so the
/// UI can describe and order the shelf. What a purchase actually grants is
/// decided by the server's `ProductDefinitions` after Google confirms the
/// receipt. The numbers below are descriptive copy, not authority.
class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.kind,
    required this.title,
    required this.blurb,
    required this.coins,
    this.entitlementKey,
    this.badge,
    this.highlight = false,
  });

  /// Play SKU. Must match the Play Console and the server catalog EXACTLY.
  final String id;
  final StoreProductKind kind;
  final String title;
  final String blurb;

  /// Coins this grants, for display only — the server credits the real amount.
  final int coins;

  /// Capability unlocked, or null.
  final String? entitlementKey;

  /// Small corner label, e.g. "BEST VALUE".
  final String? badge;

  /// Renders with the emphasised treatment.
  final bool highlight;

  bool get isCoinPack => coins > 0 && entitlementKey == null;
}

/// Entitlement keys. Mirror `ProductDefinitions` on the backend — do not rename.
abstract final class Entitlements {
  static const String noAds = 'no_ads';
  static const String supporter = 'supporter';
  static const String bountyPass = 'bounty_pass';
}

/// The shelf.
///
/// **Must stay in lockstep with `ProductDefinitions.All` on the backend.** A SKU
/// here that the server doesn't know is unredeemable — the verify call rejects
/// it as an unknown product and the player has paid for nothing.
abstract final class StoreCatalog {
  static const StoreProduct removeAds = StoreProduct(
    id: 'db_remove_ads',
    kind: StoreProductKind.nonConsumable,
    title: 'REMOVE ADS',
    blurb: 'No banners. No interstitials. Ever.\n'
        'Rewarded ads stay — those are always your choice.',
    coins: 0,
    entitlementKey: Entitlements.noAds,
  );

  static const StoreProduct supporterPack = StoreProduct(
    id: 'db_supporter_pack',
    kind: StoreProductKind.nonConsumable,
    title: 'SUPPORTER PACK',
    blurb: 'Removes ads, hands over 2,000 coins, and an exclusive '
        'supporter bullet trail.',
    coins: 2000,
    entitlementKey: Entitlements.supporter,
    badge: 'BEST VALUE',
    highlight: true,
  );

  static const List<StoreProduct> coinPacks = [
    StoreProduct(
      id: 'db_coins_small',
      kind: StoreProductKind.consumable,
      title: 'POCKET CHANGE',
      blurb: '1,000 coins',
      coins: 1000,
    ),
    StoreProduct(
      id: 'db_coins_medium',
      kind: StoreProductKind.consumable,
      title: 'SADDLE BAG',
      blurb: '5,500 coins',
      coins: 5500,
      badge: '+10%',
    ),
    StoreProduct(
      id: 'db_coins_large',
      kind: StoreProductKind.consumable,
      title: 'STRONGBOX',
      blurb: '12,000 coins',
      coins: 12000,
      badge: '+20%',
    ),
    StoreProduct(
      id: 'db_coins_huge',
      kind: StoreProductKind.consumable,
      title: 'THE VAULT',
      blurb: '30,000 coins',
      coins: 30000,
      badge: '+50%',
      highlight: true,
    ),
  ];

  /// Everything, in shelf order.
  static const List<StoreProduct> all = [
    supporterPack,
    removeAds,
    ...coinPacks,
  ];

  static StoreProduct? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Every SKU to query Play for.
  static Set<String> get productIds => {for (final p in all) p.id};
}
