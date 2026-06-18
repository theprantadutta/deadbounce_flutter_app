import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../economy/domain/repositories/wallet_repository.dart';
import '../../domain/meta_catalog.dart';
import '../../domain/repositories/meta_repository.dart';

part 'gunsmith_state.dart';

/// Drives the Gunsmith shop: live coin balance × owned perk levels, and the
/// purchase action.
class GunsmithCubit extends Cubit<GunsmithState> {
  GunsmithCubit({
    required this._meta,
    required this._wallet,
  }) : super(const GunsmithLoading());

  final MetaRepository _meta;
  final WalletRepository _wallet;

  StreamSubscription<int>? _balanceSub;
  StreamSubscription<Map<String, int>>? _ownedSub;
  int _balance = 0;
  Map<String, int> _owned = const {};
  bool _hasBalance = false;
  bool _hasOwned = false;

  void load() {
    _balanceSub = _wallet.watchBalance().listen((b) {
      _balance = b;
      _hasBalance = true;
      _emit();
    });
    _ownedSub = _meta.watchOwnedLevels().listen((o) {
      _owned = o;
      _hasOwned = true;
      _emit();
    });
  }

  void _emit() {
    if (_hasBalance && _hasOwned) {
      emit(GunsmithReady(balance: _balance, owned: Map.of(_owned)));
    }
  }

  /// Buys the next level of [perk]. Returns null on success, or a message to
  /// show the player on failure (maxed / not enough coins).
  Future<String?> buy(MetaPerk perk) async {
    try {
      await _meta.purchase(perk);
      return null;
    } on MetaPurchaseException catch (e) {
      return e.message;
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[meta] purchase failed');
      return 'Purchase failed. Try again.';
    }
  }

  @override
  Future<void> close() {
    _balanceSub?.cancel();
    _ownedSub?.cancel();
    return super.close();
  }
}
