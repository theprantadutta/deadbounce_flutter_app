import 'dart:ui';

import 'package:deadbounce_flutter_app/core/config/game_balance.dart';

import '../../../../../../core/theme/app_colors.dart';
import 'enemy_component.dart';

/// The mender: hangs back and periodically heals nearby wounded enemies,
/// turning an easy wave into a race against its pulses. A priority target —
/// the player learns to drop it first. Heals only OTHER non-mender enemies.
class SawbonesEnemy extends EnemyComponent {
  SawbonesEnemy({required super.position, super.speedMult, double hpMult = 1})
      : super(
          maxHp: (GameBalance.I.sawbones.hp * hpMult).ceil(),
          bodyRadius: GameBalance.I.sawbones.radius,
          color: const Color(0xFF3DDC84), // medic green
        );

  double _healTimer = 0;
  double _pulse = 0; // 0..1 visual pulse fading after a heal

  @override
  String get enemyId => 'sawbones';

  @override
  void updateBehavior(double dt) {
    final t = GameBalance.I.sawbones;
    if (_pulse > 0) _pulse -= dt * 2;

    // Keep a gentle distance: drift toward the player but slower than fodder
    // so it lingers at the back of the pack.
    seekPlayer(dt, t.speed);
    clampToArena();
    if (overlapsPlayer()) game.player.takeContactDamage(this);

    _healTimer += dt;
    if (_healTimer >= t.healInterval) {
      _healTimer = 0;
      _healNearby(t.healRadius, t.healAmount);
    }
  }

  void _healNearby(double radius, int amount) {
    var healedAny = false;
    for (final enemy in game.aliveEnemies) {
      if (enemy == this || enemy is SawbonesEnemy) continue;
      if (enemy.position.distanceTo(position) <= radius) {
        enemy.receiveHeal(amount);
        healedAny = true;
      }
    }
    if (healedAny) _pulse = 1;
  }

  @override
  void renderShape(Canvas canvas) {
    final r = bodyRadius;
    // Heal-pulse aura.
    if (_pulse > 0) {
      canvas.drawCircle(
        Offset.zero,
        r * (1.4 + (1 - _pulse) * 1.2),
        Paint()..color = color.withValues(alpha: 0.25 * _pulse),
      );
    }
    // Body.
    canvas.drawCircle(Offset.zero, r, Paint()..color = color);
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = AppColors.success.withValues(alpha: 0.9),
    );
    // White medical cross.
    final cross = Paint()
      ..color = const Color(0xFFF4F5FB)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, -r * 0.5), Offset(0, r * 0.5), cross);
    canvas.drawLine(Offset(-r * 0.5, 0), Offset(r * 0.5, 0), cross);
  }
}
