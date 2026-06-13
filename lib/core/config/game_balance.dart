/// The single source of truth for every tunable gameplay number.
///
/// This replaces the old compile-time `Tuning` const holder. It is a
/// **mutable singleton** (`GameBalance.I`) so the in-game debug tuning panel
/// can change values at runtime and have the game feel them immediately on the
/// next read (next shot / wave / event). Game systems read `GameBalance.I.<x>`
/// live — they must NOT copy values into long-lived fields in a way that can't
/// be refreshed.
///
/// Pure Dart (no Flutter import) so the engine and unit tests stay testable.
/// Persistence (shared_preferences) lives in `game_balance_store.dart`.
///
/// **Defaults are the shipped balance.** The debug panel's "Copy config" button
/// emits [toDartCode] so felt values can be promoted back into the field
/// initializers below. The difficulty philosophy and any changed defaults are
/// documented in CLAUDE.md.
library;

/// When a tuned value actually takes effect, surfaced as a label in the panel.
enum TuneScope {
  /// Read every event — felt immediately (speeds, coins/kill, score).
  live,

  /// Applied when the next wave spawns (enemy stats, wave scaling).
  nextWave,

  /// Applied when the next run starts (max hearts and other run-start folds).
  nextRun,
}

/// One adjustable scalar, with the metadata the panel needs and the get/set
/// closures that read/write the live section field. Also drives JSON
/// round-trip, reset, and copy-to-Dart so there is one registry, not four.
class TuningParam {
  TuningParam({
    required this.group,
    required this.key,
    required this.label,
    required this.get,
    required this.set,
    required this.min,
    required this.max,
    required this.step,
    this.isInt = false,
    this.scope = TuneScope.live,
  });

  /// Section display name (also the panel group header).
  final String group;

  /// Stable dotted id, e.g. `bullet.minSpeed` — JSON key + copy-to-Dart lhs.
  final String key;

  /// Human label shown next to the slider.
  final String label;

  final double Function() get;
  final void Function(double) set;
  final double min;
  final double max;
  final double step;
  final bool isInt;
  final TuneScope scope;
}

class GameBalance {
  GameBalance._();

  /// The live instance every game system reads. Mutated in place by the panel;
  /// never reassigned, so the [params] closures stay valid.
  static final GameBalance I = GameBalance._();

  final BulletBalance bullet = BulletBalance();
  final PlayerBalance player = PlayerBalance();
  final DrifterBalance drifter = DrifterBalance();
  final ChargerBalance charger = ChargerBalance();
  final SplitterBalance splitter = SplitterBalance();
  final TurretBalance turret = TurretBalance();
  final WardenBalance warden = WardenBalance();
  final WaveBalance waves = WaveBalance();
  final JuiceBalance juice = JuiceBalance();
  final InputBalance input = InputBalance();
  final TrajectoryBalance trajectory = TrajectoryBalance();
  final EconomyBalance economy = EconomyBalance();
  final ScoreBalance score = ScoreBalance();

  /// Restore every value to its shipped default (mutates the live sections in
  /// place so panel closures keep working).
  void resetToDefaults() {
    bullet.copyFrom(BulletBalance());
    player.copyFrom(PlayerBalance());
    drifter.copyFrom(DrifterBalance());
    charger.copyFrom(ChargerBalance());
    splitter.copyFrom(SplitterBalance());
    turret.copyFrom(TurretBalance());
    warden.copyFrom(WardenBalance());
    waves.copyFrom(WaveBalance());
    juice.copyFrom(JuiceBalance());
    input.copyFrom(InputBalance());
    trajectory.copyFrom(TrajectoryBalance());
    economy.copyFrom(EconomyBalance());
    score.copyFrom(ScoreBalance());
  }

  /// Serialize current values (dev-only persistence). Keyed by [TuningParam.key].
  Map<String, dynamic> toJson() => {for (final p in params) p.key: p.get()};

  /// Apply previously-saved values; unknown/missing keys are ignored so the
  /// stored blob stays forward/backward compatible as params are added.
  void applyJson(Map<String, dynamic> json) {
    final byKey = {for (final p in params) p.key: p};
    json.forEach((key, value) {
      final p = byKey[key];
      if (p != null && value is num) p.set(value.toDouble());
    });
  }

