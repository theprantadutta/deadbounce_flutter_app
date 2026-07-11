import '../game_rng.dart';
import 'run_modifiers.dart';
import 'upgrade_card.dart';
import 'upgrade_catalog.dart';

/// Weighted draw of the 3 wave-clear choices. Card weight = its rarity's
/// tier weight; cards at max stacks are excluded; sampling is without
/// replacement.
abstract final class UpgradeDeck {
  /// Draws 3 choices. When [guaranteeRarePlus] is set (the pity rule — the
  /// game turns it on after a couple of all-common drafts) and the weighted
  /// draw came up all common, one pick is swapped for a random available
  /// rare/epic so the exciting cards can't stay invisible for long.
  static List<UpgradeCard> draw3(
    GameRng rng,
    RunModifiers owned, {
    bool guaranteeRarePlus = false,
    Set<String>? unlockedCardIds,
  }) {
    bool available(UpgradeCard c) =>
        owned.stacksOf(c.id) < c.maxStacks &&
        (unlockedCardIds == null || unlockedCardIds.contains(c.id));

    final pool = UpgradeCatalog.all.where(available).toList();

    final picks = <UpgradeCard>[];
    while (picks.length < 3 && pool.isNotEmpty) {
      picks.add(_weightedRemove(pool, rng));
    }

    if (guaranteeRarePlus &&
        picks.isNotEmpty &&
        picks.every((c) => c.rarity == UpgradeRarity.common)) {
      final rares = UpgradeCatalog.all
          .where((c) =>
              c.rarity != UpgradeRarity.common &&
              available(c) &&
              !picks.contains(c))
          .toList();
      if (rares.isNotEmpty) {
        picks[picks.length - 1] = _weightedRemove(rares, rng);
      }
    }

    return picks;
  }

  /// Weighted pick from [pool] (by rarity weight), removing and returning it.
  static UpgradeCard _weightedRemove(List<UpgradeCard> pool, GameRng rng) {
    final totalWeight = pool.fold(0, (sum, c) => sum + c.rarity.weight);
    var roll = rng.nextDouble() * totalWeight;
    UpgradeCard chosen = pool.last;
    for (final card in pool) {
      roll -= card.rarity.weight;
      if (roll <= 0) {
        chosen = card;
        break;
      }
    }
    pool.remove(chosen);
    return chosen;
  }
}
