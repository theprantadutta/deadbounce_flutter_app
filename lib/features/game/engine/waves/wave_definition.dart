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
}

/// A batch of one enemy type spawned together (with stagger).
class SpawnGroup {
  const SpawnGroup({
    required this.type,
    required this.count,
    this.delay = 0,
    this.stagger = 0.5,
  });

  final EnemyType type;
  final int count;

  /// Seconds after the wave starts before this group begins.
  final double delay;

  /// Seconds between spawns within the group.
  final double stagger;
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
