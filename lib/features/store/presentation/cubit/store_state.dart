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

  /// Entitlement keys the player already holds.
  final Set<String> owned;

  /// The SKU currently mid-purchase, if any — only that tile shows a spinner,
  /// and every other buy button disables.
  final String? busyProductId;

  bool ownsProduct(StoreProduct product) {
    final key = product.entitlementKey;
    return key != null && owned.contains(key);
  }

  StoreReady copyWith({
    List<StoreOffer>? offers,
    Set<String>? owned,
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
