import 'dart:math' as math;

import 'package:flame/components.dart';

import 'package:deadbounce_flutter_app/core/config/game_balance.dart';

import '../../combat/bullet_state.dart';
import '../../combat/bullet_stats.dart';
import '../upgrade_modifier.dart';

/// Flashpoint — the first time a bullet reaches its 4th bounce, it flashes: a
/// short burst of burning ground at the bounce point. Rewards working the
/// walls deep before you cash the kill. One flash per bullet.
class FlashpointModifier extends UpgradeModifier {
  static const int _threshold = 4;
  static const double _radius = 70;
  static const double _duration = 0.4;
  static const int _dpsPerStack = 6;

  @override
  String get id => 'flashpoint';

  @override
  void onBounce(BounceContext ctx) {
    if (ctx.bounceIndex < _threshold || ctx.bullet.flags.hasFlashed) return;
    ctx.bullet.flags.hasFlashed = true;
    ctx.world.spawnFireTrail(
      ctx.bullet.position.clone(),
      _radius,
      _duration,
      _dpsPerStack * stacks,
    );
  }
}

/// Chain Lightning — land a chain kill (2+) and the bullet forks: a fast bolt
/// leaps to the nearest enemy, already carrying the killer's bounce count (so
/// it's lethal on contact). The bolt can't fork again (no runaway cascade).
class ChainLightningModifier extends UpgradeModifier {
  static const double _range = 320;

  @override
  String get id => 'chain_lightning';

  @override
  void onKill(KillContext ctx) {
    if (ctx.bullet.flags.suppressKillSpawn) return;
    if (ctx.chainLength < 2) return;

    final target = ctx.world.nearestEnemyTo(ctx.position, within: _range);
    if (target == null) return;
    final dir = target - ctx.position;
    if (dir.length2 < 1e-6) return;
    dir.normalize();

    ctx.world.spawnBullet(
      BulletState(
        position: ctx.position.clone(),
        velocity: dir..scale(GameBalance.I.bullet.maxSpeed),
        bounces: ctx.bullet.bounces, // inherit lethality
        flags: BulletFlags(suppressKillSpawn: true),
      ),
      BulletStats.base(),
    );
  }
}

/// Shrapnel — an armed kill sprays three slugs radially, each inheriting the
/// killer's bounce count (already lethal). The shards can chain into more
/// kills but never spray again. The core chain-fantasy card.
class ShrapnelModifier extends UpgradeModifier {
  static const int _count = 3;

  @override
  String get id => 'shrapnel';

  @override
  void onKill(KillContext ctx) {
    if (ctx.bullet.flags.suppressKillSpawn) return;
    if (ctx.bullet.bounces < 1) return; // only armed kills spray

    final stats = BulletStats.base();
    final b = GameBalance.I.bullet;
    final speed = (b.minSpeed + b.maxSpeed) / 2;
    final baseAngle = ctx.world.rng.range(0, math.pi * 2);
    for (var i = 0; i < _count; i++) {
      final a = baseAngle + i * (2 * math.pi / _count);
      ctx.world.spawnBullet(
        BulletState(
          position: ctx.position.clone(),
          velocity: Vector2(math.cos(a), math.sin(a))..scale(speed),
          bounces: ctx.bullet.bounces,
          flags: BulletFlags(suppressKillSpawn: true),
        ),
        stats,
      );
    }
  }
}