  /// Dump current values as Dart assignments, grouped by section, for the
  /// panel's "Copy config" button. Paste the lines into the section field
  /// initializers below to promote felt values into shipped defaults.
  String toDartCode() {
    final buffer = StringBuffer('// GameBalance — copied tuned values\n');
    String? currentGroup;
    for (final p in params) {
      if (p.group != currentGroup) {
        currentGroup = p.group;
        buffer.writeln('\n// $currentGroup');
      }
      final v = p.get();
      final rendered = p.isInt ? v.round().toString() : v.toString();
      buffer.writeln('${p.key} = $rendered;');
    }
    return buffer.toString();
  }

  /// The flat registry — single source for the panel, JSON, reset, copy.
  late final List<TuningParam> params = [
    // ---- Bullet ---- (do not change the feel; defaults locked)
    _p('Bullet', 'bullet.minSpeed', 'Min launch speed',
        () => bullet.minSpeed, (v) => bullet.minSpeed = v, 200, 1000, 5),
    _p('Bullet', 'bullet.maxSpeed', 'Max launch speed',
        () => bullet.maxSpeed, (v) => bullet.maxSpeed = v, 300, 1400, 5),
    _p('Bullet', 'bullet.speedGainPerBounce', '+Speed per bounce',
        () => bullet.speedGainPerBounce, (v) => bullet.speedGainPerBounce = v,
        0, 0.5, 0.01),
    _pi('Bullet', 'bullet.damagePerBounce', 'Damage per bounce',
        () => bullet.damagePerBounce.toDouble(),
        (v) => bullet.damagePerBounce = v.round(), 1, 5, 1),
    _pi('Bullet', 'bullet.maxBounces', 'Max bounces',
        () => bullet.maxBounces.toDouble(),
        (v) => bullet.maxBounces = v.round(), 1, 16, 1),
    _p('Bullet', 'bullet.lifetime', 'Lifetime (s)',
        () => bullet.lifetime, (v) => bullet.lifetime = v, 1, 10, 0.1),
    _p('Bullet', 'bullet.radius', 'Hitbox radius',
        () => bullet.radius, (v) => bullet.radius = v, 4, 20, 0.5),

    // ---- Player ----
    _pi('Player', 'player.maxHearts', 'Max hearts',
        () => player.maxHearts.toDouble(),
        (v) => player.maxHearts = v.round(), 1, 9, 1, TuneScope.nextRun),
    _p('Player', 'player.fireCooldown', 'Fire cooldown (s)',
        () => player.fireCooldown, (v) => player.fireCooldown = v,
        0.1, 2, 0.01, TuneScope.nextRun),
    _p('Player', 'player.minFireCooldown', 'Min fire cooldown (s)',
        () => player.minFireCooldown, (v) => player.minFireCooldown = v,
        0.05, 1, 0.01, TuneScope.nextRun),
    _p('Player', 'player.dashDuration', 'Dash duration (s)',
        () => player.dashDuration, (v) => player.dashDuration = v,
        0.05, 0.5, 0.01),
    _p('Player', 'player.invulnAfterHit', 'I-frames after hit (s)',
        () => player.invulnAfterHit, (v) => player.invulnAfterHit = v,
        0, 3, 0.05),
    _p('Player', 'player.invulnAfterDash', 'I-frames after dash (s)',
        () => player.invulnAfterDash, (v) => player.invulnAfterDash = v,
        0, 1, 0.05),
    _pi('Player', 'player.previewBounces', 'Preview bounces',
        () => player.previewBounces.toDouble(),
        (v) => player.previewBounces = v.round(), 0, 6, 1, TuneScope.nextRun),
    _p('Player', 'player.radius', 'Body radius',
        () => player.radius, (v) => player.radius = v, 12, 48, 1),
    _p('Player', 'player.coinPickupRadius', 'Coin pickup radius',
        () => player.coinPickupRadius, (v) => player.coinPickupRadius = v,
        16, 200, 4, TuneScope.nextRun),

    // ---- Drifter ----
    _pi('Drifter', 'drifter.hp', 'HP', () => drifter.hp.toDouble(),
        (v) => drifter.hp = v.round(), 1, 10, 1, TuneScope.nextWave),
    _p('Drifter', 'drifter.speed', 'Speed', () => drifter.speed,
        (v) => drifter.speed = v, 10, 200, 2),
    _p('Drifter', 'drifter.radius', 'Radius', () => drifter.radius,
        (v) => drifter.radius = v, 10, 48, 1),
    _p('Drifter', 'drifter.wobbleAmplitude', 'Wobble amplitude',
        () => drifter.wobbleAmplitude, (v) => drifter.wobbleAmplitude = v,
        0, 80, 2),
    _p('Drifter', 'drifter.wobbleFrequency', 'Wobble frequency',
        () => drifter.wobbleFrequency, (v) => drifter.wobbleFrequency = v,
        0, 5, 0.1),
    _p('Drifter', 'drifter.smallScale', 'Small scale (children)',
        () => drifter.smallScale, (v) => drifter.smallScale = v, 0.3, 1, 0.02),
    _p('Drifter', 'drifter.smallSpeedMult', 'Small speed mult',
        () => drifter.smallSpeedMult, (v) => drifter.smallSpeedMult = v,
        0.5, 3, 0.05),

    // ---- Charger ----
    _pi('Charger', 'charger.hp', 'HP', () => charger.hp.toDouble(),
        (v) => charger.hp = v.round(), 1, 12, 1, TuneScope.nextWave),
    _p('Charger', 'charger.roamSpeed', 'Roam speed', () => charger.roamSpeed,
        (v) => charger.roamSpeed = v, 10, 160, 2),
    _p('Charger', 'charger.dashSpeed', 'Dash speed', () => charger.dashSpeed,
        (v) => charger.dashSpeed = v, 100, 900, 10),
    _p('Charger', 'charger.telegraphDuration', 'Telegraph (s)',
        () => charger.telegraphDuration, (v) => charger.telegraphDuration = v,
        0.1, 2, 0.05),
    _p('Charger', 'charger.recoverDuration', 'Recover (s)',
        () => charger.recoverDuration, (v) => charger.recoverDuration = v,
        0.1, 2.5, 0.05),
    _p('Charger', 'charger.dashRange', 'Dash range', () => charger.dashRange,
        (v) => charger.dashRange = v, 100, 1000, 10),
    _p('Charger', 'charger.triggerRange', 'Trigger range',
        () => charger.triggerRange, (v) => charger.triggerRange = v,
        100, 800, 10),
    _p('Charger', 'charger.radius', 'Radius', () => charger.radius,
        (v) => charger.radius = v, 12, 48, 1),

    // ---- Splitter ----
    _pi('Splitter', 'splitter.hp', 'HP', () => splitter.hp.toDouble(),
        (v) => splitter.hp = v.round(), 1, 12, 1, TuneScope.nextWave),
    _p('Splitter', 'splitter.speed', 'Speed', () => splitter.speed,
        (v) => splitter.speed = v, 10, 160, 2),
    _p('Splitter', 'splitter.radius', 'Radius', () => splitter.radius,
        (v) => splitter.radius = v, 12, 56, 1),
    _p('Splitter', 'splitter.childSpread', 'Child spread',
        () => splitter.childSpread, (v) => splitter.childSpread = v, 20, 160, 5),

    // ---- Turret ----
    _pi('Turret', 'turret.hp', 'HP', () => turret.hp.toDouble(),
        (v) => turret.hp = v.round(), 1, 16, 1, TuneScope.nextWave),
    _p('Turret', 'turret.radius', 'Radius', () => turret.radius,
        (v) => turret.radius = v, 12, 48, 1),
    _p('Turret', 'turret.fireInterval', 'Fire interval (s)',
        () => turret.fireInterval, (v) => turret.fireInterval = v, 0.5, 6, 0.1),
    _p('Turret', 'turret.projectileSpeed', 'Projectile speed',
        () => turret.projectileSpeed, (v) => turret.projectileSpeed = v,
        40, 400, 5),
    _p('Turret', 'turret.projectileRadius', 'Projectile radius',
        () => turret.projectileRadius, (v) => turret.projectileRadius = v,
        4, 24, 1),
    _p('Turret', 'turret.chargeGlowDuration', 'Charge glow (s)',
        () => turret.chargeGlowDuration, (v) => turret.chargeGlowDuration = v,
        0.1, 2, 0.05),
    _p('Turret', 'turret.dampRestitution', 'Damp restitution',
        () => turret.dampRestitution, (v) => turret.dampRestitution = v,
        0.1, 1, 0.05),

    // ---- Warden ----
    _pi('Warden', 'warden.phaseHp', 'Phase HP', () => warden.phaseHp.toDouble(),
        (v) => warden.phaseHp = v.round(), 4, 40, 1, TuneScope.nextWave),
    _pi('Warden', 'warden.phases', 'Phases', () => warden.phases.toDouble(),
        (v) => warden.phases = v.round(), 1, 6, 1, TuneScope.nextWave),
    _p('Warden', 'warden.radius', 'Radius', () => warden.radius,
        (v) => warden.radius = v, 30, 90, 2),
    _p('Warden', 'warden.speed', 'Speed', () => warden.speed,
        (v) => warden.speed = v, 5, 100, 2),
    _p('Warden', 'warden.rotationSpeed', 'Rotation speed',
        () => warden.rotationSpeed, (v) => warden.rotationSpeed = v, 0, 3, 0.1),
    _pi('Warden', 'warden.shieldMinBounces', 'Shield min bounces',
        () => warden.shieldMinBounces.toDouble(),
        (v) => warden.shieldMinBounces = v.round(), 1, 8, 1, TuneScope.nextWave),
    _p('Warden', 'warden.shieldDownDuration', 'Shield-down (s)',
        () => warden.shieldDownDuration, (v) => warden.shieldDownDuration = v,
        0.5, 5, 0.1),
    _p('Warden', 'warden.hpScalePerAppearance', '+HP per appearance',
        () => warden.hpScalePerAppearance,
        (v) => warden.hpScalePerAppearance = v, 0, 1, 0.05),

    // ---- Waves / difficulty ----
    _p('Waves', 'waves.spawnTelegraph', 'Spawn telegraph (s)',
        () => waves.spawnTelegraph, (v) => waves.spawnTelegraph = v,
        0.1, 2, 0.05, TuneScope.nextWave),
    _p('Waves', 'waves.interWaveDelay', 'Inter-wave delay (s)',
        () => waves.interWaveDelay, (v) => waves.interWaveDelay = v,
        0, 4, 0.1, TuneScope.nextWave),
    _p('Waves', 'waves.extraCountPerWave', 'Extra count / wave',
        () => waves.extraCountPerWave, (v) => waves.extraCountPerWave = v,
        0, 3, 0.1, TuneScope.nextWave),
    _p('Waves', 'waves.hpGrowthPerWave', 'HP growth / wave',
        () => waves.hpGrowthPerWave, (v) => waves.hpGrowthPerWave = v,
        0, 0.3, 0.01, TuneScope.nextWave),
    _p('Waves', 'waves.hpCurveExponent', 'HP curve steepness',
        () => waves.hpCurveExponent, (v) => waves.hpCurveExponent = v,
        0.5, 3, 0.05, TuneScope.nextWave),
    _p('Waves', 'waves.speedGrowthPerWave', 'Speed growth / wave',
        () => waves.speedGrowthPerWave, (v) => waves.speedGrowthPerWave = v,
        0, 0.1, 0.005, TuneScope.nextWave),
    _p('Waves', 'waves.speedCurveExponent', 'Speed curve steepness',
        () => waves.speedCurveExponent, (v) => waves.speedCurveExponent = v,
        0.5, 3, 0.05, TuneScope.nextWave),
    _p('Waves', 'waves.speedGrowthCap', 'Speed growth cap',
        () => waves.speedGrowthCap, (v) => waves.speedGrowthCap = v,
        0, 2, 0.05, TuneScope.nextWave),
    _pi('Waves', 'waves.firstWardenWave', 'First Warden wave',
        () => waves.firstWardenWave.toDouble(),
        (v) => waves.firstWardenWave = v.round(), 1, 30, 1, TuneScope.nextWave),
    _pi('Waves', 'waves.wardenEvery', 'Warden every N waves',
        () => waves.wardenEvery.toDouble(),
        (v) => waves.wardenEvery = v.round(), 2, 12, 1, TuneScope.nextWave),

    // ---- Economy ---- (earn-rate feel)
    _pi('Economy', 'economy.coinPerKill', 'Coins per kill',
        () => economy.coinPerKill.toDouble(),
        (v) => economy.coinPerKill = v.round(), 0, 50, 1),
    _p('Economy', 'economy.dropChance', 'Coin drop chance',
        () => economy.dropChance, (v) => economy.dropChance = v, 0, 1, 0.05),
    _pi('Economy', 'economy.dropValue', 'Coin drop value',
        () => economy.dropValue.toDouble(),
        (v) => economy.dropValue = v.round(), 0, 50, 1),
    _pi('Economy', 'economy.waveClearBonus', 'Wave-clear bonus',
        () => economy.waveClearBonus.toDouble(),
        (v) => economy.waveClearBonus = v.round(), 0, 200, 1),
    _pi('Economy', 'economy.chainBonusPerKill', 'Chain bonus / kill',
        () => economy.chainBonusPerKill.toDouble(),
        (v) => economy.chainBonusPerKill = v.round(), 0, 100, 1),
    // 7-day login reward calendar (1-based day → coins).
    for (var i = 0; i < economy.loginRewardsByDay.length; i++)
      _pi('Economy', 'economy.loginRewardsByDay.$i', 'Login day ${i + 1}',
          () => economy.loginRewardsByDay[i].toDouble(),
          (v) => economy.loginRewardsByDay[i] = v.round(), 0, 1000, 5),

    // ---- Score ----
    _pi('Score', 'score.killBase', 'Kill base', () => score.killBase.toDouble(),
        (v) => score.killBase = v.round(), 0, 500, 5),
    _p('Score', 'score.bounceFactor', 'Bounce factor', () => score.bounceFactor,
        (v) => score.bounceFactor = v, 0, 3, 0.05),
    _p('Score', 'score.chainWindow', 'Chain window (s)', () => score.chainWindow,
        (v) => score.chainWindow = v, 0.3, 4, 0.1),
    _pi('Score', 'score.chainBonus', 'Chain bonus', () => score.chainBonus.toDouble(),
        (v) => score.chainBonus = v.round(), 0, 500, 5),
    _pi('Score', 'score.waveClearBase', 'Wave-clear base',
        () => score.waveClearBase.toDouble(),
        (v) => score.waveClearBase = v.round(), 0, 1000, 10),

    // ---- Game feel ---- (lower priority to tune)
    _p('Game feel', 'juice.hitStopMultiKill', 'Hit-stop multikill (s)',
        () => juice.hitStopMultiKill, (v) => juice.hitStopMultiKill = v,
        0, 0.2, 0.005),
    _p('Game feel', 'juice.hitStopWardenHit', 'Hit-stop warden (s)',
        () => juice.hitStopWardenHit, (v) => juice.hitStopWardenHit = v,
        0, 0.2, 0.005),
    _p('Game feel', 'juice.shakeTraumaKill', 'Shake trauma kill',
        () => juice.shakeTraumaKill, (v) => juice.shakeTraumaKill = v,
        0, 1, 0.02),
    _p('Game feel', 'juice.shakeTraumaChain', 'Shake trauma chain',
        () => juice.shakeTraumaChain, (v) => juice.shakeTraumaChain = v,
        0, 1, 0.02),
    _p('Game feel', 'juice.shakeTraumaBoss', 'Shake trauma boss',
        () => juice.shakeTraumaBoss, (v) => juice.shakeTraumaBoss = v,
        0, 1, 0.02),
    _p('Game feel', 'juice.shakeMaxOffset', 'Shake max offset',
        () => juice.shakeMaxOffset, (v) => juice.shakeMaxOffset = v, 0, 40, 1),
    _p('Game feel', 'juice.shakeDecayPerSecond', 'Shake decay /s',
        () => juice.shakeDecayPerSecond, (v) => juice.shakeDecayPerSecond = v,
        0.2, 5, 0.1),
    _pi('Game feel', 'juice.particleBudget', 'Particle budget',
        () => juice.particleBudget.toDouble(),
        (v) => juice.particleBudget = v.round(), 50, 2000, 50),

    // ---- Input ----
    _p('Input', 'input.aimDeadzone', 'Aim deadzone (px)',
        () => input.aimDeadzone, (v) => input.aimDeadzone = v, 4, 80, 2),
    _p('Input', 'input.maxDragLength', 'Max drag length (px)',
        () => input.maxDragLength, (v) => input.maxDragLength = v, 80, 480, 10),

    // ---- Trajectory ----
    _p('Trajectory', 'trajectory.dashLength', 'Dash length',
        () => trajectory.dashLength, (v) => trajectory.dashLength = v, 4, 40, 1),
    _p('Trajectory', 'trajectory.gapLength', 'Gap length',
        () => trajectory.gapLength, (v) => trajectory.gapLength = v, 2, 40, 1),
    _p('Trajectory', 'trajectory.flowSpeed', 'Flow speed',
        () => trajectory.flowSpeed, (v) => trajectory.flowSpeed = v, 0, 240, 5),
    _p('Trajectory', 'trajectory.maxTotalDistance', 'Max total distance',
        () => trajectory.maxTotalDistance,
        (v) => trajectory.maxTotalDistance = v, 600, 5000, 50),
    _p('Trajectory', 'trajectory.lineWidth', 'Line width',
        () => trajectory.lineWidth, (v) => trajectory.lineWidth = v, 1, 8, 0.5),
    _p('Trajectory', 'trajectory.bounceRingRadius', 'Bounce ring radius',
        () => trajectory.bounceRingRadius,
        (v) => trajectory.bounceRingRadius = v, 2, 20, 1),
  ];
}

