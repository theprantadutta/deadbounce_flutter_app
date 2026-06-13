import 'dart:math' as math;

import 'package:flame/components.dart';

import '../combat/bullet_state.dart';
import '../combat/bullet_stats.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';

import 'wall_segment.dart';

/// Result of a raycast against the arena walls.
class RayHit {
  const RayHit({
    required this.segment,
    required this.point,
    required this.distance,
    required this.normal,
  });

  final WallSegment segment;
  final Vector2 point;
  final double distance;
  final Vector2 normal;
}

/// One wall contact resolved during [RicochetSolver.advance].
class BounceResult {
  const BounceResult({
    required this.segment,
    required this.point,
    required this.bounceIndex,
    required this.dampened,
    required this.ghosted,
  });

  final WallSegment segment;
  final Vector2 point;

  /// Bullet's bounce count AFTER this contact (unchanged when dampened
  /// or ghosted).
  final int bounceIndex;
  final bool dampened;
  final bool ghosted;
}

/// THE shared ricochet core: bullet movement and the aim preview both run
/// through [castRay] and the same bounce rules, which is what guarantees
/// preview == reality. Movement IS the raycast — there is no
/// move-then-check step, so tunneling is impossible at any speed.
class RicochetSolver {
  RicochetSolver(this.segments);

  final List<WallSegment> segments;

  /// Push-off after a reflection so the continuing ray can't re-hit the
  /// surface it just left.
  static const double _epsilon = 0.01;

  /// Max wall contacts resolved within ONE advance step — corner-jam guard.
  static const int _maxContactsPerStep = 8;

  static Vector2 reflect(Vector2 v, Vector2 n) => v - n * (2 * v.dot(n));

  /// Nearest wall hit along [dir] (unit) from [origin], for a circle of
  /// [radius] — segments are offset inward by the radius and endpoints
  /// get circle tests, making the swept circle exact for this geometry.
  RayHit? castRay(
    Vector2 origin,
    Vector2 dir,
    double maxDist, {
    required double radius,
    WallSegment? ignore,
  }) {
    RayHit? nearest;

    for (final segment in segments) {
      if (identical(segment, ignore)) continue;

      final hit = _raySegment(origin, dir, maxDist, segment, radius);
      if (hit != null && (nearest == null || hit.distance < nearest.distance)) {
        nearest = hit;
      }
    }

    return nearest;
  }

  /// Advances a bullet by [dt], resolving wall contacts as it goes and
  /// reporting the straight sub-segments traveled (for swept enemy hits).
  void advance(
    BulletState state,
    BulletStats stats,
    double dt, {
    required void Function(BounceResult) onBounce,
    void Function(Vector2 from, Vector2 to)? onSubSegment,
  }) {
    var remaining = state.velocity.length * dt;
    var contacts = 0;
    WallSegment? lastSegment;

    while (remaining > _epsilon && contacts < _maxContactsPerStep) {
      final speed = state.velocity.length;
      if (speed <= 0) return;

      final dir = state.velocity / speed;
      final hit = castRay(
        state.position,
        dir,
        remaining,
        radius: stats.radius,
        ignore: lastSegment,
      );

      if (hit == null) {
        final from = state.position.clone();
        state.position.addScaled(dir, remaining);
        onSubSegment?.call(from, state.position.clone());
        return;
      }

      // Travel to the contact point.
      final from = state.position.clone();
      state.position.setFrom(hit.point);
      onSubSegment?.call(from, state.position.clone());
      remaining -= hit.distance;
      contacts++;
      lastSegment = hit.segment;

      // Ghost Round: pass through one wall, once.
      if (state.flags.ghostPassesRemaining > 0) {
        state.flags.ghostPassesRemaining--;
        state.position.addScaled(dir, _epsilon);
        onBounce(BounceResult(
          segment: hit.segment,
          point: hit.point.clone(),
          bounceIndex: state.bounces,
          dampened: false,
          ghosted: true,
        ));
        continue;
      }

      final reflected = reflect(state.velocity, hit.normal);

      if (hit.segment.isDampened) {
        // Turret-held wall: geometric reflection, energy bleed, and NO
        // bounce increment — no damage gain off this surface.
        state.velocity
          ..setFrom(reflected)
          ..scale(GameBalance.I.turret.dampRestitution);
      } else {
        state.velocity
          ..setFrom(reflected)
          ..scale(1 + stats.speedGainPerBounce);
        state.bounces++;
      }

      // Push off the surface so the next cast doesn't immediately re-hit.
      state.position.addScaled(hit.normal, _epsilon);

      onBounce(BounceResult(
        segment: hit.segment,
        point: hit.point.clone(),
        bounceIndex: state.bounces,
        dampened: hit.segment.isDampened,
        ghosted: false,
      ));
    }
  }

  RayHit? _raySegment(
    Vector2 origin,
    Vector2 dir,
    double maxDist,
    WallSegment segment,
    double radius,
  ) {
    // Only surfaces facing the ray matter.
    final facing = dir.dot(segment.normal);
    if (facing >= 0) return null;

    // Offset the segment toward the interior by the bullet radius — the
    // center then collides with the offset line exactly when the circle
    // touches the real wall.
    final offsetA = segment.a + segment.normal * radius;
    final offsetB = segment.b + segment.normal * radius;

    final hit = _rayLineSegment(origin, dir, maxDist, offsetA, offsetB);
    if (hit != null) {
      return RayHit(
        segment: segment,
        point: hit.$1,
        distance: hit.$2,
        normal: segment.normal,
      );
    }

    // Endpoint circles close the capsule (corners between segments).
    return _rayEndpointCircle(origin, dir, maxDist, segment, segment.a, radius) ??
        _rayEndpointCircle(origin, dir, maxDist, segment, segment.b, radius);
  }

  (Vector2, double)? _rayLineSegment(
    Vector2 origin,
    Vector2 dir,
    double maxDist,
    Vector2 a,
    Vector2 b,
  ) {
    final seg = b - a;
    final denom = dir.x * seg.y - dir.y * seg.x;
    if (denom.abs() < 1e-12) return null; // parallel

    final diff = a - origin;
    final t = (diff.x * seg.y - diff.y * seg.x) / denom; // along ray
    final u = (diff.x * dir.y - diff.y * dir.x) / denom; // along segment

    if (t < 1e-9 || t > maxDist || u < 0 || u > 1) return null;

    return (origin + dir * t, t);
  }

  RayHit? _rayEndpointCircle(
    Vector2 origin,
    Vector2 dir,
    double maxDist,
    WallSegment segment,
    Vector2 center,
    double radius,
  ) {
    final oc = origin - center;
    final b = oc.dot(dir);
    final c = oc.length2 - radius * radius;
    final disc = b * b - c;
    if (disc < 0) return null;

    final t = -b - math.sqrt(disc);
    if (t < 1e-9 || t > maxDist) return null;

    final point = origin + dir * t;
    final normal = (point - center)..normalize();
    // A corner hit reflects off the corner normal, not the face normal.
    return RayHit(segment: segment, point: point, distance: t, normal: normal);
  }
}
