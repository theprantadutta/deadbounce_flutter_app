import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import 'package:deadbounce_flutter_app/features/cosmetics/domain/cosmetic_catalog.dart';
import 'package:deadbounce_flutter_app/features/game/engine/upgrades/upgrade_catalog.dart';
import 'package:deadbounce_flutter_app/features/meta/domain/meta_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => GameBalance.I.resetToDefaults());

  group('Gunsmith perks must not sell a level that does nothing', () {
    // Perks that map onto an upgrade card are capped by that card's maxStacks
    // (RunModifiers.addPermanent respects it), so a level sold beyond the cap
    // takes coins and changes nothing. This mirrors the mapping in
    // GameSessionCubit._buildLoadout — if that changes, change this too.
    const perkToCard = {
      MetaCatalog.reinforcedHeart: 'heart_container',
      MetaCatalog.quickHands: 'quickdraw',
      MetaCatalog.keenEye: 'longer_sight',
      MetaCatalog.luckyStrike: 'coin_magnet',
    };

    test('no card-mapped perk exceeds its card maxStacks', () {
      final cardStacks = {
        for (final c in UpgradeCatalog.all) c.id: c.maxStacks,
      };

      perkToCard.forEach((perkId, cardId) {
        final perk = MetaCatalog.byId(perkId);
        final cap = cardStacks[cardId];
        expect(cap, isNotNull, reason: '$cardId missing from the catalog');
        expect(
          perk.maxLevel,
          lessThanOrEqualTo(cap!),
          reason: '${perk.name} sells ${perk.maxLevel} levels but $cardId '
              'only stacks $cap times — the top level would be a no-op.',
        );
      });
    });

    test('every perk costs more for each successive level', () {
      for (final perk in MetaCatalog.all) {
        for (var level = 1; level < perk.maxLevel; level++) {
          expect(
            perk.costForLevel(level),
            greaterThan(perk.costForLevel(level - 1)),
            reason: '${perk.name} level ${level + 1} is not dearer than $level',
          );
        }
      }
    });
  });

  group('Outfitter depth', () {
    test('cosmetic ids are unique', () {
      final ids = CosmeticCatalog.all.map((c) => c.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every slot still has exactly one free default', () {
      // defaultFor() does a firstWhere on isFree — two free items in a slot
      // would make the default arbitrary, none would throw.
      for (final slot in CosmeticSlot.values) {
        final free =
            CosmeticCatalog.all.where((c) => c.slot == slot && c.isFree);
        expect(free.length, 1, reason: 'slot ${slot.name}');
      }
    });

    test('the supporter trail is grant-only, so it is NOT free stock', () {
      final supporter = CosmeticCatalog.byId('trail_supporter');
      expect(supporter.grantOnly, isTrue);
      // The trap this guards: cost 0 alone would mean "everybody owns it".
      expect(supporter.cost, 0);
      expect(supporter.isFree, isFalse);
    });

    test('every slot has a legendary-tier item to chase', () {
      for (final slot in CosmeticSlot.values) {
        final dearest = CosmeticCatalog.all
            .where((c) => c.slot == slot)
            .map((c) => c.cost)
            .reduce((a, b) => a > b ? a : b);
        expect(dearest, greaterThanOrEqualTo(1500), reason: slot.name);
      }
    });
  });

  group('total permanent sink', () {
    int cosmeticSink() => CosmeticCatalog.all
        .where((c) => !c.grantOnly)
        .fold(0, (sum, c) => sum + c.cost);

    int gunsmithSink() => MetaCatalog.all.fold(
          0,
          (sum, p) => sum +
              List.generate(p.maxLevel, (i) => p.costForLevel(i))
                  .fold(0, (a, b) => a + b),
        );

    test('is deep enough that a player cannot own everything in a few runs',
        () {
      // Phase 3's whole point. Before it the ceiling was 7,800 against 5,770
      // from achievements alone — everything permanent was owned in roughly
      // 15-20 runs, which is why selling coins would have been selling a
      // two-hour shortcut into a dead shop.
      final total = cosmeticSink() + gunsmithSink();
      expect(total, greaterThan(20000),
          reason: 'permanent sink is only $total');
    });
  });

  group('in-run continue ladder', () {
    test('escalates, so a deep run cannot be cheaply bought back', () {
      final costs = GameBalance.I.economy.continueRunCosts;
      expect(costs, isNotEmpty);
      for (var i = 1; i < costs.length; i++) {
        expect(costs[i], greaterThan(costs[i - 1]));
      }
    });

    test('is capped — an unlimited buy-back would void the leaderboard', () {
      expect(GameBalance.I.economy.continueRunCosts.length, lessThanOrEqualTo(5));
    });

    test('stays under the backend CoinTxnProcessor continueRun ceiling', () {
      // The server rejects a continueRun spend beyond 5,000 as implausible;
      // pricing past it would make the sync event permanently rejected.
      for (final cost in GameBalance.I.economy.continueRunCosts) {
        expect(cost, lessThanOrEqualTo(5000));
      }
    });

    test('resetToDefaults restores the ladder (panel edits must not leak)', () {
      GameBalance.I.economy.continueRunCosts = [1];
      GameBalance.I.resetToDefaults();
      expect(GameBalance.I.economy.continueRunCosts, [500, 1200, 2500]);
    });
  });

  group('shop prices stay inside the backend sanity ceilings', () {
    test('no cosmetic or perk level exceeds the shopPurchase bound', () {
      for (final c in CosmeticCatalog.all) {
        expect(c.cost, lessThanOrEqualTo(50000), reason: c.id);
      }
      for (final p in MetaCatalog.all) {
        for (var level = 0; level < p.maxLevel; level++) {
          expect(p.costForLevel(level), lessThanOrEqualTo(50000),
              reason: '${p.id} L${level + 1}');
        }
      }
    });
  });
}
