import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import 'enemy_component.dart';

/// A fast, fragile skitterer: 1 HP dies to any armed bounce, but it closes on
/// the player quickly with a sharp, rhythmic lateral weave. The threat is its
/// SPEED, not its toughness — pressure that rewards a quick, clever shot, and
/// dash i-frames always beat it, so it never punishes slow reflexes.
class SkitterEnemy extends EnemyComponent {
  SkitterEnemy({required super.position, super.speedMult, double hpMult = 1})
      : super(
          maxHp: (GameBalance.I.skitter.hp * hpMult).ceil(),
          bodyRadius: GameBalance.I.skitter.radius,
          color: const Color(0xFFB14DFF), // electric violet — a new threat cue
        );

  double _weavePhase = 0;
  late final double _phaseOffset = game.enemyAiRng.range(0, math.pi * 2);

  @override
  String get enemyId => 'skitter';

  @override
  void updateBehavior(double dt) {
    final t = GameBalance.I.skitter;
    _weavePhase += dt * t.weaveFrequency;
    seekPlayer(dt, t.speed);

    // Sharp lateral juke perpendicular to the seek line — a steady rhythm, so
    // it reads and can be led, not a random dodge-fest.
    final toPlayer = (game.player.position - position)..normalize();
    final lateral = Vector2(-toPlayer.y, toPlayer.x);
    position.addScaled(
      lateral,
      math.sin(_weavePhase * math.pi * 2 + _phaseOffset) *
          t.weaveAmplitude *
          dt,
    );

    clampToArena();
    if (overlapsPlayer()) game.player.takeContactDamage(this);
  }

  @override
  void renderShape(Canvas canvas) {
    final toPlayer = game.player.position - position;
    final facing = math.atan2(toPlayer.y, toPlayer.x);
    canvas.save();
    canvas.rotate(facing + math.pi / 2);

    final r = bodyRadius;
    // A darting chevron/dart pointing along travel.
    final path = Path()
      ..moveTo(0, -r * 1.3)
      ..lineTo(r * 0.9, r)
      ..lineTo(0, r * 0.4)
      ..lineTo(-r * 0.9, r)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawCircle(
      Offset(0, -r * 0.2),
      r * 0.28,
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.85),
    );
    canvas.restore();
  }
}
