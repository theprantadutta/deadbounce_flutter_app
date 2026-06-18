import 'package:deadbounce_flutter_app/core/database/app_database.dart';
import 'package:deadbounce_flutter_app/core/sync/sync_outbox_writer.dart';
import 'package:deadbounce_flutter_app/features/game/engine/combat/bullet_stats.dart';
import 'package:deadbounce_flutter_app/features/game/engine/upgrades/run_modifiers.dart';
import 'package:deadbounce_flutter_app/features/game/engine/upgrades/upgrade_catalog.dart';
import 'package:deadbounce_flutter_app/features/meta/data/repositories/meta_repository_impl.dart';
import 'package:deadbounce_flutter_app/features/meta/domain/meta_catalog.dart';
import 'package:deadbounce_flutter_app/features/meta/domain/repositories/meta_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MetaPerk', () {
    test('costForLevel scales with owned level', () {
      final perk = MetaCatalog.byId(MetaCatalog.quickHands); // base 100, +160
      expect(perk.costForLevel(0), 100);
      expect(perk.costForLevel(1), 260);
      expect(perk.costForLevel(2), 420);
    });
  });

  group('permanent perks (RunModifiers.addPermanent)', () {
    test('stacks like a pick but is NOT counted as a wave pick', () {
      final mods = RunModifiers();
      final heart = UpgradeCatalog.byId('heart_container');

      mods.addPermanent(heart);
      mods.addPermanent(heart);
      expect(mods.stacksOf('heart_container'), 2);
      expect(mods.pickedIds, isEmpty);

      // A real pick on top still stacks AND is recorded as a pick.
      mods.add(heart);
      expect(mods.stacksOf('heart_container'), 3);
      expect(mods.pickedIds, ['heart_container']);
    });

    test('perk-mapped cards never raise bullet damage (core hook intact)', () {
      final base = BulletStats.base().damagePerBounce;
      for (final id in const [
        'heart_container',
        'quickdraw',
        'longer_sight',
        'coin_magnet',
      ]) {
        final mods = RunModifiers()..addPermanent(UpgradeCatalog.byId(id));
        expect(
          mods.effectiveBulletStats().damagePerBounce,
          base,
          reason: '$id must not add flat bullet damage',
        );
      }
    });
  });

  group('MetaRepository.purchase', () {
    late AppDatabase db;
    late SyncOutboxWriter writer;
    late MetaRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      writer = SyncOutboxWriter(db);
      repo = MetaRepositoryImpl(db: db, outboxWriter: writer);
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

    test('spends coins, raises the level, and queues the sync — atomically',
        () async {
      await seedCoins(1000);
      final perk = MetaCatalog.byId(MetaCatalog.reinforcedHeart); // 150

      await repo.purchase(perk);

      expect((await repo.ownedLevels())[perk.id], 1);
      expect(await db.coinLedgerDao.getBalance(), 850);

      final ledger = await db.coinLedgerDao.recentTransactions();
      expect(
        ledger.any((r) => r.reason == 'shopPurchase' && r.amount == -150),
        isTrue,
      );
      final outbox = await db.select(db.syncOutbox).get();
      expect(outbox.any((e) => e.entityType == 'coinTxn'), isTrue);
    });

    test('rejects when broke — no spend, no level', () async {
      await seedCoins(50);
      final perk = MetaCatalog.byId(MetaCatalog.reinforcedHeart); // 150

      await expectLater(
        repo.purchase(perk),
        throwsA(isA<MetaPurchaseException>()),
      );
      expect(await db.coinLedgerDao.getBalance(), 50);
      expect((await repo.ownedLevels())[perk.id], isNull);
    });

    test('rejects when already maxed', () async {
      await seedCoins(100000);
      final perk = MetaCatalog.byId(MetaCatalog.secondWind); // maxLevel 1

      await repo.purchase(perk);
      await expectLater(
        repo.purchase(perk),
        throwsA(isA<MetaPurchaseException>()),
      );
      expect((await repo.ownedLevels())[perk.id], 1);
    });
  });
}