TuningParam _p(String group, String key, String label, double Function() get,
        void Function(double) set, double min, double max, double step,
        [TuneScope scope = TuneScope.live]) =>
    TuningParam(
        group: group,
        key: key,
        label: label,
        get: get,
        set: set,
        min: min,
        max: max,
        step: step,
        scope: scope);

TuningParam _pi(String group, String key, String label, double Function() get,
        void Function(double) set, double min, double max, double step,
        [TuneScope scope = TuneScope.live]) =>
    TuningParam(
        group: group,
        key: key,
        label: label,
        get: get,
        set: set,
        min: min,
        max: max,
        step: step,
        isInt: true,
        scope: scope);

// ===========================================================================
// Section holders. Plain mutable classes; field initializers ARE the shipped
// defaults (single source of truth — `copyFrom` resets from a fresh instance).
// ===========================================================================

class BulletBalance {
  /// Launch speed range — drag length maps powerT in [0,1] across it.
  double minSpeed = 420;
  double maxSpeed = 780;

  /// +12% speed per wall bounce.
  double speedGainPerBounce = 0.12;

  /// +1 damage per wall bounce; bounce 0 = 0 damage (the core rule).
  int damagePerBounce = 1;
  int maxBounces = 8;
  double lifetime = 4.0; // seconds
  double radius = 9;

