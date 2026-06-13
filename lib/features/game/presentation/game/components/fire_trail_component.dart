import 'dart:ui';

import 'package:flame/components.dart';

import '../../../../../core/theme/app_colors.dart';
import 'deadbounce_game.dart';

/// Incendiary Trail's burning ground hazard: ticks damage on enemies
/// overlapping it until it burns out.
class FireTrailComponent extends PositionComponent
    with HasGameReference<DeadbounceGame> {
  FireTrailComponent({
    required super.position,
    required this.radius,
    required this.duration,
    required this.damagePerSecond,
  }) : super(anchor: Anchor.center, priority: 20);

  final double radius;
  final double duration;
  final int damagePerSecond;

  double _age = 0;
  double _tickAccumulator = 0;
  static const double _tickInterval = 0.25;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= duration) {
      removeFromParent();
      return;
    }

    _tickAccumulator += dt;
    if (_tickAccumulator < _tickInterval) return;
    _tickAccumulator -= _tickInterval;

    final tickDamage = (damagePerSecond * _tickInterval).ceil();
    for (final enemy in game.aliveEnemies) {
      if (enemy.position.distanceTo(position) <
          radius + enemy.bodyRadius) {
        enemy.receiveEnvironmentalDamage(tickDamage);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final life = 1 - (_age / duration);
    canvas.drawCircle(Offset.zero, radius,
        Paint()..color = AppColors.amber600.withValues(alpha: 0.18 * life));
    canvas.drawCircle(Offset.zero, radius * 0.55,
        Paint()..color = AppColors.amber400.withValues(alpha: 0.3 * life));
  }
}
