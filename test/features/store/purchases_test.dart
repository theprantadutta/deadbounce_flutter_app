import 'package:deadbounce_flutter_app/core/database/app_database.dart';
import 'package:deadbounce_flutter_app/core/sync/sync_outbox_writer.dart';
import 'package:deadbounce_flutter_app/features/economy/data/repositories/wallet_repository_impl.dart';
import 'package:deadbounce_flutter_app/features/economy/domain/entities/coin_transaction.dart';
import 'package:deadbounce_flutter_app/features/store/domain/store_catalog.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late WalletRepositoryImpl wallet;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    wallet = WalletRepositoryImpl(db: db, outboxWriter: SyncOutboxWriter(db));
  });

  tearDown(() => db.close());

  group('IAP coins are credited locally but NEVER synced', () {
    // The load-bearing rule of Phase 2. The backend credits its own ledger
    // during receipt verification and REJECTS `iapCoinPack` over the sync
    // channel — so if the client ever enqueued one, the batch would be
    // rejected and, worse, a client that COULD sync it would be minting
    // paid currency for free.
    test('creditServerGranted writes the ledger row with no outbox event',
        () async {
      await wallet.creditServerGranted(
        id: 'iap:token-abc',
        amount: 5500,
        reason: CoinReason.iapCoinPack,
      );

      expect(await db.coinLedgerDao.getBalance(), 5500);
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    });

    test('a normal transaction DOES enqueue — proving the contrast', () async {
      await wallet.addTransaction(amount: -300, reason: CoinReason.shopPurchase);

      expect(await db.coinLedgerDao.getBalance(), -300);
      expect(await db.select(db.syncOutbox).get(), hasLength(1));
    });

    test('the ledger id is derived from the purchase token, so a replay '
        'collides instead of double-crediting', () async {
      await wallet.creditServerGranted(
        id: 'iap:token-abc',
        amount: 1000,
        reason: CoinReason.iapCoinPack,
      );

      // Same token → same id → primary-key collision rather than free coins.
      await expectLater(
        wallet.creditServerGranted(
          id: 'iap:token-abc',
          amount: 1000,
          reason: CoinReason.iapCoinPack,
        ),
        throwsA(anything),
      );

      expect(await db.coinLedgerDao.getBalance(), 1000);
    });
  });

  group('processed-purchase guard', () {
    test('records a token so the coin mirror runs exactly once', () async {
      expect(await db.purchasesDao.isPurchaseProcessed('tok-1'), isFalse);

      await db.purchasesDao.markPurchaseProcessed(
        const ProcessedPurchasesCompanion(
          purchaseToken: Value('tok-1'),
          productId: Value('db_coins_medium'),
          coinsGranted: Value(5500),
          processedAt: Value(123),
        ),
      );

      expect(await db.purchasesDao.isPurchaseProcessed('tok-1'), isTrue);
      expect(await db.purchasesDao.isPurchaseProcessed('tok-2'), isFalse);
    });

    test('re-marking the same token is idempotent', () async {
      const row = ProcessedPurchasesCompanion(
        purchaseToken: Value('tok-1'),
        productId: Value('db_coins_small'),
        coinsGranted: Value(1000),
        processedAt: Value(1),
      );
      await db.purchasesDao.markPurchaseProcessed(row);
      await db.purchasesDao.markPurchaseProcessed(row);

      expect(await db.purchasesDao.allProcessedPurchases(), hasLength(1));
    });
  });

  group('entitlement cache', () {
    Future<void> seed(List<(String key, int? expiresAt)> rows) =>
        db.purchasesDao.replaceEntitlements([
          for (final (key, expiresAt) in rows)
            EntitlementsCompanion(
              entitlementKey: Value(key),
              productId: const Value('db_remove_ads'),
              grantedAt: const Value(1000),
              expiresAt: Value(expiresAt),
            ),
        ]);

    test('replace REMOVES entitlements the server no longer reports', () async {
      // The refund/chargeback/lapsed-subscription path. Merging instead of
      // replacing would leave a refunded purchase working forever.
      await seed([('no_ads', null), ('bounty_pass', 99999999999)]);
      expect(await db.purchasesDao.allEntitlements(), hasLength(2));

      await seed([('no_ads', null)]);

      final remaining = await db.purchasesDao.allEntitlements();
      expect(remaining, hasLength(1));
      expect(remaining.single.entitlementKey, 'no_ads');
    });

    test('replacing with an empty set clears everything', () async {
      await seed([('no_ads', null)]);
      await db.purchasesDao.replaceEntitlements([]);

      expect(await db.purchasesDao.allEntitlements(), isEmpty);
    });

    test('a permanent entitlement stores a null expiry', () async {
      await seed([('no_ads', null)]);
      expect((await db.purchasesDao.allEntitlements()).single.expiresAt, isNull);
    });
  });

  group('StoreCatalog', () {
    // These ids are the contract with BOTH the Play Console and the server's
    // ProductDefinitions. A typo here means a player pays and gets nothing:
    // verify rejects the SKU as unknown.
    test('every product id is unique', () {
      final ids = StoreCatalog.all.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('productIds covers the whole shelf', () {
      expect(StoreCatalog.productIds.length, StoreCatalog.all.length);
    });

    test('byId finds every catalog entry and rejects unknown SKUs', () {
      for (final product in StoreCatalog.all) {
        expect(StoreCatalog.byId(product.id), isNotNull);
      }
      expect(StoreCatalog.byId('db_not_a_real_sku'), isNull);
    });

    test('coin packs are consumable — otherwise they can only be bought once',
        () {
      for (final pack in StoreCatalog.coinPacks) {
        expect(pack.kind, StoreProductKind.consumable, reason: pack.id);
        expect(pack.coins, greaterThan(0), reason: pack.id);
      }
    });

    test('entitlement products are NOT consumable', () {
      for (final product in StoreCatalog.all) {
        if (product.entitlementKey == null) continue;
        expect(product.kind, isNot(StoreProductKind.consumable),
            reason: product.id);
      }
    });

    test('coin packs get better per tier (the ladder must reward going up)',
        () {
      final coins = StoreCatalog.coinPacks.map((p) => p.coins).toList();
      for (var i = 1; i < coins.length; i++) {
        expect(coins[i], greaterThan(coins[i - 1]));
      }
    });

    // The drift canary. These ids are the join key between the Play Console,
    // ProductDefinitions.cs and this catalog. If someone adds a SKU to one side
    // only, a player pays and verification rejects it as an unknown product —
    // so make editing this list a deliberate act.
    test('the SKU set matches the server catalog (ProductDefinitions.cs)', () {
      expect(
        StoreCatalog.productIds,
        {
          'db_remove_ads',
          'db_supporter_pack',
          'db_bounty_pass',
          'db_coins_small',
          'db_coins_medium',
          'db_coins_large',
          'db_coins_huge',
        },
        reason: 'Update ProductDefinitions.cs and the Play Console together.',
      );
    });
  });

  group('subscriptions', () {
    test('the bounty pass is a subscription with an entitlement', () {
      expect(StoreCatalog.bountyPass.kind, StoreProductKind.subscription);
      expect(StoreCatalog.bountyPass.entitlementKey, Entitlements.bountyPass);
      // A subscription must never be consumable — Play would let it be
      // re-bought while already active.
      expect(StoreCatalog.bountyPass.kind, isNot(StoreProductKind.consumable));
    });

    test('the manage URL carries both the SKU and the package', () {
      final url = StoreCatalog.manageUrlFor(StoreCatalog.bountyPass);

      // Play policy requires an unobstructed cancel route; a malformed deep
      // link lands the player on a generic page instead of this subscription.
      expect(url, contains('play.google.com/store/account/subscriptions'));
      expect(url, contains('sku=db_bounty_pass'));
      expect(url, contains('package=com.pranta.deadbounce'));
    });

    test('an expired entitlement is still STORED — filtering is a read concern',
        () async {
      // The cache can legitimately outlive an expiry while offline. The row
      // stays; the repository drops it on read, so a lapsed pass stops working
      // even before the next server round-trip.
      final past = DateTime.utc(2020).millisecondsSinceEpoch;
      await db.purchasesDao.replaceEntitlements([
        EntitlementsCompanion(
          entitlementKey: const Value('bounty_pass'),
          productId: const Value('db_bounty_pass'),
          grantedAt: const Value(1000),
          expiresAt: Value(past),
        ),
      ]);

      final rows = await db.purchasesDao.allEntitlements();
      expect(rows, hasLength(1));
      expect(rows.single.expiresAt, past);
    });
  });
}
