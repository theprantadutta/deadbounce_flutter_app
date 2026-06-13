import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../../engine/tuning.dart';
import 'enemy_component.dart';

enum _ChargerPhase { roam, telegraph, dash, recover }

/// Triangle that roams, telegraphs (flash + windup), then dashes in a
/// straight line. The dash vector locks at telegraph START — dashing
/// players dodge it. 2 HP.
class ChargerEnemy extends EnemyComponent {
  ChargerEnemy({required super.position, super.speedMult, double hpMult = 1})
      : super(
          maxHp: (Tuning.charger.hp * hpMult).ceil(),
          bodyRadius: Tuning.charger.radius,
          color: const Color(0xFFFF6B35), // red-orange
        );

  _ChargerPhase _phase = _ChargerPhase.roam;
  double _phaseTime = 0;
  final Vector2 _dashDir = Vector2.zero();
  double _dashTraveled = 0;
  double _facing = 0;

  @override
  String get enemyId => 'charger';

  @override
  void updateBehavior(double dt) {
    const t = Tuning.charger;
    _phaseTime += dt;

    switch (_phase) {
      case _ChargerPhase.roam:
        seekPlayer(dt, t.roamSpeed);
        final toPlayer = game.player.position - position;
        _facing = math.atan2(toPlayer.y, toPlayer.x);
        if (toPlayer.length < t.triggerRange) {
          _enter(_ChargerPhase.telegraph);
          // Lock the dash vector NOW — dodge window.
          _dashDir
            ..setFrom(toPlayer)
            ..normalize();
        }

      case _ChargerPhase.telegraph:
        if (_phaseTime >= t.telegraphDuration) {
          _enter(_ChargerPhase.dash);
          _dashTraveled = 0;
        }

      case _ChargerPhase.dash:
        final step = t.dashSpeed * speedMult * dt;
        // Stop at walls: cast the dash ray and clamp.
        final hit = game.solver.castRay(
          position,
          _dashDir,
          step,
          radius: bodyRadius,
        );
        if (hit != null) {
          position.setFrom(hit.point);
          _enter(_ChargerPhase.recover);
        } else {
          position.addScaled(_dashDir, step);
          _dashTraveled += step;
          if (_dashTraveled >= t.dashRange) _enter(_ChargerPhase.recover);
        }

      case _ChargerPhase.recover:
        if (_phaseTime >= t.recoverDuration) _enter(_ChargerPhase.roam);
    }

    clampToArena();
    if (overlapsPlayer()) game.player.takeContactDamage(this);
  }

  void _enter(_ChargerPhase phase) {
    _phase = phase;
    _phaseTime = 0;
  }

  @override
  void renderShape(Canvas canvas) {
    // Telegraph: pulsing white-hot flash.
    final telegraphing = _phase == _ChargerPhase.telegraph;
    final pulse = telegraphing
        ? 0.5 + 0.5 * math.sin(_phaseTime * 28)
        : 0.0;

    canvas.save();
    canvas.rotate(_facing + math.pi / 2);

    final r = bodyRadius * (telegraphing ? 1.0 + pulse * 0.15 : 1.0);
    final path = Path()
      ..moveTo(0, -r * 1.2)
      ..lineTo(r, r)
      ..lineTo(-r, r)
      ..close();

    canvas.drawPath(path, Paint()..color = color);
    if (pulse > 0) {
      canvas.drawPath(
        path,
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: pulse * 0.6),
      );
    }
    canvas.restore();
  }
}
