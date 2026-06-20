import 'dart:ui';

import 'package:flame/components.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../engine/arena/arena_definition.dart';
import '../../../engine/game_rng.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';

import '../../../engine/physics/vector_utils.dart';
import '../../../engine/waves/wave_definition.dart';
import '../components/deadbounce_game.dart';
import '../components/enemies/charger_enemy.dart';
import '../components/enemies/drifter_enemy.dart';
import '../components/enemies/enemy_component.dart';
import '../components/enemies/ironhide_enemy.dart';
import '../components/enemies/mirror_enemy.dart';
import '../components/enemies/powderkeg_enemy.dart';
import '../components/enemies/sawbones_enemy.dart';
import '../components/enemies/splitter_enemy.dart';
import '../components/enemies/turret_enemy.dart';
import '../components/enemies/warden_enemy.dart';

/// Places enemies: picks positions from the arena's spawn zones (seeded
/// rng), shows a 0.6s telegraph glyph for fairness, applies wave
/// multipliers, and tracks the alive count for wave-clear detection.
class SpawnDirector {
  SpawnDirector({
    required this._game,
    required this._arena,
    required GameRng spawnRng,
  }) : _rng = spawnRng;

  final DeadbounceGame _game;
  final ArenaDefinition _arena;
  final GameRng _rng;

  int _pendingSpawns = 0;
  int _wardenAppearances = 0;

  /// Enemies alive or mid-telegraph — zero means the wave is clear.
  int get activeCount =>
      _game.aliveEnemies.length + _pendingSpawns;

  Vector2 _pickSpawnPosition() {
    final zone = _rng.pick(_arena.spawnZones);
    return Vector2(
      zone.rect.left + _rng.nextDouble() * zone.rect.width,
      zone.rect.top + _rng.nextDouble() * zone.rect.height,
    );
  }

  /// Telegraphed spawn: glyph fades in, then the enemy materializes.
  void spawnTelegraphed(EnemyType type,
      {required double hpMult, required double speedMult}) {
    final position = _pickSpawnPosition();
    _pendingSpawns++;
    _game.world.add(_SpawnTelegraph(
      position: position,
      duration: GameBalance.I.waves.spawnTelegraph,
      onSpawn: () {
        _pendingSpawns--;
        if (_game.runEnded) return;
        _game.world
            .add(_build(type, position, hpMult: hpMult, speedMult: speedMult));
      },
    ));
  }

  /// Splitter children skip the telegraph — they burst out of the parent.
  void spawnSplitChildren(Vector2 origin,
      {required double speedMult, required double hpMult}) {
    const spread = 1.0;
    for (final side in [-1.0, 1.0]) {
      final offset = Vector2(side * GameBalance.I.splitter.childSpread / 2, 0)
        ..rotateBy(_rng.range(-spread, spread));
      final child = DrifterEnemy(
        position: origin + offset,
        speedMult: speedMult,
        hpMult: hpMult,
        small: true,
      );
      _game.world.add(child);
    }
  }

  EnemyComponent _build(EnemyType type, Vector2 position,
      {required double hpMult, required double speedMult}) {
    switch (type) {
      case EnemyType.drifter:
        return DrifterEnemy(
            position: position, speedMult: speedMult, hpMult: hpMult);
      case EnemyType.smallDrifter:
        return DrifterEnemy(
            position: position,
            speedMult: speedMult,
            hpMult: hpMult,
            small: true);
      case EnemyType.charger:
        return ChargerEnemy(
            position: position, speedMult: speedMult, hpMult: hpMult);
      case EnemyType.splitter:
        return SplitterEnemy(
            position: position, speedMult: speedMult, hpMult: hpMult);
      case EnemyType.turret:
        return TurretEnemy(
            position: position, speedMult: speedMult, hpMult: hpMult);
      case EnemyType.warden:
        return WardenEnemy(
          position: position,
          speedMult: speedMult,
          hpMult: hpMult,
          appearance: _wardenAppearances++,
        );
      case EnemyType.powderkeg:
        return PowderkegEnemy(
            position: position, speedMult: speedMult, hpMult: hpMult);
      case EnemyType.sawbones:
        return SawbonesEnemy(
            position: position, speedMult: speedMult, hpMult: hpMult);
      case EnemyType.ironhide:
        return IronhideEnemy(
            position: position, speedMult: speedMult, hpMult: hpMult);
      case EnemyType.mirror:
        return MirrorEnemy(
            position: position, speedMult: speedMult, hpMult: hpMult);
    }
  }
}

class _SpawnTelegraph extends PositionComponent {
  _SpawnTelegraph({
    required super.position,
    required this.duration,
    required this.onSpawn,
  }) : super(anchor: Anchor.center, priority: 10);

  final double duration;
  final VoidCallback onSpawn;
  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= duration) {
      onSpawn();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / duration).clamp(0.0, 1.0);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = AppColors.blue300.withValues(alpha: 0.25 + t * 0.55);
    // Contracting targeting glyph.
    final r = 36 * (1 - t * 0.5);
    canvas.drawCircle(Offset.zero, r, paint);
    for (var i = 0; i < 4; i++) {
      canvas.save();
      canvas.rotate(i * 1.5708 + t * 2);
      canvas.drawLine(Offset(0, -r - 8), Offset(0, -r + 4), paint);
      canvas.restore();
    }
  }
}
