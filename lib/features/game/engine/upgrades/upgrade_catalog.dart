import 'modifiers/bounce_modifiers.dart';
import 'modifiers/fire_modifiers.dart';
import 'modifiers/ricochet_modifiers.dart';
import 'modifiers/stat_modifiers.dart';
import 'modifiers/survival_modifiers.dart';
import 'upgrade_card.dart';

/// The single registry of all upgrade cards. Copy is in the Deadbounce
/// voice — punchy, slightly western. [effect] is the plain mechanical line
/// shown on the card so the pick is a real decision, not vibes.
abstract final class UpgradeCatalog {
  static final List<UpgradeCard> all = [
    UpgradeCard(
      id: 'quickdraw',
      name: 'QUICKDRAW',
      flavor: 'Fastest trigger west of the wall.',
      effect: '-22% fire cooldown per stack',
      rarity: UpgradeRarity.common,
      iconName: 'bolt',
      maxStacks: 3,
      buildModifier: QuickdrawModifier.new,
    ),
    UpgradeCard(
      id: 'longer_sight',
      name: 'LONGER SIGHT',
      flavor: 'See one bounce further down the line.',
      effect: '+1 preview bounce per stack',
      rarity: UpgradeRarity.common,
      iconName: 'visibility',
      maxStacks: 3,
      buildModifier: LongerSightModifier.new,
    ),
    UpgradeCard(
      id: 'heavy_caliber',
      name: 'HEAVY CALIBER',
      flavor: 'Bigger slug. Harder to miss with.',
      effect: 'Bullet size ×1.4 per stack',
      rarity: UpgradeRarity.common,
      iconName: 'circle',
      maxStacks: 2,
      buildModifier: HeavyCaliberModifier.new,
    ),
    UpgradeCard(
      id: 'coin_magnet',
      name: 'COIN MAGNET',
      flavor: 'Money finds gunslingers like you.',
      effect: '+25% coins & wider pickup per stack',
      rarity: UpgradeRarity.common,
      iconName: 'paid',
      maxStacks: 3,
      buildModifier: CoinMagnetModifier.new,
    ),
    UpgradeCard(
      id: 'long_fuse',
      name: 'LONG FUSE',
      flavor: 'This slug is in no hurry to die.',
      effect: '+1.2s bullet lifetime per stack',
      rarity: UpgradeRarity.common,
      iconName: 'schedule',
      maxStacks: 2,
      buildModifier: LongFuseModifier.new,
    ),
    UpgradeCard(
      id: 'greased_lead',
      name: 'GREASED LEAD',
      flavor: 'Every wall spits it out faster.',
      effect: '+3% speed per bounce per stack',
      rarity: UpgradeRarity.common,
      iconName: 'speed',
      maxStacks: 2,
      buildModifier: GreasedLeadModifier.new,
    ),
    UpgradeCard(
      id: 'rubber_walls',
      name: 'RUBBER WALLS',
      flavor: 'Every bounce bites twice as deep.',
      effect: '+1 damage per bounce per stack',
      rarity: UpgradeRarity.rare,
      iconName: 'sports_tennis',
      maxStacks: 2,
      buildModifier: RubberWallsModifier.new,
    ),
    UpgradeCard(
      id: 'incendiary_trail',
      name: 'INCENDIARY TRAIL',
      flavor: 'Leave the floor burning behind every ricochet.',
      effect: '2+ bounce bullets drop fire (dmg per stack)',
      rarity: UpgradeRarity.rare,
      iconName: 'local_fire_department',
      maxStacks: 2,
      buildModifier: IncendiaryTrailModifier.new,
    ),
    UpgradeCard(
      id: 'magnet_rounds',
      name: 'MAGNET ROUNDS',
      flavor: 'Twice bounced, the bullet starts hunting.',
      effect: 'After bounce 2, bullets home (per stack)',
      rarity: UpgradeRarity.rare,
      iconName: 'my_location',
      maxStacks: 2,
      buildModifier: MagnetRoundsModifier.new,
    ),
    UpgradeCard(
      id: 'heart_container',
      name: 'HEART CONTAINER',
      flavor: 'One more reason to keep standing.',
      effect: '+1 max heart per stack (heals on pick)',
      rarity: UpgradeRarity.rare,
      iconName: 'favorite',
      maxStacks: 2,
      buildModifier: HeartContainerModifier.new,
    ),
    UpgradeCard(
      id: 'echo_shot',
      name: 'ECHO SHOT',
      flavor: 'Sometimes the canyon answers back.',
      effect: '10% chance of a free echo shot per stack',
      rarity: UpgradeRarity.rare,
      iconName: 'graphic_eq',
      maxStacks: 3,
      buildModifier: EchoShotModifier.new,
    ),
    UpgradeCard(
      id: 'rifling',
      name: 'RIFLING',
      flavor: 'Grooves that keep the slug dancing.',
      effect: '+2 max bounces per stack',
      rarity: UpgradeRarity.rare,
      iconName: 'track_changes',
      maxStacks: 2,
      buildModifier: RiflingModifier.new,
    ),
    UpgradeCard(
      id: 'flashpoint',
      name: 'FLASHPOINT',
      flavor: 'Work it deep and it goes off.',
      effect: 'Bounce 4 sets off a burst (dmg per stack)',
      rarity: UpgradeRarity.rare,
      iconName: 'flare',
      maxStacks: 2,
      buildModifier: FlashpointModifier.new,
    ),
    UpgradeCard(
      id: 'chain_lightning',
      name: 'CHAIN LIGHTNING',
      flavor: 'A chain kill jumps to the next mark.',
      effect: 'Chain kills fork a lethal bolt to a nearby foe',
      rarity: UpgradeRarity.rare,
      iconName: 'flash_on',
      buildModifier: ChainLightningModifier.new,
    ),
    UpgradeCard(
      id: 'split_shot',
      name: 'SPLIT SHOT',
      flavor: 'Third bounce, the slug rides two trails.',
      effect: 'On bounce 3, the bullet splits in two',
      rarity: UpgradeRarity.epic,
      iconName: 'call_split',
      buildModifier: SplitShotModifier.new,
    ),
    UpgradeCard(
      id: 'ghost_round',
      name: 'GHOST ROUND',
      flavor: 'Every fourth shot walks straight through.',
      effect: 'Every 4th shot passes through one wall',
      rarity: UpgradeRarity.epic,
      iconName: 'blur_on',
      buildModifier: GhostRoundModifier.new,
    ),
    UpgradeCard(
      id: 'last_stand',
      name: 'LAST STAND',
      flavor: 'Death blinks first. Once.',
      effect: 'Survive one fatal hit per run',
      rarity: UpgradeRarity.epic,
      iconName: 'shield',
      buildModifier: LastStandModifier.new,
    ),
    UpgradeCard(
      id: 'shrapnel',
      name: 'SHRAPNEL',
      flavor: 'One kill, three more looking for work.',
      effect: 'Armed kills spray 3 lethal shards',
      rarity: UpgradeRarity.epic,
      iconName: 'grain',
      buildModifier: ShrapnelModifier.new,
    ),
    UpgradeCard(
      id: 'fan_fire',
      name: 'FAN FIRE',
      flavor: 'Three barrels of bad news.',
      effect: 'Every shot fans into three (±14°)',
      rarity: UpgradeRarity.epic,
      iconName: 'unfold_more',
      buildModifier: FanFireModifier.new,
    ),
    UpgradeCard(
      id: 'vengeance',
      name: 'VENGEANCE',
      flavor: 'Hit me. See what it earns you.',
      effect: 'After a hit, your next shot fires a 3-round burst',
      rarity: UpgradeRarity.epic,
      iconName: 'whatshot',
      buildModifier: VengeanceModifier.new,
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
