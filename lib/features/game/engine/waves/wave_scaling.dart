import 'dart:math' as math;

import '../game_rng.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import 'wave_definition.dart';
import 'wave_table.dart';

/// Wave source: authored table for 1..15, composed scaling beyond — runs
/// are endless. Pure (given the rng fork), so daily-challenge runs get
/// identical waves worldwide.
abstract final class WaveScaling {
  static WaveDefinition forWave(int wave, GameRng rng) {
    final t = GameBalance.I.waves;
    if (wave <= t.authoredWaves) {
      return WaveTable.authored[wave - 1];
    }

    // Shallow-then-steep: growth scales with past^exponent (exponent > 1 keeps
    // the curve near-flat just past the authored block, then accelerates).
    // Continues from the authored wave-15 baseline (hp ×1.3, speed ×1.1).
    final past = wave - t.authoredWaves;
    final hpMult =
        1.3 + t.hpGrowthPerWave * math.pow(past, t.hpCurveExponent);
    final speedMult = 1.1 +
        math.min(t.speedGrowthCap,
            t.speedGrowthPerWave * math.pow(past, t.speedCurveExponent));

    final groups = <SpawnGroup>[];
    // First Warden lands on firstWardenWave; thereafter every wardenEvery.
    final isWardenWave = wave >= t.firstWardenWave &&
        (wave - t.firstWardenWave) % t.wardenEvery == 0;
    if (isWardenWave) {
      groups.add(const SpawnGroup(type: EnemyType.warden, count: 1));
    }

    var budget = 8 + (past * t.extraCountPerWave).floor();
    if (isWardenWave) budget = (budget * 0.5).ceil();

    // Roughly even split across the roster, jittered by the seeded rng so
    // late waves vary run to run (but identically for one seed).
    final chargers = math.min(budget ~/ 3, 3 + rng.nextInt(3));
    budget -= chargers;
    final splitters = math.min(budget ~/ 3, 2 + rng.nextInt(3));
    budget -= splitters;
    final turrets = math.min(2, 1 + rng.nextInt(2));
    final drifters = math.max(2, budget);

    groups.addAll([
      SpawnGroup(type: EnemyType.drifter, count: drifters, stagger: 0.4),
      SpawnGroup(type: EnemyType.charger, count: chargers, delay: 2, stagger: 0.9),
      SpawnGroup(type: EnemyType.splitter, count: splitters, delay: 3, stagger: 1),
      SpawnGroup(type: EnemyType.turret, count: turrets, delay: 1, stagger: 2),
    ]);

    return WaveDefinition(
      wave: wave,
      groups: groups,
      hpMult: hpMult,
      speedMult: speedMult,
    );
  }
}
