import 'package:flame/components.dart';

import '../combat/bullet_state.dart';
import '../combat/bullet_stats.dart';
import '../physics/ricochet_solver.dart';
import '../tuning.dart';

/// One node of the predicted path.
class TrajectoryNode {
  const TrajectoryNode({
    required this.point,
    required this.bounceIndex,
    this.dampened = false,
    this.ghosted = false,
    this.isTerminal = false,
  });

  final Vector2 point;

  /// Bounce count at this node (0 = origin/first leg).
  final int bounceIndex;

  /// This node hits a turret-dampened section — render gray, no damage.
  final bool dampened;
  final bool ghosted;

  /// Not a wall contact: the preview's distance budget ran out mid-leg
  /// here. Rendered as a fading line end, never as a bounce ring.
  final bool isTerminal;
}

/// Predicts the aim line by running the SAME solver and bounce rules as
/// live bullets (dampening, ghost passes, speed gain) — parity is
/// structural, then locked in by trajectory_parity_test.
abstract final class TrajectoryPredictor {
  static List<TrajectoryNode> predict(
    RicochetSolver solver,
    Vector2 origin,
    Vector2 direction, {
    required BulletStats stats,
    required int previewBounces,
    required double launchSpeed,
    int ghostPasses = 0,
  }) {
    final nodes = <TrajectoryNode>[
      TrajectoryNode(point: origin.clone(), bounceIndex: 0),
    ];

    // Simulate with a long dt so advance() walks the whole preview
    // distance in one call; bounce/ghost rules apply identically.
    final state = BulletState(
      position: origin.clone(),
      velocity: (direction.normalized())..scale(launchSpeed),
      flags: BulletFlags(ghostPassesRemaining: ghostPasses),
    );

    var bouncesSeen = 0;
    var stop = false;

    final previewStats = stats.copyWith(
      maxBounces: previewBounces + 1,
      lifetime: double.infinity,
    );

    final dt =
        Tuning.trajectory.maxTotalDistance / launchSpeed; // distance budget

    solver.advance(
      state,
      previewStats,
      dt,
      onBounce: (bounce) {
        if (stop) return;
        nodes.add(TrajectoryNode(
          point: bounce.point.clone(),
          bounceIndex: bounce.bounceIndex,
          dampened: bounce.dampened,
          ghosted: bounce.ghosted,
        ));
        if (!bounce.dampened && !bounce.ghosted) {
          bouncesSeen++;
          if (bouncesSeen >= previewBounces) stop = true;
        }
      },
      onSubSegment: (from, to) {
        if (stop) return;
      },
    );

    if (!stop) {
      // Path ended on distance budget — close the polyline at the final
      // position.
      nodes.add(TrajectoryNode(
        point: state.position.clone(),
        bounceIndex: state.bounces,
        isTerminal: true,
      ));
    }

    return nodes;
  }
}
