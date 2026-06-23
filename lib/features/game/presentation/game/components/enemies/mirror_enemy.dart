import 'dart:ui';

import 'package:flame/components.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../engine/combat/bullet_state.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import '../../../../engine/physics/wall_segment.dart';
import '../bullet_component.dart';
import 'enemy_component.dart';

/// A drifting reflector. Its front face is a real, one-sided wall segment
/// fed to the SAME ricochet solver the aim preview uses — so the predicted
/// line reflects off it truthfully (preview == reality), and a front shot
/// gains a real bounce (it's a free-bounce TOOL as much as a hazard). The
/// front always faces the player, so direct shots only ever bounce; to kill
/// it you must land a shot on its back — i.e. bounce one in behind it.
class MirrorEnemy extends EnemyComponent {
  MirrorEnemy({required super.position, super.speedMult, double hpMult = 1})
      : super(
          maxHp: (GameBalance.I.mirror.hp * hpMult).ceil(),
          bodyRadius: GameBalance.I.mirror.radius,
          color: const Color(0xFFBDF4FF), // glassy cyan
        );

  /// The reflecting face, registered with the solver while alive.
  late final WallSegment _face = WallSegment(
    a: position.clone(),
    b: position.clone(),
    normal: Vector2(0, 1),
    isBoundary: false,
    isMirror: true,
  );

  /// Unit normal of the front face (points toward the player).
  final Vector2 _facing = Vector2(0, 1);

  @override
  String get enemyId => 'mirror';

  @override
  Future<void> onLoad() async {
    _recomputeFace();
    game.segments.add(_face);
  }

  @override
  void onRemove() {
    game.segments.remove(_face);
    super.onRemove();
  }

  /// Damage lands only from BEHIND the face (a back-side hit). A bullet
  /// striking the front reflects at the segment and never reaches the body;
  /// this guard stops a grazing front shot from counting.
  @override
  bool canBeDamagedBy(BulletState bullet) =>
      bullet.velocity.dot(_facing) > 0;

  /// The bullet sweep calls receiveHit even when [canBeDamagedBy] is false
  /// (that's the Warden CLANG path); the base impl ignores the gate and just
  /// subtracts HP, which would let a front shot kill the Mirror. Enforce the
  /// gate here, like Ironhide/Warden do.
  @override
  bool receiveHit(int damage, BulletComponent bullet) {
    if (!canBeDamagedBy(bullet.state)) return false; // front face: bounce only
    return super.receiveHit(damage, bullet);
  }

  @override
  void updateBehavior(double dt) {
    final toPlayer = game.player.position - position;
    if (toPlayer.length2 > 1) _facing.setFrom(toPlayer.normalized());

    seekPlayer(dt, GameBalance.I.mirror.speed);
    clampToArena();
    _recomputeFace();

    if (overlapsPlayer()) game.player.takeContactDamage(this);
  }

  /// Keep the segment glued to the body, perpendicular to the player-facing
  /// normal, at the tuned width.
  void _recomputeFace() {
    final half = GameBalance.I.mirror.width / 2;
    final perp = Vector2(-_facing.y, _facing.x)..scale(half);
    _face.a.setFrom(position - perp);
    _face.b.setFrom(position + perp);
    _face.normal.setFrom(_facing);
  }

  @override
  void renderShape(Canvas canvas) {
    final half = GameBalance.I.mirror.width / 2;
    final perp = Offset(-_facing.y, _facing.x);
    final a = perp * half;
    final b = perp * -half;

    // Dark backing (the killable side).
    canvas.drawLine(
      a,
      b,
      Paint()
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = AppColors.ink500,
    );
    // Reflective front sheen, nudged toward the player.
    final front = Offset(_facing.x, _facing.y) * 2.5;
    canvas.drawLine(
      a + front,
      b + front,
      Paint()
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
    // Pivot node.
    canvas.drawCircle(
      Offset.zero,
      4,
      Paint()..color = AppColors.blue200,
    );
  }
}
