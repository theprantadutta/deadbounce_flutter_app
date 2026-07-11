import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import 'package:deadbounce_flutter_app/features/game/engine/arena/arena_catalog.dart';
import 'package:deadbounce_flutter_app/features/game/engine/arena/arena_definition.dart';
import 'package:deadbounce_flutter_app/features/game/engine/trickshot/trickshot_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ray-casting point-in-polygon. [poly] is a list of (x, y) vertices.
bool _inside(double px, double py, List<(double, double)> poly) {
  var hit = false;
  for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    final (xi, yi) = poly[i];
    final (xj, yj) = poly[j];
    final intersects = (yi > py) != (yj > py) &&
        px < (xj - xi) * (py - yi) / (yj - yi) + xi;
    if (intersects) hit = !hit;
  }
  return hit;
}

void main() {
  setUp(GameBalance.I.resetToDefaults);

  test('every level is authored sanely and every target is reachable', () {
    final ids = <String>{};
    expect(TrickShotCatalog.levels.length, greaterThanOrEqualTo(20),
        reason: 'Phase 3 target: 20+ trick-shot levels');

    for (final level in TrickShotCatalog.levels) {
      expect(ids.add(level.id), isTrue, reason: 'duplicate id ${level.id}');

      final arena = ArenaCatalog.byId(level.arenaId);
      expect(arena.id, level.arenaId,
          reason: '${level.id} references unknown arena ${level.arenaId}');
      expect(level.targets, isNotEmpty, reason: '${level.id} has no targets');

      for (final t in level.targets) {
        // Reachable-bounce floor within the bullet's max bounces.
        expect(t.requiredBounces, inInclusiveRange(1, GameBalance.I.bullet.maxBounces),
            reason: '${level.id} target requiredBounces out of range');

        // Inside the arena, with a small margin off the walls.
        expect(t.position.x, inInclusiveRange(20.0, ArenaDefinition.width - 20),
            reason: '${level.id} target off-arena in x');
        expect(t.position.y, inInclusiveRange(20.0, ArenaDefinition.height - 20),
            reason: '${level.id} target off-arena in y');

        // Never buried inside an obstacle (would be unhittable).
        for (final poly in arena.obstacles) {
          expect(_inside(t.position.x, t.position.y, poly), isFalse,
              reason: '${level.id} target ${t.position} sits inside an '
                  'obstacle of ${arena.id}');
        }
      }
    }
  });
}
