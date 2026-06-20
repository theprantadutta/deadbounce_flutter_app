import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../engine/combat/bullet_state.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import '../../systems/sound_manager.dart';
import '../bullet_component.dart';
import '../popup_text_component.dart';
import 'enemy_component.dart';

/// An armored brute whose shield always faces the player: bullets striking
/// the frontal arc CLANG off harmlessly. Crack it from the side or back —
/// which on this arena means bouncing a shot in behind it. Reinforces the
/// bounce-for-damage loop; never grants flat damage.
class IronhideEnemy extends EnemyComponent {
  IronhideEnemy({required super.position, super.speedMult, double hpMult = 1})
      : super(
          maxHp: (GameBalance.I.ironhide.hp * hpMult).ceil(),
          bodyRadius: GameBalance.I.ironhide.radius,
          color: const Color(0xFF6B7280), // gunmetal
        );

  /// Unit vector toward the player — the shielded front. Recomputed each frame.
  final Vector2 _facing = Vector2(0, 1);
  double _hitClang = 0; // brief flash after a blocked hit

  @override
  String get enemyId => 'ironhide';

  /// Half the shield arc, in radians.
  double get _halfArc =>
      (GameBalance.I.ironhide.shieldArcDegrees / 2) * math.pi / 180;

  bool _isFrontal(Vector2 bulletPosition) {
    final toBullet = bulletPosition - position;
    if (toBullet.length2 < 1e-6) return true;
    toBullet.normalize();
    return toBullet.dot(_facing) >= math.cos(_halfArc);
  }

  @override
  bool canBeDamagedBy(BulletState bullet) => !_isFrontal(bullet.position);

  @override
  bool receiveHit(int damage, BulletComponent bullet) {
    if (!canBeDamagedBy(bullet.state)) {
      // CLANG: reflect off the shield, no damage (mirrors the Warden shield).
      final normal = (bullet.state.position - position)..normalize();
      final v = bullet.state.velocity;
      v.setFrom(v - normal * (2 * v.dot(normal)));
      bullet.state.position.addScaled(normal, 4);
      _hitClang = 0.15;
      if (game.gameFeel.combatText) {
        game.world.add(PopupTextComponent.bounceCounter(
            'CLANG', position + normal * (bodyRadius + 26)));
      }
      game.juice.sound.play(Sfx.wardenClang, volume: 0.8);
      return false;
    }
    return super.receiveHit(damage, bullet);
  }

  @override
  void updateBehavior(double dt) {
    if (_hitClang > 0) _hitClang -= dt;
    final toPlayer = game.player.position - position;
    if (toPlayer.length2 > 1) _facing.setFrom(toPlayer.normalized());

    seekPlayer(dt, GameBalance.I.ironhide.speed);
    clampToArena();
    if (overlapsPlayer()) game.player.takeContactDamage(this);
  }

  @override
  void renderShape(Canvas canvas) {
    final r = bodyRadius;
    // Hexa-ish armored core.
    canvas.drawCircle(Offset.zero, r, Paint()..color = color);
    canvas.drawCircle(
      Offset.zero,
      r * 0.55,
      Paint()..color = const Color(0xFF9AA3B2),
    );

    // Shield arc on the front (facing the player).
    final facingAngle = math.atan2(_facing.y, _facing.x);
    final shieldPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = _hitClang > 0
          ? const Color(0xFFFFFFFF)
          : AppColors.blue300.withValues(alpha: 0.95);
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r + 4),
      facingAngle - _halfArc,
      _halfArc * 2,
      false,
      shieldPaint,
    );
  }
}
