part of 'gunsmith_cubit.dart';

sealed class GunsmithState extends Equatable {
  const GunsmithState();

  @override
  List<Object?> get props => [];
}

final class GunsmithLoading extends GunsmithState {
  const GunsmithLoading();
}

final class GunsmithReady extends GunsmithState {
  const GunsmithReady({required this.balance, required this.owned});

  final int balance;

  /// perkId → owned level.
  final Map<String, int> owned;

  @override
  List<Object?> get props => [balance, owned];
}
