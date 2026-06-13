import 'wave_definition.dart';

/// Authored waves 1–15, deliberately a gentle on-ramp.
///
/// Difficulty philosophy (also in CLAUDE.md): **the first 3 waves must feel
/// trivial** — only slow Drifters, generous spacing — then difficulty stays
/// near-flat and accelerates later. Enemy introductions: Drifter w1, Charger
/// w4 (long telegraph), Splitter w6, Turret w8, first Warden w10. Beyond 15,
/// WaveScaling composes endless waves.
abstract final class WaveTable {
  static const List<WaveDefinition> authored = [
    // --- Waves 1–3: tutorial-easy. Drifters only, slowed, lots of space. ---
    WaveDefinition(wave: 1, groups: [
      SpawnGroup(type: EnemyType.drifter, count: 2, stagger: 1.4),
    ], speedMult: 0.8),
    WaveDefinition(wave: 2, groups: [
      SpawnGroup(type: EnemyType.drifter, count: 3, stagger: 1.2),
    ], speedMult: 0.85),
    WaveDefinition(wave: 3, groups: [
      SpawnGroup(type: EnemyType.drifter, count: 4, stagger: 1.0),
    ], speedMult: 0.9),
    // --- Waves 4–6: gentle introduction. Charger (long telegraph), Splitter. ---
    WaveDefinition(wave: 4, groups: [
      SpawnGroup(type: EnemyType.drifter, count: 4, stagger: 0.9),
      SpawnGroup(type: EnemyType.charger, count: 1, delay: 3),
    ]),
    WaveDefinition(wave: 5, groups: [
      SpawnGroup(type: EnemyType.drifter, count: 5, stagger: 0.8),
      SpawnGroup(type: EnemyType.charger, count: 1, delay: 2.5),
    ]),
    WaveDefinition(wave: 6, groups: [
      SpawnGroup(type: EnemyType.drifter, count: 4, stagger: 0.7),
      SpawnGroup(type: EnemyType.splitter, count: 1, delay: 2.5),
    ]),
    // --- Waves 7+: the real ramp begins. ---
    WaveDefinition(wave: 7, groups: [
      SpawnGroup(type: EnemyType.splitter, count: 2, stagger: 1.2),
      SpawnGroup(type: EnemyType.charger, count: 2, delay: 2.5, stagger: 1),
    ]),
    WaveDefinition(wave: 8, groups: [
      SpawnGroup(type: EnemyType.turret, count: 1),
      SpawnGroup(type: EnemyType.drifter, count: 5, delay: 1.5, stagger: 0.6),
    ]),
    WaveDefinition(wave: 9, groups: [
      SpawnGroup(type: EnemyType.turret, count: 1),
      SpawnGroup(type: EnemyType.splitter, count: 2, delay: 1, stagger: 1.2),
      SpawnGroup(type: EnemyType.charger, count: 2, delay: 3, stagger: 1),
    ]),
    WaveDefinition(wave: 10, groups: [
      SpawnGroup(type: EnemyType.warden, count: 1), // first mini-boss
      SpawnGroup(type: EnemyType.charger, count: 2, delay: 4, stagger: 1.5),
    ], hpMult: 1.05),
    WaveDefinition(wave: 11, groups: [
      SpawnGroup(type: EnemyType.drifter, count: 8, stagger: 0.4),
      SpawnGroup(type: EnemyType.splitter, count: 3, delay: 2, stagger: 1),
    ], hpMult: 1.1),
    WaveDefinition(wave: 12, groups: [
      SpawnGroup(type: EnemyType.turret, count: 2, stagger: 2),
      SpawnGroup(type: EnemyType.charger, count: 3, delay: 2, stagger: 0.9),
    ], hpMult: 1.15),
    WaveDefinition(wave: 13, groups: [
      SpawnGroup(type: EnemyType.splitter, count: 4, stagger: 0.8),
      SpawnGroup(type: EnemyType.drifter, count: 6, delay: 3, stagger: 0.4),
    ], hpMult: 1.2, speedMult: 1.05),
    WaveDefinition(wave: 14, groups: [
      SpawnGroup(type: EnemyType.turret, count: 2, stagger: 2),
      SpawnGroup(type: EnemyType.splitter, count: 3, delay: 1.5, stagger: 1),
      SpawnGroup(type: EnemyType.charger, count: 2, delay: 4, stagger: 1),
    ], hpMult: 1.25, speedMult: 1.05),
    WaveDefinition(wave: 15, groups: [
      SpawnGroup(type: EnemyType.warden, count: 1),
      SpawnGroup(type: EnemyType.turret, count: 1, delay: 2),
      SpawnGroup(type: EnemyType.drifter, count: 6, delay: 4, stagger: 0.5),
    ], hpMult: 1.3, speedMult: 1.1),
  ];
}
