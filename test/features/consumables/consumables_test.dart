import 'dart:convert';

import 'package:deadbounce_flutter_app/core/database/app_database.dart';
import 'package:deadbounce_flutter_app/core/sync/sync_event.dart';
import 'package:deadbounce_flutter_app/core/sync/sync_outbox_writer.dart';
import 'package:deadbounce_flutter_app/features/consumables/data/repositories/consumables_repository_impl.dart';
import 'package:deadbounce_flutter_app/features/consumables/domain/consumable_catalog.dart';
import 'package:deadbounce_flutter_app/features/consumables/domain/consumable_loadout.dart';
import 'package:deadbounce_flutter_app/features/consumables/domain/repositories/consumables_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ConsumablesRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ConsumablesRepositoryImpl(db: db, outboxWriter: SyncOutboxWriter(db));
  });

  tearDown(() => db.close());

  Future<void> giveCoins(int amount) => db.coinLedgerDao.insertTransaction(
        CoinLedgerRow(
          id: 'seed-$amount',
          amount: amount,
          reason: 'adjustment',
          runId: null,
          createdAt: 1,
        ),
      );

  final heart = ConsumableCatalog.byId(ConsumableCatalog.extraHeart);

  group('buying', () {
    test('spends coins, adds stock and queues the aggregate atomically',
        () async {
      await giveCoins(1000);

      await repo.buy(heart);

      expect(await db.coinLedgerDao.getBalance(), 1000 - heart.cost);
      expect((await repo.stock())[heart.id], 1);

      final outbox = await db.select(db.syncOutbox).get();
      final types = outbox.map((e) => e.entityType).toSet();
      // The coin spend and the stock BOTH have to sync — the spend alone would
      // mean the player paid and the server never learned they own anything.
      expect(types, contains(SyncEntityType.coinTxn.name));
      expect(types, contains(SyncEntityType.consumableState.name));
    });

    test('refuses when the player cannot afford it, changing nothing',
        () async {
      await giveCoins(10);

      await expectLater(
        repo.buy(heart),
        throwsA(isA<ConsumablePurchaseException>()),
      );

      expect(await db.coinLedgerDao.getBalance(), 10);
      expect(await repo.stock(), isEmpty);
      // The whole transaction rolled back, so no half-written outbox row.
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    });

    test('stacks repeat purchases', () async {
      await giveCoins(5000);
      await repo.buy(heart);
      await repo.buy(heart);

      expect((await repo.stock())[heart.id], 2);
    });
  });

  group('consuming', () {
    test('spends stock and returns the combined effect', () async {
      await giveCoins(5000);
      await repo.buy(heart);
      await repo.buy(ConsumableCatalog.byId(ConsumableCatalog.coinDoubler));

      final loadout = await repo.consume(
        [ConsumableCatalog.extraHeart, ConsumableCatalog.coinDoubler],
      );

      expect(loadout.bonusHearts, 1);
      expect(loadout.coinMultiplier, 2.0);

      final stock = await repo.stock();
      expect(stock[ConsumableCatalog.extraHeart], 0);
      expect(stock[ConsumableCatalog.coinDoubler], 0);
    });

    test('skips ids the player does not hold rather than throwing', () async {
      // A stale picker selection must never stop a run from starting.
      final loadout = await repo.consume([ConsumableCatalog.extraHeart]);

      expect(loadout.isEmpty, isTrue);
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    });

    test('ignores unknown ids', () async {
      final loadout = await repo.consume(['not_a_real_item']);
      expect(loadout.isEmpty, isTrue);
    });

    test('never drives stock negative', () async {
      await giveCoins(5000);
      await repo.buy(heart);

      await repo.consume([heart.id]);
      await repo.consume([heart.id]); // already spent

      expect((await repo.stock())[heart.id], 0);
    });

    test('syncs zero counts, so "spent them all" is distinguishable from '
        '"unchanged"', () async {
      await giveCoins(5000);
      await repo.buy(heart);
      await repo.consume([heart.id]);

      final rows = await db.select(db.syncOutbox).get();
      final state = rows
          .where((e) => e.entityType == SyncEntityType.consumableState.name)
          .last;
      final payload = jsonDecode(state.payload) as Map<String, dynamic>;
      final stock = payload['stock'] as Map<String, dynamic>;

      // The server REPLACES the aggregate, so omitting a zeroed item would
      // look identical to not mentioning it — and the stock would never drop.
      expect(stock[heart.id], 0);
      expect(payload['updated_at'], isA<int>());
    });
  });

  group('ConsumableLoadout', () {
    test('empty by default', () {
      expect(ConsumableLoadout.empty.isEmpty, isTrue);
      expect(ConsumableLoadout.empty.coinMultiplier, 1.0);
    });

    test('folds each id to its documented effect', () {
      final all = ConsumableLoadout.fromIds(
        ConsumableCatalog.all.map((c) => c.id),
      );

      expect(all.bonusHearts, 1);
      expect(all.freeRareCard, isTrue);
      expect(all.coinMultiplier, 2.0);
      expect(all.freeRerolls, 1);
    });

    test('unknown ids contribute nothing', () {
      expect(ConsumableLoadout.fromIds(['nope']).isEmpty, isTrue);
    });
  });

  group('catalog', () {
    test('ids are unique', () {
      final ids = ConsumableCatalog.all.map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every item has a real coin cost — a free consumable is not a sink',
        () {
      for (final item in ConsumableCatalog.all) {
        expect(item.cost, greaterThan(0), reason: item.id);
      }
    });

    test('costs stay under the backend shopPurchase ceiling', () {
      // Consumables ride the shopPurchase coin reason, which the server bounds
      // at 50,000; pricing past it would make the spend permanently rejected.
      for (final item in ConsumableCatalog.all) {
        expect(item.cost, lessThanOrEqualTo(50000), reason: item.id);
      }
    });

    test('the per-run cap is small enough to still be a decision', () {
      expect(ConsumableCatalog.maxEquipped, lessThan(ConsumableCatalog.all.length));
    });
  });

  group('remembered loadout', () {
    test('is empty before anything is saved', () async {
      expect(await repo.lastSelection(), isEmpty);
    });

    test('round-trips a saved selection', () async {
      await giveCoins(5000);
      await repo.buy(heart);
      await repo.saveSelection([heart.id]);

      expect(await repo.lastSelection(), [heart.id]);
    });

    test('drops items no longer in stock', () async {
      // Offering an item that would then be skipped at run start looks
      // exactly like the item being eaten.
      await giveCoins(5000);
      await repo.buy(heart);
      await repo.saveSelection([heart.id]);
      await repo.consume([heart.id]);

      expect(await repo.lastSelection(), isEmpty);
    });

    test('drops ids that left the catalog', () async {
      await repo.saveSelection(['a_removed_item']);
      expect(await repo.lastSelection(), isEmpty);
    });

    test('never returns more than a run can carry', () async {
      await giveCoins(20000);
      for (final item in ConsumableCatalog.all) {
        await repo.buy(item);
      }
      await repo.saveSelection(ConsumableCatalog.all.map((c) => c.id).toList());

      expect(
        (await repo.lastSelection()).length,
        lessThanOrEqualTo(ConsumableCatalog.maxEquipped),
      );
    });

    test('an empty save clears it', () async {
      await giveCoins(5000);
      await repo.buy(heart);
      await repo.saveSelection([heart.id]);
      await repo.saveSelection([]);

      expect(await repo.lastSelection(), isEmpty);
    });
  });
}
