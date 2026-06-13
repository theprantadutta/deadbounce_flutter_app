import 'dart:math' as math;
import 'dart:ui';


import '../../../../../../core/theme/app_colors.dart';
import '../../../../engine/physics/wall_segment.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import '../enemy_projectile_component.dart';
import 'enemy_component.dart';

/// Anchors to a wall slot and fires slow projectiles the player must
/// dodge or intercept. While alive, its wall section is DAMPENED: bullets
/// reflect weakly off it and gain no bounce — kill it first. 4 HP.
class TurretEnemy extends EnemyComponent {
  TurretEnemy({required super.position, super.speedMult, double hpMult = 1})
      : super(
          maxHp: (GameBalance.I.turret.hp * hpMult).ceil(),
          bodyRadius: GameBalance.I.turret.radius,
          color: const Color(0xFF1FA9FF), // hostile electric blue
        );

  WallSegment? _claimed;
  double _fireTimer = 0;
  double _wallAngle = 0;

  @override
  String get enemyId => 'turret';

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _claimAndAttach();
  }

  void _claimAndAttach() {
    // Nearest free turret slot; falls back to staying where spawned
    // (still functional, just no wall dampening).
    WallSegment? best;
    var bestDist = double.infinity;
    for (final segment in game.segments) {
      if (segment.turretSlot == null || segment.isDampened) continue;
      final d = segment.midpoint.distanceTo(position);
      if (d < bestDist) {
        bestDist = d;
        best = segment;
      }
    }

    if (best != null) {
      best.dampenedBy = '$hashCode';
      _claimed = best;
      // Sit on the wall, pushed inward by the body radius.
      position
        ..setFrom(best.midpoint)
        ..addScaled(best.normal, bodyRadius * 0.8);
      _wallAngle = math.atan2(best.normal.y, best.normal.x);
    }
  }

  @override
  void onRemove() {
    // Bulletproof release — a leaked claim would leave the wall dead
    // forever.
    if (_claimed?.dampenedBy == '$hashCode') {
      _claimed?.dampenedBy = null;
    }
    _claimed = null;
    super.onRemove();
  }

  @override
  void updateBehavior(double dt) {
    _fireTimer += dt;
    if (_fireTimer >= GameBalance.I.turret.fireInterval) {
      _fireTimer = 0;
      final dir = (game.player.position - position)..normalize();
      game.world.add(EnemyProjectileComponent(
        position: position + dir * (bodyRadius + 8),
        velocity: dir * GameBalance.I.turret.projectileSpeed * speedMult,
      ));
    }
    if (overlapsPlayer()) game.player.takeContactDamage(this);
  }

  @override
  void renderShape(Canvas canvas) {
    canvas.save();
    canvas.rotate(_wallAngle + math.pi / 2);

    // Wall-mounted wedge.
    final r = bodyRadius;
    final path = Path()
      ..moveTo(-r, r * 0.8)
      ..lineTo(r, r * 0.8)
      ..lineTo(r * 0.55, -r * 0.9)
      ..lineTo(-r * 0.55, -r * 0.9)
      ..close();
    canvas.drawPath(path, Paint()..color = color);

    // Charging glow toward the next shot.
    final charge =
        (_fireTimer / GameBalance.I.turret.fireInterval).clamp(0.0, 1.0);
    if (charge > 0.6) {
      canvas.drawCircle(
        Offset(0, -r * 0.5),
        r * 0.35,
        Paint()
          ..color = AppColors.blue200
              .withValues(alpha: (charge - 0.6) / 0.4 * 0.9),
      );
    }
    canvas.restore();
  }
}
