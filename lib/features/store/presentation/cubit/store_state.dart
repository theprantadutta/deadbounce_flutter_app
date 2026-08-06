part of 'store_cubit.dart';

sealed class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object?> get props => [];
}

final class StoreLoading extends StoreState {
  const StoreLoading();
}

/// Play Billing isn't reachable (no Play Services, or a store outage).
/// Distinct from an empty shelf so the screen can explain itself.
final class StoreUnavailable extends StoreState {
  const StoreUnavailable(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class StoreReady extends StoreState {
  const StoreReady({
    required this.offers,
    required this.owned,
    this.busyProductId,
  });

  final List<StoreOffer> offers;

  /// What the player holds, with subscription windows.
  final List<OwnedEntitlement> owned;

  /// The SKU currently mid-purchase, if any — only that tile shows a spinner,
  /// and every other buy button disables.
  final String? busyProductId;

  bool ownsProduct(StoreProduct product) => _find(product) != null;

  /// When this product's entitlement lapses, or null if it's permanent (or
  /// not owned). Drives the "ACTIVE UNTIL …" line on the pass.
  DateTime? expiryFor(StoreProduct product) => _find(product)?.expiresAt;

  OwnedEntitlement? _find(StoreProduct product) {
    final key = product.entitlementKey;
    if (key == null) return null;
    for (final e in owned) {
      if (e.key == key) return e;
    }
    return null;
  }

  StoreReady copyWith({
    List<StoreOffer>? offers,
    List<OwnedEntitlement>? owned,
    String? busyProductId,
    bool clearBusy = false,
  }) {
    return StoreReady(
      offers: offers ?? this.offers,
      owned: owned ?? this.owned,
      busyProductId: clearBusy ? null : (busyProductId ?? this.busyProductId),
    );
  }

  @override
  List<Object?> get props => [offers, owned, busyProductId];
}