  void copyFrom(BulletBalance o) {
    minSpeed = o.minSpeed;
    maxSpeed = o.maxSpeed;
    speedGainPerBounce = o.speedGainPerBounce;
    damagePerBounce = o.damagePerBounce;
    maxBounces = o.maxBounces;
    lifetime = o.lifetime;
    radius = o.radius;
  }
}

class PlayerBalance {
  int maxHearts = 3;
  double fireCooldown = 0.55;
  double minFireCooldown = 0.18;
  double dashDuration = 0.12;
  double invulnAfterHit = 1.2; // forgiving i-frames so early mistakes don't snowball
  double invulnAfterDash = 0.15;
  int previewBounces = 2;
  double radius = 26;
  double coinPickupRadius = 64;

  void copyFrom(PlayerBalance o) {
    maxHearts = o.maxHearts;
    fireCooldown = o.fireCooldown;
    minFireCooldown = o.minFireCooldown;
    dashDuration = o.dashDuration;
    invulnAfterHit = o.invulnAfterHit;
    invulnAfterDash = o.invulnAfterDash;
    previewBounces = o.previewBounces;
    radius = o.radius;
    coinPickupRadius = o.coinPickupRadius;
  }
}

class DrifterBalance {
  int hp = 1;
  double speed = 58;
  double radius = 22;
  double wobbleAmplitude = 26;
  double wobbleFrequency = 1.4;
  double smallScale = 0.62; // splitter children
  double smallSpeedMult = 1.5;

