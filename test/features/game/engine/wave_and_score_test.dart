import 'package:deadbounce_flutter_app/features/game/engine/combat/score_system.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import 'package:deadbounce_flutter_app/features/game/engine/game_rng.dart';
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

    test('chain labels speak Deadbounce', () {
      expect(ScoreSystem.chainLabel(1), isNull);
      expect(ScoreSystem.chainLabel(2), 'DOUBLE KILL');
      expect(ScoreSystem.chainLabel(3), 'TRIPLE KILL');
      expect(ScoreSystem.chainLabel(4), 'QUAD DRAW');
      expect(ScoreSystem.chainLabel(7), 'RICOCHET RAMPAGE');
    });
  });
}
