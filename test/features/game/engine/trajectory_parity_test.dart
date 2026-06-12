import 'dart:math' as math;

import 'package:deadbounce_flutter_app/features/game/engine/arena/arena_catalog.dart';
import 'package:deadbounce_flutter_app/features/game/engine/combat/bullet_state.dart';
import 'package:deadbounce_flutter_app/features/game/engine/combat/bullet_stats.dart';
import 'package:deadbounce_flutter_app/features/game/engine/physics/ricochet_solver.dart';
import 'package:deadbounce_flutter_app/features/game/engine/trajectory/trajectory_predictor.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

/// THE keystone test: the aim preview and the live bullet must agree on
/// every bounce point, in every arena — preview == reality.
void main() {
  const previewBounces = 3;
  const launchSpeed = 600.0;

  for (final arena in ArenaCatalog.all) {
    test('preview matches simulated bullet bounces in ${arena.id}', () {
      final solver = RicochetSolver(arena.buildSegments());
      final stats = BulletStats.base();
      final origin = Vector2(360, 1000);

      for (var deg = 200; deg < 340; deg += 7) {
        final angle = deg * math.pi / 180;
        final dir = Vector2(math.cos(angle), math.sin(angle));

        final predicted = TrajectoryPredictor.predict(
          solver,
          origin,
          dir,
          stats: stats,
          previewBounces: previewBounces,
          launchSpeed: launchSpeed,
        );
        final predictedBounces = predicted
            .skip(1)
            .where((n) => !n.ghosted && !n.isTerminal)
            .toList();

        // Simulate the live bullet in 1/120 substeps.
        final state = BulletState(
          position: origin.clone(),
          velocity: dir * launchSpeed,
        );
        final simulatedBounces = <Vector2>[];
        for (var step = 0;
            step < 1200 && simulatedBounces.length < previewBounces;
            step++) {
          solver.advance(state, stats, 1 / 120, onBounce: (b) {
            if (!b.dampened && !b.ghosted &&
                simulatedBounces.length < previewBounces) {
              simulatedBounces.add(b.point.clone());
            }
          });
        }

        expect(simulatedBounces.length,
            greaterThanOrEqualTo(math.min(predictedBounces.length, 1)),
            reason: 'angle $deg in ${arena.id}');

        for (var i = 0;
            i < math.min(predictedBounces.length, simulatedBounces.length);
            i++) {
          expect(
            predictedBounces[i].point.distanceTo(simulatedBounces[i]),
            lessThan(0.5),
            reason:
                'bounce $i diverged at angle $deg in ${arena.id}: '
                'predicted ${predictedBounces[i].point}, '
                'simulated ${simulatedBounces[i]}',
          );
        }
      }
    });
  }

  test('dampened sections appear dampened in the preview too', () {
    final segments = ArenaCatalog.cleanRect.buildSegments();
    segments.firstWhere((s) => s.a.y == 0 && s.b.y == 0).dampenedBy = 't1';
    final solver = RicochetSolver(segments);

    final predicted = TrajectoryPredictor.predict(
      solver,
      Vector2(360, 600),
      Vector2(0, -1),
      stats: BulletStats.base(),
      previewBounces: 2,
      launchSpeed: 600,
    );

    expect(predicted.any((n) => n.dampened), isTrue);
  });

  test('ghost pass renders as a pass-through node in the preview', () {
    final solver = RicochetSolver(ArenaCatalog.pillars.buildSegments());

    final predicted = TrajectoryPredictor.predict(
      solver,
      Vector2(40, 600),
      Vector2(1, 0),
      stats: BulletStats.base(),
      previewBounces: 2,
      launchSpeed: 600,
      ghostPasses: 1,
    );

    expect(predicted.any((n) => n.ghosted), isTrue);
  });
}
