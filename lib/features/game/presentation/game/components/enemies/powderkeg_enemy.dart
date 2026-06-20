import 'dart:math' as math;
import 'dart:ui';

import 'package:deadbounce_flutter_app/core/config/game_balance.dart';

import '../shockwave_component.dart';
import 'enemy_component.dart';

/// A slow, volatile barrel: drifts toward the player like a Drifter, but on
/// death it leaves a telegraphed shockwave that detonates after a short
/// fuse — punishing players who camp on top of their kills. Spatial play,
/// not a buff: it never touches bullet damage.
class PowderkegEnemy extends EnemyComponent {
  PowderkegEnemy({required super.position, super.speedMult, double hpMult = 1})
      : super(
          maxHp: (GameBalance.I.powderkeg.hp * hpMult).ceil(),
          bodyRadius: GameBalance.I.powderkeg.radius,
          color: const Color(0xFFE2622E), // volatile orange
        );

  double _wobble = 0;

  @override
  String get enemyId => 'powderkeg';

  @override
  void updateBehavior(double dt) {
    _wobble += dt * 4;
    seekPlayer(dt, GameBalance.I.powderkeg.speed);
    clampToArena();
    if (overlapsPlayer()) game.player.takeContactDamage(this);
  }

  @override
  void die({killer}) {
    final t = GameBalance.I.powderkeg;
    game.world.add(ShockwaveComponent(
      position: position.clone(),
      radius: t.blastRadius,
      fuse: t.fuseDuration,
    ));
    super.die(killer: killer);
  }

  @override
  void renderShape(Canvas canvas) {
    final r = bodyRadius;
    // Barrel body.
    canvas.drawCircle(Offset.zero, r, Paint()..color = color);
    // Hazard stripes — a hint that it's volatile.
    final stripe = Paint()
      ..color = const Color(0xFF2A1206)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset.zero, r * 0.62, stripe);
    // Pulsing fuse core.
    final pulse = 0.5 + 0.5 * math.sin(_wobble);
    canvas.drawCircle(
      Offset.zero,
      r * 0.3,
      Paint()..color = Color.lerp(const Color(0xFFFFD166),
          const Color(0xFFFF4D5E), pulse)!,
    );
  }
}
