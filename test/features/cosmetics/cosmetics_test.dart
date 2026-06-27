import 'dart:convert';

import 'package:deadbounce_flutter_app/core/database/app_database.dart';
import 'package:deadbounce_flutter_app/core/sync/sync_outbox_writer.dart';
import 'package:deadbounce_flutter_app/features/cosmetics/data/repositories/cosmetics_repository_impl.dart';
import 'package:deadbounce_flutter_app/features/cosmetics/domain/cosmetic_catalog.dart';
import 'package:deadbounce_flutter_app/features/cosmetics/domain/repositories/cosmetics_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CosmeticSlot.wireName', () {
    test('emits snake_case slot keys for the wire', () {
      expect(CosmeticSlot.bulletTrail.wireName, 'bullet_trail');
      expect(CosmeticSlot.gunslinger.wireName, 'gunslinger');
      expect(CosmeticSlot.arenaTheme.wireName, 'arena_theme');
    });
  });

  group('CosmeticsRepositoryImpl (offline-first, no network)', () {
    late AppDatabase db;
    late CosmeticsRepositoryImpl repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = CosmeticsRepositoryImpl(db: db, outboxWriter: SyncOutboxWriter(db));
    });
    tearDown(() => db.close());

    Future<void> seedCoins(int amount) =>
        db.coinLedgerDao.insertTransaction(CoinLedgerRow(
          id: 'seed',
          amount: amount,
          reason: 'adjustment',
          runId: null,
          createdAt: 1,
        ));

    // trail_ice: paid (200), slot bulletTrail.
    final paidTrail = CosmeticCatalog.byId('trail_ice');

    Future<List<SyncOutboxRow>> outbox() => db.select(db.syncOutbox).get();
    Map<String, dynamic> payloadOf(SyncOutboxRow r) =>
        jsonDecode(r.payload) as Map<String, dynamic>;

    test('purchase spends coins and emits coinTxn + cosmeticState', () async {
      await seedCoins(500);
      await repo.purchase(paidTrail);

      expect(await db.coinLedgerDao.getBalance(), 300); // 500 - 200

      final rows = await outbox();
      final coin = rows.firstWhere((e) => e.entityType == 'coinTxn');
      expect(payloadOf(coin)['reason'], 'shopPurchase');
      expect(payloadOf(coin)['amount'], -200);

      final state = rows.firstWhere((e) => e.entityType == 'cosmeticState');
      expect((payloadOf(state)['owned'] as List), contains('trail_ice'));

      expect(await db.cosmeticsDao.isOwned('trail_ice'), isTrue);
    });

    test('equip emits cosmeticState with snake_case slot keys', () async {
      await seedCoins(500);
      await repo.purchase(paidTrail);
      await repo.equip(paidTrail);

      final states =
          (await outbox()).where((e) => e.entityType == 'cosmeticState').toList();
      final equipped = payloadOf(states.last)['equipped'] as Map<String, dynamic>;
      expect(equipped.containsKey('bullet_trail'), isTrue);
      expect(equipped['bullet_trail'], 'trail_ice');
    });

    test('purchase rejects when unaffordable — no spend', () async {
      await seedCoins(50);
      await expectLater(
        repo.purchase(paidTrail),
        throwsA(isA<CosmeticPurchaseException>()),
      );
      expect(await db.coinLedgerDao.getBalance(), 50);
    });

    test('free defaults are buy-free and equip without ownership', () async {
      final freeSkin = CosmeticCatalog.defaultFor(CosmeticSlot.gunslinger);
      await repo.purchase(freeSkin); // no-op, must not throw or charge
      await repo.equip(freeSkin); // allowed without an owned row

      final loadout = await repo.loadout();
      expect(loadout.gunslinger.id, freeSkin.id);
    });
  });
}
