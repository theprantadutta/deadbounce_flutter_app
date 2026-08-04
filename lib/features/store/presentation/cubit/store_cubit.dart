import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/logging/app_logger.dart';
import '../../domain/repositories/store_repository.dart';
import '../../domain/store_catalog.dart';

part 'store_state.dart';

/// Drives the store screen: the priced shelf, what's already owned, and the
/// in-flight purchase.
class StoreCubit extends Cubit<StoreState> {
  StoreCubit(this._repository) : super(const StoreLoading());

  final StoreRepository _repository;
  StreamSubscription<Set<String>>? _entitlementSub;

  Future<void> load() async {
    emit(const StoreLoading());

    final available = await _repository.isAvailable();
    if (isClosed) return;

    if (!available) {
      // A device without Play Services, or Billing genuinely unreachable.
      // Say so plainly instead of showing an empty shelf that does nothing.
      emit(const StoreUnavailable(
        'The store is unavailable on this device right now.',
      ));
      return;
    }

    final offers = await _repository.offers();
    if (isClosed) return;

    // Owned state drives the whole shelf, so track it live: a purchase
    // completed on another screen (or recovered at start-up) flips the button
    // to OWNED without anyone having to reload.
    _entitlementSub ??= _repository.watchEntitlements().listen((owned) {
      final s = state;
      if (s is StoreReady) emit(s.copyWith(owned: owned));
    });

    emit(StoreReady(
      offers: offers,
      owned: await _repository.currentEntitlements(),
    ));
  }

  /// Buys [product]. Returns the outcome so the screen can decide what to say —
  /// a cancellation, for instance, deserves no message at all.
  Future<PurchaseOutcome> buy(StoreProduct product) async {
    final s = state;
    if (s is! StoreReady || s.busyProductId != null) {
      return const PurchaseFailed('A purchase is already in progress.');
    }

    emit(s.copyWith(busyProductId: product.id));
    try {
      final outcome = await _repository.buy(product);
      if (!isClosed) {
        emit((state as StoreReady).copyWith(clearBusy: true));
      }
      return outcome;
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[store] buy failed');
      if (!isClosed) emit((state as StoreReady).copyWith(clearBusy: true));
      return const PurchaseFailed('Something went wrong. Please try again.');
    }
  }

  /// Re-pulls entitlements from the server and replays unfinished purchases.
  /// Returns null on success, or a message to show.
  Future<String?> restore() async {
    try {
      await _repository.restore();
      if (!isClosed) {
        final s = state;
        if (s is StoreReady) {
          emit(s.copyWith(owned: await _repository.currentEntitlements()));
        }
      }
      return null;
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[store] restore failed');
      return 'Could not reach the store. Check your connection and try again.';
    }
  }

  @override
  Future<void> close() {
    _entitlementSub?.cancel();
    return super.close();
  }
}
