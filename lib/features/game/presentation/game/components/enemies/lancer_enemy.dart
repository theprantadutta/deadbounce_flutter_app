import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../../../../core/theme/app_colors.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import '../deadbounce_game.dart' show DeadbounceGame;
import 'enemy_component.dart';

enum _LancerPhase { reposition, telegraph, strafe }

/// A standoff striker. It holds at range, telegraphs (long, obvious), then
/// strafes in a straight horizontal line clear across the arena — a fast
/// MOVING ricochet target you can lead a bounce into, and a dodgeable threat.
/// The lane is locked and drawn during the telegraph, so a dash always clears
/// it (accessibility). 3 HP rewards a real multi-bounce lead shot.
class LancerEnemy extends EnemyComponent {
  LancerEnemy({required super.position, super.speedMult, double hpMult = 1})
      : super(
          maxHp: (GameBalance.I.lancer.hp * hpMult).ceil(),
          bodyRadius: GameBalance.I.lancer.radius,
          color: const Color(0xFF19E3C7), // steely teal
        );

  _LancerPhase _phase = _LancerPhase.reposition;
  double _phaseTime = 0;
  double _settle = 0; // time held at a good standoff distance
  final Vector2 _strafeDir = Vector2.zero();
  double _facing = 0;

  @override
  String get enemyId => 'lancer';

  @override
  void updateBehavior(double dt) {
    final t = GameBalance.I.lancer;
    _phaseTime += dt;

    switch (_phase) {
      case _LancerPhase.reposition:
        final toPlayer = game.player.position - position;
        final dist = toPlayer.length;
        _facing = math.atan2(toPlayer.y, toPlayer.x);
        final dir = toPlayer.normalized();
        // Hold roughly [standoffRange] from the player: back off if crowded,
        // close in if too far, otherwise settle for a beat then commit.
        if (dist < t.standoffRange - 40) {
          position.addScaled(dir, -t.roamSpeed * speedMult * dt);
          _settle = 0;
        } else if (dist > t.standoffRange + 40) {
          position.addScaled(dir, t.roamSpeed * speedMult * dt);
          _settle = 0;
        } else {
          _settle += dt;
        }
        if (_settle >= 0.6) {
          // Lock a straight horizontal lane toward the player's side.
          _strafeDir.setValues(
              game.player.position.x >= position.x ? 1 : -1, 0);
          _facing = _strafeDir.x >= 0 ? 0 : math.pi;
          _enter(_LancerPhase.telegraph);
        }

      case _LancerPhase.telegraph:
        if (_phaseTime >= t.telegraphDuration) _enter(_LancerPhase.strafe);

      case _LancerPhase.strafe:
        position.addScaled(_strafeDir, t.strafeSpeed * speedMult * dt);
        // Crossed to the far wall → reset and pick a new lane.
        if (position.x <= bodyRadius + 2 ||
            position.x >= DeadbounceGame.arenaWidth - bodyRadius - 2) {
          _enter(_LancerPhase.reposition);
        }
    }

    clampToArena();
    if (overlapsPlayer()) game.player.takeContactDamage(this);
  }

  void _enter(_LancerPhase phase) {
    _phase = phase;
    _phaseTime = 0;
  }

  @override
  void renderShape(Canvas canvas) {
    final telegraphing = _phase == _LancerPhase.telegraph;
    final pulse = telegraphing ? 0.5 + 0.5 * math.sin(_phaseTime * 26) : 0.0;

    // Locked strafe lane, drawn world-aligned so the player reads where it
    // will cross (only during the telegraph wind-up).
    if (telegraphing) {
      final lane = Paint()
        ..strokeWidth = 3
        ..color = color.withValues(alpha: 0.22 + pulse * 0.3);
      canvas.drawLine(
        Offset.zero,
        Offset(_strafeDir.x * 1400, 0),
        lane,
      );
    }

    canvas.save();
    canvas.rotate(_facing); // 0 = pointing +x
    final r = bodyRadius;
    // An elongated lance/dart pointing along travel.
    final path = Path()
      ..moveTo(r * 1.7, 0)
      ..lineTo(-r * 0.8, r * 0.7)
      ..lineTo(-r * 0.4, 0)
      ..lineTo(-r * 0.8, -r * 0.7)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    if (pulse > 0) {
      canvas.drawPath(
        path,
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: pulse * 0.6),
      );
    }
    canvas.drawCircle(
      Offset(r * 0.2, 0),
      r * 0.26,
      Paint()..color = AppColors.blue100.withValues(alpha: 0.85),
    );
    canvas.restore();
  }
}
