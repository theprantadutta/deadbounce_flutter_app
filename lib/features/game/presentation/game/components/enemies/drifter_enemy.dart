import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../../../../core/theme/app_colors.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import 'enemy_component.dart';

/// Slow-floating orb that drifts toward the player with a lateral wobble.
/// 1 HP early fodder. The `small` variant is what Splitters break into.
class DrifterEnemy extends EnemyComponent {
  DrifterEnemy({
    required super.position,
    super.speedMult,
    double hpMult = 1,
    this.small = false,
  })  : _wobblePhase = 0,
        super(
          maxHp: (GameBalance.I.drifter.hp * hpMult).ceil(),
          bodyRadius: small
              ? GameBalance.I.drifter.radius * GameBalance.I.drifter.smallScale
              : GameBalance.I.drifter.radius,
          color: const Color(0xFFCC9544), // dim amber
        );

  final bool small;
  double _wobblePhase;
  late final double _phaseOffset =
      game.enemyAiRng.range(0, math.pi * 2);

  @override
  String get enemyId => small ? 'small_drifter' : 'drifter';

  @override
  void updateBehavior(double dt) {
    final t = GameBalance.I.drifter;
    _wobblePhase += dt * t.wobbleFrequency;

    final speed = t.speed * (small ? t.smallSpeedMult : 1.0);
    seekPlayer(dt, speed);

    // Lateral wobble perpendicular to the seek direction.
    final toPlayer = (game.player.position - position)..normalize();
    final lateral = Vector2(-toPlayer.y, toPlayer.x);
    position.addScaled(
      lateral,
      math.sin(_wobblePhase * math.pi * 2 + _phaseOffset) *
          t.wobbleAmplitude *
          dt,
    );

    clampToArena();
    if (overlapsPlayer()) game.player.takeContactDamage(this);
  }

  @override
  void renderShape(Canvas canvas) {
    canvas.drawCircle(Offset.zero, bodyRadius, Paint()..color = color);
    canvas.drawCircle(
      Offset.zero,
      bodyRadius * 0.45,
      Paint()..color = AppColors.amber200.withValues(alpha: 0.8),
    );
  }
}