  void copyFrom(DrifterBalance o) {
    hp = o.hp;
    speed = o.speed;
    radius = o.radius;
    wobbleAmplitude = o.wobbleAmplitude;
    wobbleFrequency = o.wobbleFrequency;
    smallScale = o.smallScale;
    smallSpeedMult = o.smallSpeedMult;
  }
}

class ChargerBalance {
  int hp = 2;
  double roamSpeed = 46;
  double dashSpeed = 460;
  double telegraphDuration = 0.7; // long, obvious wind-up = generous dodge window
  double recoverDuration = 0.9;
  double dashRange = 520; // max dash distance before recovering
  double triggerRange = 360; // starts telegraphing within this
  double radius = 24;

  void copyFrom(ChargerBalance o) {
    hp = o.hp;
    roamSpeed = o.roamSpeed;
    dashSpeed = o.dashSpeed;
    telegraphDuration = o.telegraphDuration;
    recoverDuration = o.recoverDuration;
    dashRange = o.dashRange;
    triggerRange = o.triggerRange;
    radius = o.radius;
  }
}

class SplitterBalance {
  int hp = 2;
  double speed = 42;
  double radius = 28;
  double childSpread = 70; // offset of spawned children

  void copyFrom(SplitterBalance o) {
    hp = o.hp;
    speed = o.speed;
    radius = o.radius;
    childSpread = o.childSpread;
  }
}

