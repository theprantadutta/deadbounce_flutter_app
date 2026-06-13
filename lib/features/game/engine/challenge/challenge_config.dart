import '../waves/wave_definition.dart';

/// Run-shaping config a daily challenge applies. All fields are read by
/// DeadbounceGame and its systems; a null/default field means "normal".
class ChallengeConfig {
  const ChallengeConfig({
    this.forcedEnemyType,
    this.extraWallDamage = 0,
    this.startingHearts,
    this.scoreMultiplier = 1,
    this.randomUpgrades = false,
  });

  /// Spawn only this enemy type (Wardens on boss waves still appear).
  final EnemyType? forcedEnemyType;

  /// Added to every bullet's damage-per-bounce for the whole run.
  final int extraWallDamage;

  /// Override the player's starting/max hearts.
  final int? startingHearts;

  /// Final score (and HUD) multiplied by this.
  final double scoreMultiplier;

  /// Upgrades are drawn and auto-applied at random — no picking.
  final bool randomUpgrades;
}
