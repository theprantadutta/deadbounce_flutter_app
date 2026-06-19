import 'dart:math' as math;
import 'dart:ui';


import '../../../../../../core/theme/app_colors.dart';
import '../../../../engine/combat/bullet_state.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import '../../systems/sound_manager.dart';
import '../bullet_component.dart';
import '../popup_text_component.dart';
import 'enemy_component.dart';

/// The mini-boss, every 5th wave: a large rotating shielded shape. The
/// shield blocks bullets with fewer than 3 bounces (they CLANG off);
/// only mastery of the ricochet gets through. Multi-phase HP — each
/// phase break drops the shield for a window and speeds it up.
class WardenEnemy extends EnemyComponent {
  WardenEnemy({
    required super.position,
    super.speedMult,
    double hpMult = 1,
    int appearance = 0,
  })  : _phaseMaxHp = (GameBalance.I.warden.phaseHp *
                hpMult *
                (1 + appearance * GameBalance.I.warden.hpScalePerAppearance))
            .ceil(),
        super(
          maxHp: (GameBalance.I.warden.phaseHp *
                  GameBalance.I.warden.phases *
                  hpMult *
                  (1 + appearance * GameBalance.I.warden.hpScalePerAppearance))
              .ceil(),
          bodyRadius: GameBalance.I.warden.radius,
          color: const Color(0xFFF7F3E9), // white-hot core
        );

  final int _phaseMaxHp;
  int _phase = 0; // 0..phases-1
  double _shieldDownTimer = 0;
  double _rotation = 0;
  double _speedBoost = 1;

  bool get shieldUp => _shieldDownTimer <= 0;
  int get phasesTotal => GameBalance.I.warden.phases;

  /// HP within the current phase.
  int get phaseHp => hp - (phasesTotal - 1 - _phase) * _phaseMaxHp;

  @override
  String get enemyId => 'warden';

  @override
  bool canBeDamagedBy(BulletState bullet) =>
      !shieldUp || bullet.bounces >= GameBalance.I.warden.shieldMinBounces;

  @override
  bool receiveHit(int damage, BulletComponent bullet) {
    if (!canBeDamagedBy(bullet.state)) {
      // CLANG: reflect the bullet off the shield circle, no damage gain.
      final normal = (bullet.state.position - position)..normalize();
      final v = bullet.state.velocity;
      v.setFrom(v - normal * (2 * v.dot(normal)));
      bullet.state.position.addScaled(normal, 4);
      if (game.gameFeel.combatText) {
        game.world.add(PopupTextComponent.bounceCounter(
            'CLANG', position + normal * (bodyRadius + 30)));
      }
      game.juice.sound.play(Sfx.wardenClang);
      return false;
    }

    final wasPhase = (hp - 1) ~/ _phaseMaxHp;
    final killed = super.receiveHit(damage, bullet);
    if (killed) return true;

    final nowPhase = (hp - 1) ~/ _phaseMaxHp;
    if (nowPhase < wasPhase) {
      // Phase break: big moment + shield-down punish window.
      _phase = phasesTotal - 1 - nowPhase;
      _shieldDownTimer = GameBalance.I.warden.shieldDownDuration;
      _speedBoost += 0.35;
      game.juice.wardenFeedback(position.clone());
    }
    return false;
  }

  @override
  void updateBehavior(double dt) {
    _rotation += GameBalance.I.warden.rotationSpeed * _speedBoost * dt;
    if (_shieldDownTimer > 0) _shieldDownTimer -= dt;

    seekPlayer(dt, GameBalance.I.warden.speed * _speedBoost);
    clampToArena();
    if (overlapsPlayer()) game.player.takeContactDamage(this);
  }

  @override
  void renderShape(Canvas canvas) {
    canvas.save();
    canvas.rotate(_rotation);

    // Core: rotating square-ish polygon, white hot.
    final core = Path();
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final p = Offset(
        bodyRadius * 0.62 * math.cos(angle),
        bodyRadius * 0.62 * math.sin(angle),
      );
      i == 0 ? core.moveTo(p.dx, p.dy) : core.lineTo(p.dx, p.dy);
    }
    core.close();
    canvas.drawPath(core, Paint()..color = color);

    // Amber shield ring (segmented) while up.
    if (shieldUp) {
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = AppColors.amber500.withValues(alpha: 0.9);
      for (var i = 0; i < 4; i++) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: bodyRadius),
          i * math.pi / 2 + 0.18,
          math.pi / 2 - 0.36,
          false,
          ring,
        );
      }
    }
    canvas.restore();

    // Phase HP bar above the boss (drawn unrotated).
    const barWidth = 110.0;
    const barHeight = 8.0;
    final top = Offset(-barWidth / 2, -bodyRadius - 26);
    canvas.drawRect(
      Rect.fromLTWH(top.dx, top.dy, barWidth, barHeight),
      Paint()..color = const Color(0x66000000),
    );
    final frac = (phaseHp / _phaseMaxHp).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(top.dx, top.dy, barWidth * frac, barHeight),
      Paint()..color = AppColors.amber400,
    );
    // Phase pips.
    for (var i = 0; i < phasesTotal; i++) {
      canvas.drawCircle(
        Offset(top.dx + 10 + i * 14, top.dy - 8),
        4,
        Paint()
          ..color = i >= _phase ? AppColors.amber400 : AppColors.ink400,
      );
    }
  }
}
