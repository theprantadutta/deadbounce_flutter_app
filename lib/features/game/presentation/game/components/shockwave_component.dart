import 'dart:ui';

import 'package:flame/components.dart';

import '../../../../../core/theme/app_colors.dart';
import '../systems/sound_manager.dart';
import 'deadbounce_game.dart';

/// The Powderkeg's death detonation: telegraphs an expanding warning ring
/// over [fuse] seconds (long enough to dash clear), then deals one heart of
/// hazard damage to the player if they're caught inside [radius] at the
/// moment of the blast. A positioning hazard — never an instant gotcha.
class ShockwaveComponent extends PositionComponent
    with HasGameReference<DeadbounceGame> {
  ShockwaveComponent({
    required super.position,
    required this.radius,
    required this.fuse,
  }) : super(anchor: Anchor.center, priority: 18);

  final double radius;
  final double fuse;

  double _age = 0;
  bool _detonated = false;
  static const double _flashDuration = 0.2;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;

    if (!_detonated && _age >= fuse) {
      _detonated = true;
      final reach = radius + game.player.bodyRadius;
      if (game.player.position.distanceTo(position) < reach) {
        game.player.takeHazardDamage('powderkeg');
      }
      game.juice.addTrauma(0.3);
      game.juice.sound.play(Sfx.hurt, volume: 0.7);
    }

    if (_age >= fuse + _flashDuration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    if (_age < fuse) {
      final t = (_age / fuse).clamp(0.0, 1.0);
      // Danger zone fills in as the fuse burns.
      canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()..color = AppColors.error.withValues(alpha: 0.08 + t * 0.12),
      );
      // Outer warning boundary.
      canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppColors.error.withValues(alpha: 0.3 + t * 0.5),
      );
      // Inner ring closing toward the edge — reads the imminent blast.
      canvas.drawCircle(
        Offset.zero,
        radius * t,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = AppColors.amber400.withValues(alpha: 0.6),
      );
    } else {
      final f = 1 - ((_age - fuse) / _flashDuration).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()..color = AppColors.error.withValues(alpha: 0.5 * f),
      );
      canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = AppColors.amber300.withValues(alpha: f),
      );
    }
  }
}
