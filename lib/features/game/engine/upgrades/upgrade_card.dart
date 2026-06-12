import 'upgrade_modifier.dart';

enum UpgradeRarity { common, rare, epic }

extension UpgradeRarityWeight on UpgradeRarity {
  /// Relative draw weight of the rarity tier.
  int get weight => switch (this) {
        UpgradeRarity.common => 100,
        UpgradeRarity.rare => 40,
        UpgradeRarity.epic => 12,
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
    this.maxStacks = 1,
  });

  final String id;
  final String name;

  /// Punchy one-liner in the Deadbounce voice.
  final String flavor;
  final UpgradeRarity rarity;
  final String iconName;
  final int maxStacks;
  final UpgradeModifier Function() buildModifier;
}
