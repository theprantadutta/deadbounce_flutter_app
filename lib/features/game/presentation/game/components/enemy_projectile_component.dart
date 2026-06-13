import 'dart:ui';

import 'package:flame/components.dart';

import '../../../../../core/theme/app_colors.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import 'deadbounce_game.dart';

/// A Turret's slow shot: dodge it or shoot it down — player bullets
/// destroy it at ANY bounce count (interception is always rewarded).
class EnemyProjectileComponent extends PositionComponent
    with HasGameReference<DeadbounceGame> {
  EnemyProjectileComponent({
    required super.position,
    required this.velocity,
  }) : super(anchor: Anchor.center, priority: 35);

  final Vector2 velocity;
  double get radius => GameBalance.I.turret.projectileRadius;

  double _pulse = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt;
    position.addScaled(velocity, dt);

    // Out of bounds → gone.
    if (position.x < -40 ||
        position.x > DeadbounceGame.arenaWidth + 40 ||
        position.y < -40 ||
        position.y > DeadbounceGame.arenaHeight + 40) {
      removeFromParent();
      return;
    }

    // Player contact.
    if (position.distanceTo(game.player.position) <
        radius + game.player.bodyRadius) {
      game.player.takeProjectileDamage(this);
      removeFromParent();
      return;
    }

    // Intercepted by any player bullet (any bounce count).
    for (final bullet in game.aliveBullets) {
      if (position.distanceTo(bullet.position) <
          radius + bullet.stats.radius) {
        game.particles.passThroughPing(position.clone());
        removeFromParent();
        return;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final pulse = 0.7 + 0.3 * (_pulse * 6).remainder(1.0);
    canvas.drawCircle(Offset.zero, radius * 1.8,
        Paint()..color = AppColors.blue400.withValues(alpha: 0.2 * pulse));
    canvas.drawCircle(
        Offset.zero, radius, Paint()..color = AppColors.blue400);
    canvas.drawCircle(Offset.zero, radius * 0.45,
        Paint()..color = const Color(0xFFFFFFFF));
  }
}