class TurretBalance {
  int hp = 4;
  double radius = 26;
  double fireInterval = 2.4;
  double projectileSpeed = 140;
  double projectileRadius = 10;
  double chargeGlowDuration = 0.6;

  /// Velocity kept after bouncing off a turret-dampened wall section.
  /// The bounce counter does NOT increment on these — that wall is dead
  /// weight until the turret dies.
  double dampRestitution = 0.55;

  void copyFrom(TurretBalance o) {
    hp = o.hp;
    radius = o.radius;
    fireInterval = o.fireInterval;
    projectileSpeed = o.projectileSpeed;
    projectileRadius = o.projectileRadius;
    chargeGlowDuration = o.chargeGlowDuration;
    dampRestitution = o.dampRestitution;
  }
}

class WardenBalance {
  int phaseHp = 14; // per phase
  int phases = 3;
  double radius = 56;
  double speed = 26;
  double rotationSpeed = 0.8; // rad/s
  int shieldMinBounces = 3; // bullets below this clang off
  double shieldDownDuration = 2.0; // after a phase break
  double hpScalePerAppearance = 0.25; // +25% phase HP each Warden wave

  void copyFrom(WardenBalance o) {
    phaseHp = o.phaseHp;
    phases = o.phases;
    radius = o.radius;
    speed = o.speed;
    rotationSpeed = o.rotationSpeed;
    shieldMinBounces = o.shieldMinBounces;
    shieldDownDuration = o.shieldDownDuration;
    hpScalePerAppearance = o.hpScalePerAppearance;
  }
}

