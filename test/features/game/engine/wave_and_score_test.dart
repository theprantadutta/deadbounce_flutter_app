import 'package:deadbounce_flutter_app/features/game/engine/arena/arena_definition.dart';
import 'package:deadbounce_flutter_app/features/game/engine/combat/score_system.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import 'package:deadbounce_flutter_app/features/game/engine/game_rng.dart';
import 'package:deadbounce_flutter_app/features/game/engine/waves/spawn_formation.dart';
import 'package:deadbounce_flutter_app/features/game/engine/waves/wave_definition.dart';
import 'package:deadbounce_flutter_app/features/game/engine/waves/wave_scaling.dart';
import 'package:deadbounce_flutter_app/features/game/engine/waves/wave_table.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Reset the live config before each test so a mutation in one test (or the
  // debug tuning panel during a real session) can never leak into another.
  setUp(GameBalance.I.resetToDefaults);

  group('waves', () {
    test('authored waves come from the table verbatim', () {
      final rng = GameRng(1).fork('waves');
      for (var w = 1; w <= 15; w++) {
        expect(WaveScaling.forWave(w, rng), same(WaveTable.authored[w - 1]));
      }
    });

    test('first Warden is wave 10, then every 5th (authored and composed)', () {
      final rng = GameRng(1).fork('waves');
      for (final w in [10, 15, 20, 25, 40]) {
        final def = WaveScaling.forWave(w, rng);
        expect(def.groups.any((g) => g.type == EnemyType.warden), isTrue,
            reason: 'wave $w must include a Warden');
      }
      // The early game stays kind: no Warden before wave 10, none off-cadence.
      for (final w in [5, 9, 16, 17, 23]) {
        final def = WaveScaling.forWave(w, rng);
        expect(def.groups.any((g) => g.type == EnemyType.warden), isFalse,
            reason: 'wave $w must NOT include a Warden');
      }
    });

    test('composed waves scale monotonically in hp and respect speed cap',
        () {
      final rng = GameRng(1).fork('waves');
      double? lastHp;
      for (var w = 16; w <= 80; w++) {
        final def = WaveScaling.forWave(w, rng);
        if (lastHp != null) {
          expect(def.hpMult, greaterThan(lastHp));
        }
        lastHp = def.hpMult;
        expect(def.speedMult,
            lessThanOrEqualTo(1.1 + GameBalance.I.waves.speedGrowthCap + 1e-9));
        expect(def.totalCount, greaterThan(0));
      }
    });

    test('late scaling lifts the speed cap and stays under it', () {
      final rng = GameRng(1).fork('waves');
      // Speed climbs past the OLD 0.6 cap now that it's lifted to 1.2.
      final late = WaveScaling.forWave(120, rng);
      expect(late.speedMult, greaterThan(1.1 + 0.6));
      // ...but never past the configured ceiling.
      expect(late.speedMult,
          lessThanOrEqualTo(1.1 + GameBalance.I.waves.speedGrowthCap + 1e-9));
    });

    test('endless roster can field the new fast archetypes', () {
      final rng = GameRng(9).fork('waves');
      final types = <EnemyType>{};
      for (var w = 16; w <= 200; w++) {
        for (final g in WaveScaling.forWave(w, rng).groups) {
          types.add(g.type);
        }
      }
      expect(types, contains(EnemyType.skitter));
      expect(types, contains(EnemyType.lancer));
    });

    test('same seed composes identical late waves (daily challenge)', () {
      final a = WaveScaling.forWave(30, GameRng(77).fork('waves'));
      final b = WaveScaling.forWave(30, GameRng(77).fork('waves'));
      expect(a.totalCount, b.totalCount);
      expect(a.groups.length, b.groups.length);
      for (var i = 0; i < a.groups.length; i++) {
        expect(a.groups[i].type, b.groups[i].type);
        expect(a.groups[i].count, b.groups[i].count);
      }
    });
  });

  group('draft cadence', () {
    bool draft(int w) =>
        WaveScaling.shouldDraft(w, everyWaveUntil: 5, cadence: 2);

    test('drafts every wave through the early cap', () {
      for (var w = 1; w <= 5; w++) {
        expect(draft(w), isTrue, reason: 'wave $w should draft');
      }
    });

    test('then only every Nth wave (fewer hard pauses)', () {
      expect(draft(6), isFalse);
      expect(draft(7), isTrue);
      expect(draft(8), isFalse);
      expect(draft(9), isTrue);
    });

    test('a cadence of 1 keeps drafting every wave (guarded against 0)', () {
      expect(WaveScaling.shouldDraft(8, everyWaveUntil: 5, cadence: 1), isTrue);
      expect(WaveScaling.shouldDraft(8, everyWaveUntil: 5, cadence: 0), isTrue);
    });
  });

  group('spawn formations', () {
    GameRng rng() => GameRng(42).fork('spawn');

    test('empty for non-positive counts', () {
      expect(SpawnFormations.offsets(
              SpawnFormation.line, SpawnEdge.top, 0, rng()),
          isEmpty);
    });

    test('a top-edge line is a horizontal, centered, evenly-spaced row', () {
      final offs =
          SpawnFormations.offsets(SpawnFormation.line, SpawnEdge.top, 5, rng());
      expect(offs.length, 5);
      // Parallel to the top edge → no inward (y) component.
      for (final o in offs) {
        expect(o.y, 0);
      }
      // Strictly increasing along x, and symmetric about the anchor.
      for (var i = 1; i < offs.length; i++) {
        expect(offs[i].x, greaterThan(offs[i - 1].x));
      }
      expect(offs.first.x, closeTo(-offs.last.x, 1e-9));
      expect(offs[2].x, closeTo(0, 1e-9)); // odd count → middle on anchor
      expect(offs[1].x - offs[0].x, closeTo(SpawnFormations.spacing, 1e-9));
    });

    test('a side-edge line runs vertically (parallel to that edge)', () {
      final offs = SpawnFormations.offsets(
          SpawnFormation.line, SpawnEdge.left, 4, rng());
      for (final o in offs) {
        expect(o.x, 0); // no horizontal spread
      }
      for (var i = 1; i < offs.length; i++) {
        expect(offs[i].y, greaterThan(offs[i - 1].y));
      }
    });

    test('a wedge pushes the ends inward (arrowhead), center on the anchor',
        () {
      final offs = SpawnFormations.offsets(
          SpawnFormation.wedge, SpawnEdge.top, 5, rng());
      expect(offs[2].y, closeTo(0, 1e-9)); // apex at the anchor
      expect(offs.first.y, greaterThan(0)); // ends deeper into the arena
      expect(offs.last.y, greaterThan(0));
      expect(offs.first.y, closeTo(offs.last.y, 1e-9)); // symmetric arrowhead
    });

    test('a cluster stays tight and is deterministic for one seed', () {
      final a = SpawnFormations.offsets(
          SpawnFormation.cluster, SpawnEdge.top, 4, GameRng(7).fork('spawn'));
      final b = SpawnFormations.offsets(
          SpawnFormation.cluster, SpawnEdge.top, 4, GameRng(7).fork('spawn'));
      expect(a.length, 4);
      for (var i = 0; i < a.length; i++) {
        expect(a[i].x, b[i].x); // same seed → identical worldwide
        expect(a[i].y, b[i].y);
        expect(a[i].length, lessThan(SpawnFormations.spacing));
      }
    });
  });

  group('score system', () {
    test('kill score scales with bounce multiplier', () {
      final s = ScoreSystem();
      s.registerKill(bulletId: 1, bounces: 0, now: 0);
      final base = GameBalance.I.score.killBase;
      expect(s.score, base);

      final s2 = ScoreSystem();
      s2.registerKill(bulletId: 1, bounces: 4, now: 0);
      expect(s2.score,
          (base * (1 + GameBalance.I.score.bounceFactor * 4)).round());
      expect(s2.maxBounceKill, 4);
    });

    test('chains group kills by the same bullet within the window', () {
      final s = ScoreSystem();
      expect(s.registerKill(bulletId: 7, bounces: 2, now: 0), 1);
      expect(s.registerKill(bulletId: 7, bounces: 2, now: 0.5), 2);
      expect(s.registerKill(bulletId: 7, bounces: 2, now: 1.2), 3);
      expect(s.bestChain, 3);

      // Outside the window: chain resets.
      expect(s.registerKill(bulletId: 7, bounces: 2, now: 5), 1);

      // A different bullet never joins the chain.
      expect(s.registerKill(bulletId: 8, bounces: 2, now: 5.1), 1);
    });

    test("chain window bonus (Gunfighter's Memory) extends the runway", () {
      final base = GameBalance.I.score.chainWindow; // 1.4
      final s = ScoreSystem(chainWindowBonus: 0.3);
      expect(s.registerKill(bulletId: 1, bounces: 1, now: 0), 1);
      // base+0.2 is beyond the base window but within the extended one.
      expect(s.registerKill(bulletId: 1, bounces: 1, now: base + 0.2), 2);

      // Without the bonus, that same gap breaks the chain.
      final plain = ScoreSystem();
      expect(plain.registerKill(bulletId: 1, bounces: 1, now: 0), 1);
      expect(plain.registerKill(bulletId: 1, bounces: 1, now: base + 0.2), 1);
    });

    test('chain labels speak Deadbounce', () {
      expect(ScoreSystem.chainLabel(1), isNull);
      expect(ScoreSystem.chainLabel(2), 'DOUBLE KILL');
      expect(ScoreSystem.chainLabel(3), 'TRIPLE KILL');
      expect(ScoreSystem.chainLabel(4), 'QUAD DRAW');
      expect(ScoreSystem.chainLabel(7), 'RICOCHET RAMPAGE');
    });
  });
}
