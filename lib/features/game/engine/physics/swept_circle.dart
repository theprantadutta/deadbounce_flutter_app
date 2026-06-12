import 'dart:math' as math;

import 'package:flame/components.dart';

/// Earliest contact time t in [0, 1] of a point moving from [p0] to [p1]
/// against a static circle at [center] with [combinedRadius]
/// (bullet radius + enemy radius), or null when they never touch.
/// Enemies move slowly relative to one 1/120s substep, so treating them
/// as static per substep is exact enough.
double? sweptCircleHitT(
  Vector2 p0,
  Vector2 p1,
  Vector2 center,
  double combinedRadius,
) {
  final d = p1 - p0;
  final f = p0 - center;

  final a = d.length2;
  if (a < 1e-12) {
    // Not moving this substep — overlap test.
    return f.length2 <= combinedRadius * combinedRadius ? 0 : null;
  }

  final b = 2 * f.dot(d);
  final c = f.length2 - combinedRadius * combinedRadius;

  final disc = b * b - 4 * a * c;
  if (disc < 0) return null;

  final sqrtDisc = math.sqrt(disc);

  final t1 = (-b - sqrtDisc) / (2 * a);
  if (t1 >= 0 && t1 <= 1) return t1;

  // Started inside (t1 < 0 <= t2): contact right now.
  final t2 = (-b + sqrtDisc) / (2 * a);
  if (t1 < 0 && t2 >= 0) return 0;

  return null;
}
