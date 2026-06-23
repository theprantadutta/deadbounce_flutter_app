import 'package:flame/components.dart';

import '../physics/wall_segment.dart';

/// Where (and what) a wave may spawn.
class SpawnZone {
  const SpawnZone({required this.rect, this.edge = SpawnEdge.top});

  /// In arena coordinates (origin top-left, 720x1280 logical).
  final ZoneRect rect;
  final SpawnEdge edge;
}

enum SpawnEdge { top, left, right }

/// Plain rect — named to avoid colliding with dart:ui's Rect in
/// component code.
class ZoneRect {
  const ZoneRect(this.left, this.top, this.width, this.height);
  final double left;
  final double top;
  final double width;
  final double height;
}

/// Authored wall geometry for one arena. Data, not code — new arenas are
/// content. Normals are computed in [buildSegments]; authors only list
/// points.
class ArenaDefinition {
  const ArenaDefinition({
    required this.id,
    required this.displayName,
    required this.flavor,
    required this.obstacles,
    required this.playerAnchors,
    required this.spawnZones,
    required this.turretSlotWalls,
    this.cornerCut = 0,
  });

  final String id;
  final String displayName;

  /// One-liner shown on the pre-game loading screen.
  final String flavor;

  /// Closed polygons (counter-clockwise, arena coords) inside the arena —
  /// pillars and the like. Each edge becomes a ricochet surface.
  final List<List<(double, double)>> obstacles;

  /// Exactly 3 dash anchors in the bottom third, left → right.
  final List<(double, double)> playerAnchors;

  final List<SpawnZone> spawnZones;

  /// Indices of boundary walls (0=top, 1=right, 2=bottom, 3=left, then
  /// corner cuts) where Turrets may anchor.
  final List<int> turretSlotWalls;

  /// When > 0, the four corners are cut at 45° with this leg length —
  /// the "angled corners" variant.
  final double cornerCut;

  static const double width = 720;
  static const double height = 1280;

  /// Expands boundary + obstacles into oriented [WallSegment]s. Normals
  /// face the playable interior (computed, never authored).
  List<WallSegment> buildSegments() {
    final segments = <WallSegment>[];
    final center = Vector2(width / 2, height / 2);

    void addWall(Vector2 a, Vector2 b, {required bool isBoundary, int? slot}) {
      // A zero-length edge would NaN the normal — skip degenerate geometry.
      if ((b - a).length2 < 1e-6) return;
      final direction = (b - a)..normalize();
      final normal = Vector2(-direction.y, direction.x);
      // Orient toward the arena center (convex boundary) — for obstacle
      // edges this flips outward correctly below.
      final mid = (a + b)..scale(0.5);
      if (normal.dot(center - mid) < 0) normal.negate();
      segments.add(
        WallSegment(
          a: a,
          b: b,
          normal: normal,
          isBoundary: isBoundary,
          turretSlot: slot,
        ),
      );
    }

    // Boundary (with optional 45° corner cuts).
    final c = cornerCut;
    final boundary = c <= 0
        ? <(Vector2, Vector2)>[
            (Vector2(0, 0), Vector2(width, 0)), // top
            (Vector2(width, 0), Vector2(width, height)), // right
            (Vector2(width, height), Vector2(0, height)), // bottom
            (Vector2(0, height), Vector2(0, 0)), // left
          ]
        : <(Vector2, Vector2)>[
            (Vector2(c, 0), Vector2(width - c, 0)),
            (Vector2(width - c, 0), Vector2(width, c)), // top-right cut
            (Vector2(width, c), Vector2(width, height - c)),
            (Vector2(width, height - c), Vector2(width - c, height)),
            (Vector2(width - c, height), Vector2(c, height)),
            (Vector2(c, height), Vector2(0, height - c)), // bottom-left cut
            (Vector2(0, height - c), Vector2(0, c)),
            (Vector2(0, c), Vector2(c, 0)), // top-left cut
          ];

    for (var i = 0; i < boundary.length; i++) {
      addWall(
        boundary[i].$1,
        boundary[i].$2,
        isBoundary: true,
        slot: turretSlotWalls.contains(i) ? i : null,
      );
    }

    // Obstacles: edges of each polygon. The interior-facing rule for an
    // obstacle is AWAY from the polygon's centroid.
    for (final polygon in obstacles) {
      final points = [for (final (x, y) in polygon) Vector2(x, y)];
      final centroid = points.fold(Vector2.zero(), (acc, p) => acc + p)
        ..scale(1 / points.length);

      for (var i = 0; i < points.length; i++) {
        final a = points[i];
        final b = points[(i + 1) % points.length];
        if ((b - a).length2 < 1e-6) continue; // skip degenerate edge
        final direction = (b - a)..normalize();
        final normal = Vector2(-direction.y, direction.x);
        final mid = (a + b)..scale(0.5);
        if (normal.dot(mid - centroid) < 0) normal.negate();
        segments.add(
          WallSegment(a: a, b: b, normal: normal, isBoundary: false),
        );
      }
    }

    return segments;
  }

  List<Vector2> anchors() => [
    for (final (x, y) in playerAnchors) Vector2(x, y),
  ];
}
