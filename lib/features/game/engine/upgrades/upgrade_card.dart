import 'upgrade_modifier.dart';

enum UpgradeRarity { common, rare, epic }

extension UpgradeRarityWeight on UpgradeRarity {
  /// Relative draw weight of the rarity tier. Phase 3 pass: rares/epics were
  /// too invisible (40/12) next to commons — bumped so the exciting cards
  /// actually show up (paired with the pity rule in [UpgradeDeck]).
  int get weight => switch (this) {
        UpgradeRarity.common => 100,
        UpgradeRarity.rare => 50,
        UpgradeRarity.epic => 22,
      };
}

/// Card metadata + the factory for its behavior. The icon name is a
/// Material icon resolved in the presentation layer — the engine stays
/// free of Flutter imports.
class UpgradeCard {
  const UpgradeCard({
    required this.id,
    required this.name,
    required this.flavor,
    required this.rarity,
    required this.iconName,
    required this.buildModifier,
    this.effect = '',
    this.maxStacks = 1,
  });

  final String id;
  final String name;

  /// Punchy one-liner in the Deadbounce voice.
  final String flavor;

  /// Plain-language mechanical effect (shown on the card so the progression
  /// decision isn't vibes-only). Per-stack where it stacks.
  final String effect;
  final UpgradeRarity rarity;
  final String iconName;
  final int maxStacks;
  final UpgradeModifier Function() buildModifier;
}
