import 'package:flame/components.dart';

import 'bullet_stats.dart';

/// Per-bullet mutable flags set by upgrade modifiers.
class BulletFlags {
  BulletFlags({
    this.ghostPassesRemaining = 0,
    this.hasSplit = false,
    this.trailCooldown = 0,
  });

  /// Ghost Round: walls this bullet may pass through (consumed by the
  /// solver).
  int ghostPassesRemaining;

  /// Split Shot: a bullet splits at most once.
  bool hasSplit;

  /// Incendiary Trail drop timer.
  double trailCooldown;
}

/// The live state of one bullet — mutated by the RicochetSolver.
class BulletState {
  BulletState({
    required this.position,
    required this.velocity,
    this.bounces = 0,
    this.age = 0,
    BulletFlags? flags,
  }) : flags = flags ?? BulletFlags();

  final Vector2 position;
  final Vector2 velocity;
  int bounces;
  double age;
  final BulletFlags flags;

  /// Enemies already hit since the last bounce — a bullet passes through
  /// (or damages) each enemy at most once per straight segment.
  final Set<int> hitEnemyIds = <int>{};

  /// THE core rule: zero damage until the first wall bounce, then
  /// damagePerBounce per bounce.
  int damageFor(BulletStats stats) =>
      bounces == 0 ? 0 : bounces * stats.damagePerBounce;

  bool isExpired(BulletStats stats) =>
      bounces >= stats.maxBounces || age >= stats.lifetime;
}
