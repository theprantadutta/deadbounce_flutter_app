import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/wallet_repository.dart';

/// Streams the coin balance for the home/HUD display.
class WalletCubit extends Cubit<int> {
  WalletCubit(this._repository) : super(0) {
    _sub = _repository.watchBalance().listen(emit);
  }

  final WalletRepository _repository;
  late final StreamSubscription<int> _sub;

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
