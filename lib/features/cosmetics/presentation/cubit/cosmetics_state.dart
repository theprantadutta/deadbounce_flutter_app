part of 'cosmetics_cubit.dart';

sealed class CosmeticsState extends Equatable {
  const CosmeticsState();

  @override
  List<Object?> get props => [];
}

final class CosmeticsLoading extends CosmeticsState {
  const CosmeticsLoading();
}

final class CosmeticsReady extends CosmeticsState {
  const CosmeticsReady({
    required this.balance,
    required this.owned,
    required this.equipped,
  });

  final int balance;

  /// Owned cosmetic ids (includes the free defaults).
  final Set<String> owned;

  /// Equipped cosmetic id per slot.
  final Map<CosmeticSlot, String> equipped;

  @override
  List<Object?> get props => [balance, owned, equipped];
}
