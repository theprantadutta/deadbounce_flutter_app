import 'dart:math' as math;
import 'dart:ui';

import '../../../../../core/theme/app_colors.dart';
import '../../../engine/combat/bullet_state.dart';
import 'bullet_component.dart';
import 'enemies/enemy_component.dart';

/// A trick-shot target: a static ring cleared only by a bullet carrying at
/// least [requiredBounces] ricochets. Reuses the enemy sweep/hit path but is
/// inert otherwise — no movement, no contact damage, no economy.
class TrickShotTargetComponent extends EnemyComponent {
  TrickShotTargetComponent({
    required super.position,
    required this.requiredBounces,
  }) : super(
          maxHp: 1,
          bodyRadius: 32,
          color: AppColors.blue300,
        );

  final int requiredBounces;
  bool _hit = false;
  double _pulse = 0;

  bool get isHit => _hit;

  @override
  String get enemyId => 'trickshot_target';

  /// Only a sufficiently-bounced bullet can clear it.
  @override
  bool canBeDamagedBy(BulletState bullet) =>
      bullet.bounces >= requiredBounces;

  @override
  bool receiveHit(int damage, BulletComponent bullet) {
    if (_hit || bullet.state.bounces < requiredBounces) return false;
    _hit = true;
    game.onTrickShotTargetHit(this);
    removeFromParent();
    return true;
  }

  @override
  void updateBehavior(double dt) {
    _pulse += dt * 2.5; // gentle idle pulse; static, never seeks/contacts
  }

  @override
  void renderShape(Canvas canvas) {
    final r = bodyRadius;
    final pulse = 0.5 + 0.5 * math.sin(_pulse);

    // Concentric bullseye rings.
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset.zero,
        r * (1 - i * 0.28),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = (i.isEven ? AppColors.blue300 : AppColors.amber300)
              .withValues(alpha: 0.55 + pulse * 0.35),
      );
    }
    // Required-bounce pips clustered in the bullseye.
    for (var i = 0; i < requiredBounces; i++) {
      final angle = -math.pi / 2 + i * (2 * math.pi / requiredBounces);
      final at = requiredBounces == 1
          ? Offset.zero
          : Offset(math.cos(angle), math.sin(angle)) * (r * 0.22);
      canvas.drawCircle(at, 4, Paint()..color = AppColors.amber200);
    }
  }
}
