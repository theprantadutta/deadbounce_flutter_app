import 'package:flame/components.dart';

/// One ricochet surface. Normals point INTO the arena and are computed at
/// arena load — authors never hand-write them.
class WallSegment {
  WallSegment({
    required this.a,
    required this.b,
    required this.normal,
    this.isBoundary = true,
    this.turretSlot,
    this.isMirror = false,
  });

  final Vector2 a;
  final Vector2 b;

  /// Unit normal, oriented toward the playable interior.
  final Vector2 normal;

  /// Boundary walls vs obstacle (pillar) edges.
  final bool isBoundary;

  /// Non-null when a Turret may anchor here (index into the arena's
  /// turret slots).
  final int? turretSlot;

  /// A Mirror enemy's reflecting face: a dynamic, one-sided segment owned
  /// by a [MirrorEnemy] (added to the solver's list while it lives, removed
  /// on death). The arena doesn't draw these — the enemy renders itself.
  final bool isMirror;

  /// Id of the TurretEnemy currently dampening this section, or null.
  /// While held: bullets reflect with reduced restitution and do NOT
  /// gain a bounce — tactical pressure to kill the turret first.
  String? dampenedBy;

  bool get isDampened => dampenedBy != null;

  Vector2 get direction => (b - a)..normalize();
  double get length => a.distanceTo(b);
  Vector2 get midpoint => (a + b)..scale(0.5);
}
