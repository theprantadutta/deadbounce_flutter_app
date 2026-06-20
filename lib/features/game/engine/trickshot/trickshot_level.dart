import 'package:flame/components.dart';

/// One target in a trick-shot level: a ring the player must strike with a
/// bullet carrying at least [requiredBounces] bounces. Positions are in
/// arena coordinates (720 × 1280).
class TrickShotTarget {
  const TrickShotTarget({
    required this.position,
    required this.requiredBounces,
  });

  final Vector2 position;
  final int requiredBounces;
}

/// A curated bounce puzzle: hit every target with the required number of
/// ricochets. No enemies, no waves — pure aim mastery. [par] is the
/// suggested total shots; [hint] coaches the intended solution.
class TrickShotLevel {
  const TrickShotLevel({
    required this.id,
    required this.name,
    required this.arenaId,
    required this.targets,
    required this.par,
    required this.hint,
  });

  final String id;
  final String name;
  final String arenaId;
  final List<TrickShotTarget> targets;

  /// Suggested shot count to clear the level (the "par").
  final int par;
  final String hint;
}
