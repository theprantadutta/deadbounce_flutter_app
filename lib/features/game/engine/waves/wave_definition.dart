enum EnemyType {
  drifter,
  smallDrifter,
  charger,
  splitter,
  turret,
  warden,
  powderkeg,
  sawbones,
  ironhide,
  mirror,
  skitter,
  lancer,
}

/// How a group's members are arranged in space when they spawn.
///
/// Chains — same-bullet kills within the chain window — are the game's stated
/// identity, but scattered spawns rarely line targets up. A non-[scattered]
/// group shares a single spawn anchor and lays its members out as a threadable
/// shape, so a clever ricochet can thread several in one shot.
enum SpawnFormation {
  /// Each member picks an independent random spawn point (the default — the
  /// original behavior, untouched).
  scattered,

  /// A straight row along the spawn edge — the clearest "one bullet, many
  /// targets" setup.
  line,

  /// An arrowhead: a row that bends inward toward the arena.
  wedge,

  /// A tight blob that blooms into a threadable arc as separation steering
  /// pushes it apart on the approach.
  cluster,
}

/// A batch of one enemy type spawned together (with stagger).
class SpawnGroup {
  const SpawnGroup({
    required this.type,
    required this.count,
    this.delay = 0,
    this.stagger = 0.5,
    this.formation = SpawnFormation.scattered,
  });

  final EnemyType type;
  final int count;

  /// Seconds after the wave starts before this group begins.
  final double delay;

  /// Seconds between spawns within the group.
  final double stagger;

  /// Spatial arrangement of this group's members (see [SpawnFormation]).
  final SpawnFormation formation;
}

/// One wave: its groups plus scaling multipliers applied to every enemy.
class WaveDefinition {
  const WaveDefinition({
    required this.wave,
    required this.groups,
    this.hpMult = 1,
    this.speedMult = 1,
  });

  final int wave;
  final List<SpawnGroup> groups;
  final double hpMult;
  final double speedMult;

  int get totalCount =>
      groups.fold(0, (sum, g) => sum + g.count);

  /// True when this wave fields a Warden — a boss wave (cues boss music).
  bool get hasBoss => groups.any((g) => g.type == EnemyType.warden);
}
