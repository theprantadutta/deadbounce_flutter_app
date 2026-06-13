import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../../../core/theme/app_colors.dart';
import 'deadbounce_game.dart';

/// A dropped coin: idles, then magnetizes to the player inside their
/// pickup radius (Coin Magnet widens it).
class CoinPickupComponent extends PositionComponent
    with HasGameReference<DeadbounceGame> {
  CoinPickupComponent({required super.position, required this.value})
      : super(anchor: Anchor.center, priority: 25);

  final int value;
  static const double _radius = 10;
  static const double _magnetSpeed = 520;
  static const double _lifetime = 9;

  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    if (_age >= _lifetime) {
      removeFromParent();
      return;
    }

    final toPlayer = game.player.position - position;
    final pickupRadius =
        game.modifiers.effectivePlayerStats().coinPickupRadius;

    if (toPlayer.length < game.player.bodyRadius + _radius) {
      game.collectCoin(value, position.clone());
      removeFromParent();
      return;
    }

    if (toPlayer.length < pickupRadius) {
      toPlayer.normalize();
      position.addScaled(toPlayer, _magnetSpeed * dt);
    }
  }

  @override
  void render(Canvas canvas) {
    final blink = _age > _lifetime - 2 && (_age * 6).floor().isEven;
    if (blink) return;
    final bob = math.sin(_age * 5) * 2;
    canvas.drawCircle(Offset(0, bob), _radius * 1.7,
        Paint()..color = AppColors.amber400.withValues(alpha: 0.18));
    canvas.drawCircle(
        Offset(0, bob), _radius, Paint()..color = AppColors.amber400);
    canvas.drawCircle(Offset(-2, bob - 2), _radius * 0.35,
        Paint()..color = AppColors.amber100);
  }
}