class WaveBalance {
  double spawnTelegraph = 0.6;
  double interWaveDelay = 1.2;
  int authoredWaves = 15;

  /// Difficulty philosophy: the first 3 waves must feel trivial; difficulty is
  /// near-flat early then accelerates. The authored table (waves 1–15) hand-
  /// crafts the gentle on-ramp; beyond it these formulas compose endless waves.
  ///
  /// Past authored waves, hp/speed grow as `growth * past^exponent` — exponent
  /// > 1 keeps the curve shallow early and steepens it later. Speed is capped.
  double extraCountPerWave = 0.8;
  double hpGrowthPerWave = 0.08;
  double hpCurveExponent = 1.3;
  double speedGrowthPerWave = 0.015;
  double speedCurveExponent = 1.3;
  double speedGrowthCap = 0.6;

  /// The first Warden appears on this wave (kept late so the early game stays
  /// kind); after it, one shows every [wardenEvery] waves (15, 20, …).
  int firstWardenWave = 10;
  int wardenEvery = 5;

  void copyFrom(WaveBalance o) {
    spawnTelegraph = o.spawnTelegraph;
    interWaveDelay = o.interWaveDelay;
    authoredWaves = o.authoredWaves;
    extraCountPerWave = o.extraCountPerWave;
    hpGrowthPerWave = o.hpGrowthPerWave;
    hpCurveExponent = o.hpCurveExponent;
    speedGrowthPerWave = o.speedGrowthPerWave;
    speedCurveExponent = o.speedCurveExponent;
    speedGrowthCap = o.speedGrowthCap;
    firstWardenWave = o.firstWardenWave;
    wardenEvery = o.wardenEvery;
  }
}

