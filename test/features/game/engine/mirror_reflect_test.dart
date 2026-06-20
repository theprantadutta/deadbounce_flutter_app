import 'package:deadbounce_flutter_app/features/game/engine/combat/bullet_state.dart';
import 'package:deadbounce_flutter_app/features/game/engine/combat/bullet_stats.dart';
import 'package:deadbounce_flutter_app/features/game/engine/physics/ricochet_solver.dart';
import 'package:deadbounce_flutter_app/features/game/engine/physics/wall_segment.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Mirror enemy models its reflecting face as a one-sided WallSegment
/// fed to the same solver the aim preview uses. These tests lock the two
/// properties that make it work: the FRONT reflects (and counts as a real
/// bounce — a free-bounce tool), the BACK passes through (so a wall-bounced
/// shot can reach the body to kill it).
void main() {
  // A horizontal mirror at y=300 spanning x 250..350, normal pointing down
  // (0,1) — toward the player, who sits below.
  WallSegment mirror() => WallSegment(
        a: Vector2(250, 300),
        b: Vector2(350, 300),
        normal: Vector2(0, 1),
        isBoundary: false,
        isMirror: true,
      );

  group('mirror face', () {
    test('a shot from the front (player side) reflects and counts a bounce',
        () {
      final solver = RicochetSolver([mirror()]);
      final state = BulletState(
        position: Vector2(300, 360), // below the mirror
        velocity: Vector2(0, -600), // travelling up into the front
      );
      var bounced = false;
      // Enough time to cover the ~50px gap to the mirror and reflect back.
      solver.advance(state, BulletStats.base(), 0.2,
          onBounce: (b) => bounced = true);

      expect(bounced, isTrue, reason: 'front face must reflect the shot');
      expect(state.bounces, 1, reason: 'a mirror reflection is a real bounce');
      expect(state.velocity.y, greaterThan(0),
          reason: 'bullet should be sent back down after reflecting');
    });

    test('a shot from behind passes through (so the body is killable)', () {
      final solver = RicochetSolver([mirror()]);
      final hit = solver.castRay(
        Vector2(300, 240), // above the mirror (its back)
        Vector2(0, 1), // travelling down toward the back face
        200,
        radius: BulletStats.base().radius,
      );
      expect(hit, isNull,
          reason: 'the back face is non-reflecting — the shot passes through');
    });
  });
}
