import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../economy/domain/repositories/wallet_repository.dart';
import '../../domain/cosmetic_catalog.dart';
import '../../domain/repositories/cosmetics_repository.dart';

part 'cosmetics_state.dart';

/// Drives the cosmetics shop: live coin balance × owned ids × equipped slots,
/// plus buy/equip actions.
class CosmeticsCubit extends Cubit<CosmeticsState> {
  CosmeticsCubit({
    required this._cosmetics,
    required this._wallet,
  }) : super(const CosmeticsLoading());

  final CosmeticsRepository _cosmetics;
  final WalletRepository _wallet;

  StreamSubscription<int>? _balanceSub;
  StreamSubscription<Set<String>>? _ownedSub;
  StreamSubscription<Map<CosmeticSlot, String>>? _equippedSub;

  int _balance = 0;
  Set<String> _owned = const {};
  Map<CosmeticSlot, String> _equipped = const {};
  bool _hasBalance = false;
  bool _hasOwned = false;
  bool _hasEquipped = false;

  void load() {
    _balanceSub = _wallet.watchBalance().listen((b) {
      _balance = b;
      _hasBalance = true;
      _emit();
    });
    _ownedSub = _cosmetics.watchOwned().listen((o) {
      _owned = o;
      _hasOwned = true;
      _emit();
    });
    _equippedSub = _cosmetics.watchEquipped().listen((e) {
      _equipped = e;
      _hasEquipped = true;
      _emit();
    });
  }

  void _emit() {
    if (_hasBalance && _hasOwned && _hasEquipped) {
      emit(CosmeticsReady(
        balance: _balance,
        owned: Set.of(_owned),
        equipped: Map.of(_equipped),
      ));
    }
  }

  /// Buys [cosmetic]; null on success, else a message to show the player.
  Future<String?> buy(Cosmetic cosmetic) async {
    try {
      await _cosmetics.purchase(cosmetic);
      return null;
    } on CosmeticPurchaseException catch (e) {
      return e.message;
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[cosmetics] purchase failed');
      return 'Purchase failed. Try again.';
    }
  }

  Future<void> equip(Cosmetic cosmetic) async {
    try {
      await _cosmetics.equip(cosmetic);
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[cosmetics] equip failed');
    }
  }

  @override
  Future<void> close() {
    _balanceSub?.cancel();
    _ownedSub?.cancel();
    _equippedSub?.cancel();
    return super.close();
  }
}