class JuiceBalance {
  double hitStopMultiKill = 0.045;
  double hitStopWardenHit = 0.060;
  double shakeTraumaKill = 0.18;
  double shakeTraumaChain = 0.35;
  double shakeTraumaBoss = 0.5;
  double shakeMaxOffset = 14;
  double shakeDecayPerSecond = 1.6;
  int particleBudget = 600;

  void copyFrom(JuiceBalance o) {
    hitStopMultiKill = o.hitStopMultiKill;
    hitStopWardenHit = o.hitStopWardenHit;
    shakeTraumaKill = o.shakeTraumaKill;
    shakeTraumaChain = o.shakeTraumaChain;
    shakeTraumaBoss = o.shakeTraumaBoss;
    shakeMaxOffset = o.shakeMaxOffset;
    shakeDecayPerSecond = o.shakeDecayPerSecond;
    particleBudget = o.particleBudget;
  }
}

class InputBalance {
  /// Below this drag length (logical px) a release counts as a tap-dash.
  double aimDeadzone = 24;

  /// Drag length mapping to full power.
  double maxDragLength = 240;

  void copyFrom(InputBalance o) {
    aimDeadzone = o.aimDeadzone;
    maxDragLength = o.maxDragLength;
  }
}

class TrajectoryBalance {
  double dashLength = 18;
  double gapLength = 12;
  double flowSpeed = 90; // dash phase px/s
  double maxTotalDistance = 2400;
  double lineWidth = 3.5;
  double bounceRingRadius = 8;

  void copyFrom(TrajectoryBalance o) {
    dashLength = o.dashLength;
    gapLength = o.gapLength;
    flowSpeed = o.flowSpeed;
    maxTotalDistance = o.maxTotalDistance;
    lineWidth = o.lineWidth;
    bounceRingRadius = o.bounceRingRadius;
  }
}

class EconomyBalance {
  // In-run earn rates. Tuned so even the easy early waves give satisfying coin
  // feedback (numbers going up) without a runaway curve.
  int coinPerKill = 3;
  double dropChance = 0.4; // chance a kill also drops a pickup coin
  int dropValue = 4;
  int waveClearBonus = 15;
  int chainBonusPerKill = 4; // per kill beyond the first in a chain

  /// 7-day login reward calendar (day 7 is the big haul). Indexed by the
  /// 1-based calendar day; the cycle repeats. Lives here so earn rates are
  /// panel-tunable. NOTE: achievement/challenge reward amounts are NOT here —
  /// those mirror the backend's validation catalog and must not drift.
  List<int> loginRewardsByDay = [25, 40, 60, 80, 110, 150, 300];

  void copyFrom(EconomyBalance o) {
    coinPerKill = o.coinPerKill;
    dropChance = o.dropChance;
    dropValue = o.dropValue;
    waveClearBonus = o.waveClearBonus;
    chainBonusPerKill = o.chainBonusPerKill;
    loginRewardsByDay = List<int>.of(o.loginRewardsByDay);
  }
}

class ScoreBalance {
  int killBase = 50;

  /// Kill score multiplies by (1 + bounceFactor * bounces).
  double bounceFactor = 0.5;

  /// Seconds between kills by the SAME bullet to count as a chain.
  double chainWindow = 1.4;
  int chainBonus = 75; // per chain link beyond the first
  int waveClearBase = 100;

  void copyFrom(ScoreBalance o) {
    killBase = o.killBase;
    bounceFactor = o.bounceFactor;
    chainWindow = o.chainWindow;
    waveClearBase = o.waveClearBase;
    chainBonus = o.chainBonus;
  }
}
