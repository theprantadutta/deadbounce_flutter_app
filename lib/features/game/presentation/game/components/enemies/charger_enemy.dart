import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import 'enemy_component.dart';

enum _ChargerPhase { roam, telegraph, dash, recover }

/// Triangle that roams, telegraphs (flash + windup), then dashes in a
/// straight line. The dash vector locks at telegraph START — dashing
/// players dodge it. 2 HP.
class ChargerEnemy extends EnemyComponent {
  ChargerEnemy({required super.position, super.speedMult, double hpMult = 1})
      : super(
          maxHp: (GameBalance.I.charger.hp * hpMult).ceil(),
          bodyRadius: GameBalance.I.charger.radius,
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
    final t = GameBalance.I.charger;
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
    // Recover: the vulnerability window — render it as a dizzy stagger so
    // players learn to punish it (its recover is the whole risk/reward story).
    final recovering = _phase == _ChargerPhase.recover;
    final pulse = telegraphing
        ? 0.5 + 0.5 * math.sin(_phaseTime * 28)
        : 0.0;

    canvas.save();
    var tilt = _facing + math.pi / 2;
    if (recovering) tilt += math.sin(_phaseTime * 11) * 0.28; // groggy sway
    canvas.rotate(tilt);

    final r = bodyRadius * (telegraphing ? 1.0 + pulse * 0.15 : 1.0);
    final path = Path()
      ..moveTo(0, -r * 1.2)
      ..lineTo(r, r)
      ..lineTo(-r, r)
      ..close();

    // Dim the body while staggered so it reads as "open — hit me now".
    final body = recovering
        ? Color.lerp(color, const Color(0xFF5E2410), 0.45)!
        : color;
    canvas.drawPath(path, Paint()..color = body);
    if (pulse > 0) {
      canvas.drawPath(
        path,
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: pulse * 0.6),
      );
    }
    canvas.restore();

    // Orbiting "dizzy" sparks above the head during the stagger.
    if (recovering) {
      final star = Paint()..color = const Color(0xFFFFE29A);
      for (var i = 0; i < 3; i++) {
        final a = _phaseTime * 7 + i * 2.094;
        canvas.drawCircle(
          Offset(math.cos(a) * bodyRadius * 0.7,
              -bodyRadius * 1.25 + math.sin(a) * bodyRadius * 0.22),
          3,
          star,
        );
      }
    }
  }
}
