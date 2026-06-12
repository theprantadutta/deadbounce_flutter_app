/// Every gameplay constant in one place. Balance passes touch this file
/// and nothing else; final shipped values are documented in CLAUDE.md.
abstract final class Tuning {
  static const bullet = BulletTuning();
  static const player = PlayerTuning();
  static const drifter = DrifterTuning();
  static const charger = ChargerTuning();
  static const splitter = SplitterTuning();
  static const turret = TurretTuning();
  static const warden = WardenTuning();
  static const waves = WaveTuning();
  static const juice = JuiceTuning();
  static const input = InputTuning();
  static const trajectory = TrajectoryTuning();
  static const economy = EconomyTuning();
  static const score = ScoreTuning();
}

class BulletTuning {
  const BulletTuning();

  /// Launch speed range — drag length maps powerT in [0,1] across it.
  final double minSpeed = 420;
  final double maxSpeed = 780;

  /// +12% speed per wall bounce.
  final double speedGainPerBounce = 0.12;

  /// +1 damage per wall bounce; bounce 0 = 0 damage (the core rule).
  final int damagePerBounce = 1;
  final int maxBounces = 8;
  final double lifetime = 4.0; // seconds
  final double radius = 9;
}

class PlayerTuning {
  const PlayerTuning();

  final int maxHearts = 3;
  final double fireCooldown = 0.55;
  final double minFireCooldown = 0.18;
  final double dashDuration = 0.12;
  final double invulnAfterHit = 1.0;
  final double invulnAfterDash = 0.15;
  final int previewBounces = 2;
  final double radius = 26;
  final double coinPickupRadius = 64;
}

class DrifterTuning {
  const DrifterTuning();
  final int hp = 1;
  final double speed = 58;
  final double radius = 22;
  final double wobbleAmplitude = 26;
  final double wobbleFrequency = 1.4;
  final double smallScale = 0.62; // splitter children
  final double smallSpeedMult = 1.5;
}

class ChargerTuning {
  const ChargerTuning();
  final int hp = 2;
  final double roamSpeed = 46;
  final double dashSpeed = 460;
  final double telegraphDuration = 0.5;
  final double recoverDuration = 0.9;
  final double dashRange = 520; // max dash distance before recovering
  final double triggerRange = 360; // starts telegraphing within this
  final double radius = 24;
}

class SplitterTuning {
  const SplitterTuning();
  final int hp = 2;
  final double speed = 42;
  final double radius = 28;
  final double childSpread = 70; // offset of spawned children
}

class TurretTuning {
  const TurretTuning();
  final int hp = 4;
  final double radius = 26;
  final double fireInterval = 2.4;
  final double projectileSpeed = 140;
  final double projectileRadius = 10;
  final double chargeGlowDuration = 0.6;

  /// Velocity kept after bouncing off a turret-dampened wall section.
  /// The bounce counter does NOT increment on these — that wall is dead
  /// weight until the turret dies.
  final double dampRestitution = 0.55;
}

class WardenTuning {
  const WardenTuning();
  final int phaseHp = 14; // per phase
  final int phases = 3;
  final double radius = 56;
  final double speed = 26;
  final double rotationSpeed = 0.8; // rad/s
  final int shieldMinBounces = 3; // bullets below this clang off
  final double shieldDownDuration = 2.0; // after a phase break
  final double hpScalePerAppearance = 0.25; // +25% phase HP each Warden wave
}

class WaveTuning {
  const WaveTuning();
  final double spawnTelegraph = 0.6;
  final double interWaveDelay = 1.2;
  final int authoredWaves = 15;

  /// Past authored waves: count grows ~0.8/wave, hp +8%/wave, speed +1.5%
  /// capped at +60%.
  final double extraCountPerWave = 0.8;
  final double hpGrowthPerWave = 0.08;
  final double speedGrowthPerWave = 0.015;
  final double speedGrowthCap = 0.6;
  final int wardenEvery = 5;
}

class JuiceTuning {
  const JuiceTuning();
  final double hitStopMultiKill = 0.045;
  final double hitStopWardenHit = 0.060;
  final double shakeTraumaKill = 0.18;
  final double shakeTraumaChain = 0.35;
  final double shakeTraumaBoss = 0.5;
  final double shakeMaxOffset = 14;
  final double shakeDecayPerSecond = 1.6;
  final int particleBudget = 600;
}

class InputTuning {
  const InputTuning();

  /// Below this drag length (logical px) a release counts as a tap-dash.
  final double aimDeadzone = 24;

  /// Drag length mapping to full power.
  final double maxDragLength = 240;
}

class TrajectoryTuning {
  const TrajectoryTuning();
  final double dashLength = 18;
  final double gapLength = 12;
  final double flowSpeed = 90; // dash phase px/s
  final double maxTotalDistance = 2400;
  final double lineWidth = 3.5;
  final double bounceRingRadius = 8;
}

class EconomyTuning {
  const EconomyTuning();
  final int coinPerKill = 2;
  final double dropChance = 0.35; // chance a kill also drops a pickup coin
  final int dropValue = 3;
  final int waveClearBonus = 10;
  final int chainBonusPerKill = 5; // per kill beyond the first in a chain
}

class ScoreTuning {
  const ScoreTuning();
  final int killBase = 50;

  /// Kill score multiplies by (1 + bounceFactor * bounces).
  final double bounceFactor = 0.5;

  /// Seconds between kills by the SAME bullet to count as a chain.
  final double chainWindow = 1.4;
  final int chainBonus = 75; // per chain link beyond the first
  final int waveClearBase = 100;
}
