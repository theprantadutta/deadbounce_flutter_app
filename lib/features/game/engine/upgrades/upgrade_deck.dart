import '../game_rng.dart';
import 'run_modifiers.dart';
import 'upgrade_card.dart';
import 'upgrade_catalog.dart';

/// Weighted draw of the 3 wave-clear choices. Card weight = its rarity's
/// tier weight; cards at max stacks are excluded; sampling is without
/// replacement.
abstract final class UpgradeDeck {
  static List<UpgradeCard> draw3(GameRng rng, RunModifiers owned) {
    final pool = UpgradeCatalog.all
        .where((c) => owned.stacksOf(c.id) < c.maxStacks)
        .toList();

    final picks = <UpgradeCard>[];
    while (picks.length < 3 && pool.isNotEmpty) {
      final totalWeight =
          pool.fold(0, (sum, c) => sum + c.rarity.weight);
      var roll = rng.nextDouble() * totalWeight;

      UpgradeCard chosen = pool.last;
      for (final card in pool) {
        roll -= card.rarity.weight;
        if (roll <= 0) {
          chosen = card;
          break;
        }
      }

      picks.add(chosen);
      pool.remove(chosen);
    }

    return picks;
  }
}
