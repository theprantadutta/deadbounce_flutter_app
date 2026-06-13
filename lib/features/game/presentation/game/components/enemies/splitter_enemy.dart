import 'dart:math' as math;
import 'dart:ui';

import '../../../../engine/tuning.dart';
import 'enemy_component.dart';

/// Hexagon that splits into 2 small Drifters on death. 2 HP.
class SplitterEnemy extends EnemyComponent {
  SplitterEnemy({required super.position, super.speedMult, double hpMult = 1})
      : _hpMult = hpMult,
        super(
          maxHp: (Tuning.splitter.hp * hpMult).ceil(),
          bodyRadius: Tuning.splitter.radius,
          color: const Color(0xFF9D5CFF), // violet
        );

  final double _hpMult;
  double _spin = 0;

  @override
  String get enemyId => 'splitter';

  @override
  void updateBehavior(double dt) {
    _spin += dt * 0.8;
    seekPlayer(dt, Tuning.splitter.speed);
    clampToArena();
    if (overlapsPlayer()) game.player.takeContactDamage(this);
  }

  @override
  void die({killer}) {
    // Children spawn through the SpawnDirector so the wave's alive-count
    // stays correct.
    game.spawner.spawnSplitChildren(
      position.clone(),
      speedMult: speedMult,
      hpMult: _hpMult,
    );
    super.die(killer: killer);
  }

  @override
  void renderShape(Canvas canvas) {
    canvas.save();
    canvas.rotate(_spin);
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final p = Offset(
        bodyRadius * math.cos(angle),
        bodyRadius * math.sin(angle),
      );
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFC9A2FF),
    );
    canvas.restore();
  }
}
