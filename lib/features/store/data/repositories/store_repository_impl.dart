import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../../core/analytics/analytics.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/network/api_client.dart';
import '../../../economy/domain/entities/coin_transaction.dart';
import '../../../economy/domain/repositories/wallet_repository.dart';
import '../../domain/repositories/store_repository.dart';
import '../../domain/store_catalog.dart';
import '../datasources/purchase_api.dart';

/// Play Billing + server verification.
///
/// The rule this class exists to enforce: **nothing is granted until the server
/// has verified the receipt with Google.** Play's own "purchased" callback is
/// treated as nothing more than "here is a token worth checking" — it can be
/// faked by a patched client, so it never directly unlocks anything.
class StoreRepositoryImpl implements StoreRepository {
  StoreRepositoryImpl({
    required this._db,
    required this._api,
    required this._wallet,
    InAppPurchase? iap,
  }) : _iap = iap ?? InAppPurchase.instance;

  final AppDatabase _db;
  final PurchaseApi _api;
  final WalletRepository _wallet;
  final InAppPurchase _iap;

  StreamSubscription<List<PurchaseDetails>>? _sub;

  /// Completes the `buy()` currently awaiting Play's answer. Play reports
  /// purchases on a broadcast stream rather than as a future, so the in-flight
  /// call parks here until its product comes back.
  final Map<String, Completer<PurchaseOutcome>> _pending = {};

  @override
  void start() {
    _sub ??= _iap.purchaseStream.listen(
      _onPurchases,
      onError: (Object e, StackTrace st) =>
          AppLogger.talker.handle(e, st, '[store] purchase stream error'),
    );

    // Recover anything Play still considers unfinished. This is what saves a
    // player who paid and then lost the app mid-flight — Play redelivers the
    // purchase here and we verify it as if nothing happened.
    unawaited(_iap.restorePurchases().catchError((Object e, StackTrace st) {
      AppLogger.talker.handle(e, st, '[store] initial restore failed');
    }));
  }

  @override
  Future<bool> isAvailable() async {
    try {
      return await _iap.isAvailable();
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[store] isAvailable failed');
      return false;
    }
  }

  @override
  Future<List<StoreOffer>> offers() async {
    try {
      final response = await _iap.queryProductDetails(StoreCatalog.productIds);

      if (response.error != null) {
        AppLogger.talker
            .warning('[store] queryProductDetails: ${response.error!.message}');
      }
      // A SKU Play doesn't know is a Console/catalog skew — log it loudly,
      // because it means a shelf item is unbuyable.
      if (response.notFoundIDs.isNotEmpty) {
        AppLogger.talker.warning(
          '[store] SKUs missing from Play: ${response.notFoundIDs.join(', ')}',
        );
      }

      final details = {
        for (final d in response.productDetails) d.id: d,
      };

      return [
        for (final product in StoreCatalog.all)
          StoreOffer(
            product: product,
            // Play's price string is already localised — never format it here.
            price: details[product.id]?.price ?? '',
            available: details.containsKey(product.id),
          ),
      ];
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[store] offers failed');
      return [
        for (final product in StoreCatalog.all)
          StoreOffer(product: product, price: '', available: false),
      ];
    }
  }

