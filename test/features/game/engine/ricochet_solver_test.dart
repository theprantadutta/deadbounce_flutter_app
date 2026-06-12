import 'package:deadbounce_flutter_app/features/game/engine/arena/arena_catalog.dart';
import 'package:deadbounce_flutter_app/features/game/engine/combat/bullet_state.dart';
import 'package:deadbounce_flutter_app/features/game/engine/combat/bullet_stats.dart';
import 'package:deadbounce_flutter_app/features/game/engine/physics/ricochet_solver.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('reflect', () {
    test('45 degrees in, 45 degrees out', () {
      final v = Vector2(1, 1)..normalize();
      final n = Vector2(0, -1); // floor facing up
      final r = RicochetSolver.reflect(v, n);
      expect(r.x, closeTo(v.x, 1e-9));
      expect(r.y, closeTo(-v.y, 1e-9));
    });

    test('normal incidence inverts', () {
      final r = RicochetSolver.reflect(Vector2(0, 1), Vector2(0, -1));
      expect(r.x, closeTo(0, 1e-9));
      expect(r.y, closeTo(-1, 1e-9));
    });

    test('preserves magnitude', () {
      final v = Vector2(3, 4);
      final r = RicochetSolver.reflect(v, Vector2(0, -1));
      expect(r.length, closeTo(5, 1e-9));
    });
  });

  group('advance', () {
    test('no tunneling at extreme speed through a thin pillar', () {
      final solver =
          RicochetSolver(ArenaCatalog.pillars.buildSegments());
      // Aim straight right through the left pillar (x: 180..260, y 520-680).
      final state = BulletState(
        position: Vector2(40, 600),
        velocity: Vector2(50_000, 0),
      );
      var bounced = false;
      solver.advance(state, BulletStats.base(), 1 / 120, onBounce: (b) {
        bounced = true;
      });
      expect(bounced, isTrue,
          reason: 'a 50k u/s bullet must still hit the pillar face');
      // It reflected back — never inside or past the pillar.
      expect(state.position.x, lessThan(190));
    });

    test('bounce increments count and gains speed (+12%)', () {
      final solver =
          RicochetSolver(ArenaCatalog.cleanRect.buildSegments());
      final state = BulletState(
        position: Vector2(360, 640),
        velocity: Vector2(0, -600),
      );
      solver.advance(state, BulletStats.base(), 1.5, onBounce: (_) {});
      expect(state.bounces, greaterThanOrEqualTo(1));
      // After n bounces speed = 600 * 1.12^n.
      var expected = 600.0;
      for (var i = 0; i < state.bounces; i++) {
        expected *= 1.12;
      }
      expect(state.velocity.length, closeTo(expected, 0.5));
    });

    test('dampened segment bleeds speed and does not increment bounces',
        () {
      final segments = ArenaCatalog.cleanRect.buildSegments();
      // Dampen the top wall.
      final top = segments.firstWhere((s) => s.a.y == 0 && s.b.y == 0);
      top.dampenedBy = 'turret-1';

      final solver = RicochetSolver(segments);
      final state = BulletState(
        position: Vector2(360, 400),
        velocity: Vector2(0, -500),
      );
      BounceResult? result;
      solver.advance(state, BulletStats.base(), 1.0,
          onBounce: (b) => result ??= b);

      expect(result!.dampened, isTrue);
      expect(state.bounces, 0);
      // Speed bled to ~55% on the dampened contact.
      expect(state.velocity.length, closeTo(500 * 0.55, 1));
    });

    test('ghost flag passes through one wall then reflects on the next',
        () {
      final solver =
          RicochetSolver(ArenaCatalog.pillars.buildSegments());
      final state = BulletState(
        position: Vector2(40, 600),
        velocity: Vector2(700, 0),
        flags: BulletFlags(ghostPassesRemaining: 1),
      );
      final events = <BounceResult>[];
      solver.advance(state, BulletStats.base(), 2.0,
          onBounce: events.add);

      expect(events.first.ghosted, isTrue);
      expect(state.flags.ghostPassesRemaining, 0);
      // It traveled past the first pillar face (x > 180).
      final laterReal =
          events.where((e) => !e.ghosted).toList();
      expect(laterReal, isNotEmpty,
          reason: 'after ghosting it must reflect somewhere further on');
    });

    test('expiry rules: max bounces and lifetime', () {
      final stats = BulletStats.base();
      final state = BulletState(
        position: Vector2.zero(),
        velocity: Vector2(1, 0),
      );
      expect(state.isExpired(stats), isFalse);
      state.bounces = stats.maxBounces;
      expect(state.isExpired(stats), isTrue);
      state.bounces = 0;
      state.age = stats.lifetime;
      expect(state.isExpired(stats), isTrue);
    });

    test('damage is zero at bounce 0 and scales per bounce', () {
      final stats = BulletStats.base();
      final state = BulletState(
        position: Vector2.zero(),
        velocity: Vector2(1, 0),
      );
      expect(state.damageFor(stats), 0);
      state.bounces = 1;
      expect(state.damageFor(stats), 1);
      state.bounces = 4;
      expect(state.damageFor(stats), 4);
      // Rubber Walls: damagePerBounce 2.
      expect(state.damageFor(stats.copyWith(damagePerBounce: 2)), 8);
    });
  });
}
