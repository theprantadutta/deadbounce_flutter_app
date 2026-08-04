import '../store_catalog.dart';

/// A catalog product joined with its live Play pricing.
class StoreOffer {
  const StoreOffer({
    required this.product,
    required this.price,
    required this.available,
  });

  final StoreProduct product;

  /// Google Play's already-localised price string ("₹89.00", "$0.99").
  /// Empty when Play couldn't be reached or the SKU isn't configured yet.
  final String price;

  /// False when Play doesn't know this SKU — usually a Console/catalog skew.
  final bool available;
}

/// Why a purchase attempt ended.
sealed class PurchaseOutcome {
  const PurchaseOutcome();
}

/// Bought, verified by the server, and granted.
final class PurchaseSucceeded extends PurchaseOutcome {
  const PurchaseSucceeded({
    required this.productId,
    required this.coinsGranted,
  });

  final String productId;

  /// Coins the SERVER credited (0 when this receipt had already been redeemed).
  final int coinsGranted;
}

/// The player dismissed the Play sheet. Not an error — show nothing.
final class PurchaseCancelled extends PurchaseOutcome {
  const PurchaseCancelled();
}

/// Play accepted it but it isn't paid yet (cash, voucher, parental approval).
/// The entitlement arrives later, so tell the player to expect it.
final class PurchasePending extends PurchaseOutcome {
  const PurchasePending();
}

final class PurchaseFailed extends PurchaseOutcome {
  const PurchaseFailed(this.message);

  /// Already user-presentable.
  final String message;
}

abstract interface class StoreRepository {
  /// True once Play Billing is reachable. False on a device without Play
  /// Services — the store UI then explains itself instead of hanging.
  Future<bool> isAvailable();

  /// The shelf, priced by Play.
  Future<List<StoreOffer>> offers();

  /// Runs the full flow: Play sheet → server verification → local grant.
  /// Completes only once the server has verified (or the attempt has ended).
  Future<PurchaseOutcome> buy(StoreProduct product);

  /// Re-pulls entitlements from the server and replays anything Play still
  /// considers unfinished. Backs Settings → Restore purchases, which Google
  /// Play REQUIRES to work.
  Future<void> restore();

  /// Locally cached entitlement keys, live. Readable offline.
  Stream<Set<String>> watchEntitlements();

  Future<Set<String>> currentEntitlements();

  /// Convenience for the Phase 4 ad gate.
  Future<bool> hasEntitlement(String key);

  /// Starts listening to Play's purchase stream. Called once at session start:
  /// it recovers purchases that completed while the app was dead.
  void start();

  Future<void> dispose();
}