  @override
  Future<PurchaseOutcome> buy(StoreProduct product) async {
    // A second tap while the first is in flight must not open two Play sheets.
    final existing = _pending[product.id];
    if (existing != null) return existing.future;

    final ProductDetailsResponse response;
    try {
      response = await _iap.queryProductDetails({product.id});
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[store] buy: product lookup failed');
      return const PurchaseFailed('Could not reach the store. Try again.');
    }

    if (response.productDetails.isEmpty) {
      return const PurchaseFailed('That item is not available right now.');
    }

    final completer = Completer<PurchaseOutcome>();
    _pending[product.id] = completer;

    try {
      final param = PurchaseParam(productDetails: response.productDetails.first);
      // Consumables go through buyConsumable so Play knows they're repeatable;
      // everything else is a one-time entitlement.
      final started = product.kind == StoreProductKind.consumable
          ? await _iap.buyConsumable(purchaseParam: param, autoConsume: false)
          : await _iap.buyNonConsumable(purchaseParam: param);

      if (!started) {
        _pending.remove(product.id);
        return const PurchaseFailed('The store could not start that purchase.');
      }
    } catch (e, st) {
      _pending.remove(product.id);
      AppLogger.talker.handle(e, st, '[store] buy failed to start');
      return const PurchaseFailed('Could not start that purchase.');
    }

    Analytics.purchaseStarted(productId: product.id, kind: product.kind.name);
    return completer.future;
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      try {
        await _handlePurchase(purchase);
      } catch (e, st) {
        AppLogger.talker.handle(e, st, '[store] purchase handling failed');
        _resolve(purchase.productID,
            const PurchaseFailed('Something went wrong. Please try again.'));
        // Never leave a purchase uncompleted — Play redelivers it forever.
        await _completeIfNeeded(purchase);
      }
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        // Cash/voucher/parental approval. Real money may still arrive, so we
        // neither grant nor complete it — Play will re-emit when it resolves.
        Analytics.purchaseResult(
            productId: purchase.productID, result: 'pending');
        _resolve(purchase.productID, const PurchasePending());
        return;

      case PurchaseStatus.canceled:
        Analytics.purchaseResult(
            productId: purchase.productID, result: 'cancelled');
        _resolve(purchase.productID, const PurchaseCancelled());
        await _completeIfNeeded(purchase);
        return;

      case PurchaseStatus.error:
        final message = purchase.error?.message ?? 'The purchase failed.';
        AppLogger.talker.warning('[store] purchase error: $message');
        Analytics.purchaseResult(
            productId: purchase.productID, result: 'error');
        _resolve(purchase.productID, PurchaseFailed(message));
        await _completeIfNeeded(purchase);
        return;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _verifyAndGrant(purchase);
        return;
    }
  }

  Future<void> _verifyAndGrant(PurchaseDetails purchase) async {
    final token = purchase.verificationData.serverVerificationData;
    if (token.isEmpty) {
      _resolve(purchase.productID,
          const PurchaseFailed('That purchase could not be verified.'));
      await _completeIfNeeded(purchase);
      return;
    }

    final VerifyPurchaseDto verified;
    try {
      verified = await _api.verify(
        productId: purchase.productID,
        purchaseToken: token,
      );
    } on ApiException catch (e) {
      // Deliberately do NOT complete the purchase here. Play keeps redelivering
      // an uncompleted purchase, which is exactly what we want while the server
      // is unreachable — the player paid, and the grant must survive a bad
      // network. Completing now would throw the receipt away.
      AppLogger.talker.warning('[store] verify failed: ${e.message}');
      Analytics.purchaseResult(
          productId: purchase.productID, result: 'verify_failed');
      _resolve(
        purchase.productID,
        PurchaseFailed(
          e.statusCode == 503
              ? 'The store is busy. Your purchase is safe — try again shortly.'
              : e.message,
        ),
      );
      return;
    }

    await _persistGrant(purchase, verified);

    // Only now is it safe to tell Play we're done: the entitlement is recorded
    // server-side and mirrored locally.
    await _completeIfNeeded(purchase);

    Analytics.purchaseResult(
      productId: purchase.productID,
      result: verified.alreadyProcessed ? 'already_owned' : 'granted',
    );

    _resolve(
      purchase.productID,
      PurchaseSucceeded(
        productId: purchase.productID,
        coinsGranted: verified.alreadyProcessed ? 0 : verified.coinsGranted,
      ),
    );
  }

  Future<void> _persistGrant(
    PurchaseDetails purchase,
    VerifyPurchaseDto verified,
  ) async {
    final token = purchase.verificationData.serverVerificationData;
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    // The server's entitlement set is the whole truth — replace, don't merge,
    // so a refunded or lapsed entitlement disappears locally too.
    await _db.purchasesDao.replaceEntitlements([
      for (final e in verified.entitlements)
        EntitlementsCompanion(
          entitlementKey: Value(e.key),
          productId: Value(e.productId),
          grantedAt: Value(e.grantedAt.millisecondsSinceEpoch),
          expiresAt: Value(e.expiresAt?.millisecondsSinceEpoch),
        ),
    ]);

    // Coins: mirror locally exactly once. The server is idempotent by token, so
    // a retried verify is harmless THERE — but the local ledger would happily
    // credit again and drift the player's visible balance away from the truth.
    if (verified.coinsGranted > 0 && !verified.alreadyProcessed) {
      final already = await _db.purchasesDao.isPurchaseProcessed(token);
      if (!already) {
        await _wallet.creditServerGranted(
          // Derived from the token so a replay collides on the ledger PK.
          id: 'iap:$token',
          amount: verified.coinsGranted,
          reason: CoinReason.iapCoinPack,
        );
      }
    }

    // Bundle cosmetics: the server already owns them; mirror so they're usable
    // offline immediately rather than after the next snapshot.
    for (final id in verified.cosmeticsGranted) {
      await _db.cosmeticsDao.addOwned(id, now);
    }

    await _db.purchasesDao.markPurchaseProcessed(
      ProcessedPurchasesCompanion(
        purchaseToken: Value(token),
        productId: Value(purchase.productID),
        coinsGranted: Value(verified.coinsGranted),
        processedAt: Value(now),
      ),
    );

    AppLogger.talker.info(
      '[store] granted ${purchase.productID} '
      '(coins=${verified.coinsGranted}, '
      'entitlements=${verified.entitlements.length})',
    );
  }

  Future<void> _completeIfNeeded(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) return;
    try {
      await _iap.completePurchase(purchase);
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[store] completePurchase failed');
    }
  }

  void _resolve(String productId, PurchaseOutcome outcome) {
    final completer = _pending.remove(productId);
    if (completer != null && !completer.isCompleted) completer.complete(outcome);
  }

  @override
  Future<void> restore() async {
    // Two halves, and both matter. The server is authoritative for what's
    // owned; Play is authoritative for what hasn't been completed yet.
    try {
      final entitlements = await _api.entitlements();
      await _db.purchasesDao.replaceEntitlements([
        for (final e in entitlements)
          EntitlementsCompanion(
            entitlementKey: Value(e.key),
            productId: Value(e.productId),
            grantedAt: Value(e.grantedAt.millisecondsSinceEpoch),
            expiresAt: Value(e.expiresAt?.millisecondsSinceEpoch),
          ),
      ]);
      AppLogger.talker
          .info('[store] restored ${entitlements.length} entitlement(s)');
    } on ApiException catch (e) {
      AppLogger.talker.warning('[store] entitlement restore failed: ${e.message}');
      rethrow;
    }

    await _iap.restorePurchases();
  }

  @override
  Stream<Set<String>> watchEntitlements() =>
      watchOwned().map((owned) => {for (final e in owned) e.key});

  @override
  Future<Set<String>> currentEntitlements() async =>
      {for (final e in await currentOwned()) e.key};

  @override
  Stream<List<OwnedEntitlement>> watchOwned() =>
      _db.purchasesDao.watchEntitlements().map(_live);

  @override
  Future<List<OwnedEntitlement>> currentOwned() async =>
      _live(await _db.purchasesDao.allEntitlements());

  @override
  Future<bool> hasEntitlement(String key) async =>
      (await currentEntitlements()).contains(key);

  /// Drops anything whose subscription window has passed — the cache can
  /// legitimately outlive an expiry while the device is offline, and a lapsed
  /// pass must stop working even before the next server round-trip.
  static List<OwnedEntitlement> _live(List<EntitlementRow> rows) {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    return [
      for (final row in rows)
        if (row.expiresAt == null || row.expiresAt! > now)
          OwnedEntitlement(
            key: row.entitlementKey,
            productId: row.productId,
            expiresAt: row.expiresAt == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(row.expiresAt!,
                    isUtc: true),
          ),
    ];
  }

  @override
  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    for (final completer in _pending.values) {
      if (!completer.isCompleted) {
        completer.complete(const PurchaseFailed('The store closed.'));
      }
    }
    _pending.clear();
  }
}
