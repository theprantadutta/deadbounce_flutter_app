import 'package:flame/components.dart';

import '../arena/arena_definition.dart';
import '../game_rng.dart';
import 'wave_definition.dart';

/// Pure layout math for [SpawnFormation]: given the count of members and the
/// spawn edge they come from, returns one offset per member (relative to the
/// group's shared anchor point) arranged as the requested shape.
///
/// The spread axis runs parallel to the spawn edge; [SpawnFormation.wedge] and
/// [SpawnFormation.cluster] also push inward (into the arena). Deterministic
/// given the [GameRng] so daily-challenge waves are identical worldwide. Kept
/// out of any Flame component so it's unit-testable like the rest of the engine.
abstract final class SpawnFormations {
  /// Distance between adjacent members in a line/wedge (px). Wide enough that a
  /// bounced bullet's damage line can thread several, tight enough that the
  /// shape reads as one formation.
  static const double spacing = 70;

  /// Offsets (from the anchor) for each member of a [formation] of [count]
  /// enemies entering from [edge]. Length always equals `max(count, 0)`.
  static List<Vector2> offsets(
    SpawnFormation formation,
    SpawnEdge edge,
    int count,
    GameRng rng,
  ) {
    if (count <= 0) return const [];

    // `along` runs parallel to the edge; `inward` points into the arena.
    final along = edge == SpawnEdge.top ? Vector2(1, 0) : Vector2(0, 1);
    final inward = switch (edge) {
      SpawnEdge.top => Vector2(0, 1),
      SpawnEdge.left => Vector2(1, 0),
      SpawnEdge.right => Vector2(-1, 0),
    };

    final mid = (count - 1) / 2.0; // centers the shape on the anchor
    final result = <Vector2>[];
    for (var i = 0; i < count; i++) {
      final lane = i - mid;
      switch (formation) {
        case SpawnFormation.scattered:
        case SpawnFormation.line:
          result.add(along * (lane * spacing));
        case SpawnFormation.wedge:
          result.add(along * (lane * spacing) +
              inward * (lane.abs() * spacing * 0.6));
        case SpawnFormation.cluster:
          // A tight seeded blob; separation steering blooms it into an arc.
          result.add(along * (rng.range(-1, 1) * spacing * 0.7) +
              inward * (rng.range(-1, 1) * spacing * 0.7));
      }
    }
    return result;
  }
}
