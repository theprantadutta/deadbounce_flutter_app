import 'modifiers/bounce_modifiers.dart';
import 'modifiers/fire_modifiers.dart';
import 'modifiers/stat_modifiers.dart';
import 'modifiers/survival_modifiers.dart';
import 'upgrade_card.dart';

/// The single registry of all upgrade cards. Copy is in the Deadbounce
/// voice — punchy, slightly western.
abstract final class UpgradeCatalog {
  static final List<UpgradeCard> all = [
    UpgradeCard(
      id: 'quickdraw',
      name: 'QUICKDRAW',
      flavor: 'Fastest trigger west of the wall.',
      rarity: UpgradeRarity.common,
      iconName: 'bolt',
      maxStacks: 3,
      buildModifier: QuickdrawModifier.new,
    ),
    UpgradeCard(
      id: 'longer_sight',
      name: 'LONGER SIGHT',
      flavor: 'See one bounce further down the line.',
      rarity: UpgradeRarity.common,
      iconName: 'visibility',
      maxStacks: 3,
      buildModifier: LongerSightModifier.new,
    ),
    UpgradeCard(
      id: 'heavy_caliber',
      name: 'HEAVY CALIBER',
      flavor: 'Bigger slug. Harder to miss with.',
      rarity: UpgradeRarity.common,
      iconName: 'circle',
      maxStacks: 2,
      buildModifier: HeavyCaliberModifier.new,
    ),
    UpgradeCard(
      id: 'coin_magnet',
      name: 'COIN MAGNET',
      flavor: 'Money finds gunslingers like you.',
      rarity: UpgradeRarity.common,
      iconName: 'paid',
      maxStacks: 3,
      buildModifier: CoinMagnetModifier.new,
    ),
    UpgradeCard(
      id: 'rubber_walls',
      name: 'RUBBER WALLS',
      flavor: 'Every bounce bites twice as deep.',
      rarity: UpgradeRarity.rare,
      iconName: 'sports_tennis',
      maxStacks: 2,
      buildModifier: RubberWallsModifier.new,
    ),
    UpgradeCard(
      id: 'incendiary_trail',
      name: 'INCENDIARY TRAIL',
      flavor: 'Leave the floor burning behind every ricochet.',
      rarity: UpgradeRarity.rare,
      iconName: 'local_fire_department',
      maxStacks: 2,
      buildModifier: IncendiaryTrailModifier.new,
    ),
    UpgradeCard(
      id: 'magnet_rounds',
      name: 'MAGNET ROUNDS',
      flavor: 'Twice bounced, the bullet starts hunting.',
      rarity: UpgradeRarity.rare,
      iconName: 'my_location',
      maxStacks: 2,
      buildModifier: MagnetRoundsModifier.new,
    ),
    UpgradeCard(
      id: 'heart_container',
      name: 'HEART CONTAINER',
      flavor: 'One more reason to keep standing.',
      rarity: UpgradeRarity.rare,
      iconName: 'favorite',
      maxStacks: 2,
      buildModifier: HeartContainerModifier.new,
    ),
    UpgradeCard(
      id: 'echo_shot',
      name: 'ECHO SHOT',
      flavor: 'Sometimes the canyon answers back.',
      rarity: UpgradeRarity.rare,
      iconName: 'graphic_eq',
      maxStacks: 3,
      buildModifier: EchoShotModifier.new,
    ),
    UpgradeCard(
      id: 'split_shot',
      name: 'SPLIT SHOT',
      flavor: 'Third bounce, the slug rides two trails.',
      rarity: UpgradeRarity.epic,
      iconName: 'call_split',
      buildModifier: SplitShotModifier.new,
    ),
    UpgradeCard(
      id: 'ghost_round',
      name: 'GHOST ROUND',
      flavor: 'Every fourth shot walks straight through.',
      rarity: UpgradeRarity.epic,
      iconName: 'blur_on',
      buildModifier: GhostRoundModifier.new,
    ),
    UpgradeCard(
      id: 'last_stand',
      name: 'LAST STAND',
      flavor: 'Death blinks first. Once.',
      rarity: UpgradeRarity.epic,
      iconName: 'shield',
      buildModifier: LastStandModifier.new,
    ),
  ];

  static UpgradeCard byId(String id) => all.firstWhere((c) => c.id == id);

  /// Null when [id] is unknown — use at boundaries that read persisted/meta
  /// ids that may have been removed from the catalog, so a stale id can't
  /// crash run start with a [StateError].
  static UpgradeCard? tryById(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return null;
  }
}
