import 'dart:math' as math;

import '../../combat/bullet_state.dart';
import '../../physics/vector_utils.dart';
import '../upgrade_modifier.dart';

/// Split Shot — on a bullet's 3rd wall bounce it splits once: a clone
/// rotated +15° spawns (inheriting bounces — already lethal), the
/// original deflects -15°. The hasSplit flag prevents recursion.
class SplitShotModifier extends UpgradeModifier {
  static const double _splitAngle = math.pi / 12; // 15°
  static const int _splitBounce = 3;

  @override
  String get id => 'split_shot';

  @override
  void onBounce(BounceContext ctx) {
    if (ctx.bounceIndex != _splitBounce || ctx.bullet.flags.hasSplit) return;
    ctx.bullet.flags.hasSplit = true;

    final clone = BulletState(
      position: ctx.bullet.position.clone(),
      velocity: ctx.bullet.velocity.clone()..rotateBy(_splitAngle),
      bounces: ctx.bullet.bounces,
      flags: BulletFlags(hasSplit: true),
    );
    ctx.world.spawnBullet(clone, ctx.stats);

    ctx.bullet.velocity.rotateBy(-_splitAngle);
  }
}

/// Incendiary Trail — bullets with 2+ bounces drip burning ground
/// hazards behind them.
class IncendiaryTrailModifier extends UpgradeModifier {
  static const double _dropInterval = 0.16;
  static const double _trailRadius = 30;
  static const double _trailDuration = 1.2;
  static const int _trailDps = 2;

  @override
  String get id => 'incendiary_trail';

  @override
  void onBulletUpdate(BulletUpdateContext ctx, double dt) {
    if (ctx.bullet.bounces < 2) return;

    ctx.bullet.flags.trailCooldown -= dt;
    if (ctx.bullet.flags.trailCooldown > 0) return;
    ctx.bullet.flags.trailCooldown = _dropInterval;

    ctx.world.spawnFireTrail(
      ctx.bullet.position.clone(),
      _trailRadius,
      _trailDuration,
      _trailDps * stacks,
    );
  }
}

/// Magnet Rounds — after the 2nd bounce, bullets steer gently toward the
/// nearest enemy. Magnitude is preserved (no damage/speed change), and
/// the preview intentionally does NOT show the curve — homing is a
/// forgiveness mechanic, not an aiming one.
class MagnetRoundsModifier extends UpgradeModifier {
  static const double _searchRadius = 260;
  static const double _turnRatePerStack = 2.4; // rad/s

  @override
  String get id => 'magnet_rounds';

  @override
  void onBulletUpdate(BulletUpdateContext ctx, double dt) {
    if (ctx.bullet.bounces < 2) return;

    final target = ctx.world.nearestEnemyTo(
      ctx.bullet.position,
      within: _searchRadius,
    );
    if (target == null) return;

    final toTarget = target - ctx.bullet.position;
    if (toTarget.length2 < 1e-6) return; // coincident — nothing to steer toward
    final desired = toTarget..normalize();
    final current = ctx.bullet.velocity.normalized();

    final cross = current.cross(desired);
    final dot = current.dot(desired).clamp(-1.0, 1.0);
    final angleTo = math.atan2(cross, dot);

    final maxTurn = _turnRatePerStack * stacks * dt;
    final turn = angleTo.clamp(-maxTurn, maxTurn);

    ctx.bullet.velocity.rotateBy(turn);
  }
}
