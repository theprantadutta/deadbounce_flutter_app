import 'package:flame/components.dart';

import '../combat/bullet_state.dart';
import '../combat/bullet_stats.dart';
import '../combat/player_stats.dart';
import '../game_rng.dart';
import '../physics/wall_segment.dart';

/// Capabilities upgrade hooks may use to act on the world — implemented
/// by DeadbounceGame, faked in tests. Hooks never touch components
/// directly.
abstract interface class GameWorldOps {
  /// Spawns an additional bullet (Split Shot, Echo Shot). [delaySeconds]
  /// defers the spawn (Echo Shot's follow-up shot).
  void spawnBullet(BulletState state, BulletStats stats,
      {double delaySeconds = 0});

  /// Drops a burning ground hazard (Incendiary Trail).
  void spawnFireTrail(Vector2 position, double radius, double duration,
      int damagePerSecond);

  /// Nearest living enemy within [within] units, or null.
  Vector2? nearestEnemyTo(Vector2 position, {required double within});

  /// Seeded gameplay rng (the 'modifiers' fork).
  GameRng get rng;
}

/// A shot about to be fired — onFire hooks may add more.
class PendingShot {
  PendingShot({
    required this.direction,
    required this.speed,
    this.delaySeconds = 0,
    BulletFlags? flags,
  }) : flags = flags ?? BulletFlags();

  final Vector2 direction;
  final double speed;
  final double delaySeconds;
  final BulletFlags flags;
}

class FireContext {
  FireContext({
    required this.origin,
    required this.shotIndex,
    required this.shots,
    required this.world,
  });

  final Vector2 origin;

  /// Player's cumulative shot counter (Ghost Round's "every 4th shot").
  final int shotIndex;

  /// Mutable: hooks may append duplicates or tag flags on entries.
  final List<PendingShot> shots;
  final GameWorldOps world;
}

class BounceContext {
  BounceContext({
    required this.bullet,
    required this.stats,
    required this.wall,
    required this.bounceIndex,
    required this.world,
  });

  final BulletState bullet;
  final BulletStats stats;
  final WallSegment wall;
  final int bounceIndex;
  final GameWorldOps world;
}

class BulletUpdateContext {
  BulletUpdateContext({
    required this.bullet,
    required this.stats,
    required this.world,
  });

  final BulletState bullet;
  final BulletStats stats;
  final GameWorldOps world;
}

class KillContext {
  KillContext({
    required this.bullet,
    required this.enemyType,
    required this.chainLength,
    required this.position,
    required this.world,
  });

  final BulletState bullet;
  final String enemyType;
  final int chainLength;
  final Vector2 position;
  final GameWorldOps world;
}

class PlayerDamageContext {
  PlayerDamageContext({required this.heartsAfter});

  final int heartsAfter;
  bool deathPrevented = false;

  /// Last Stand: cancel a fatal hit (once per run).
  void preventDeath() => deathPrevented = true;
}

class CoinContext {
  CoinContext(this.amount);

  /// Mutable — Coin Magnet scales it.
  double amount;
}

/// Base class for the 12+ upgrade cards' behavior. The split that keeps
/// this from becoming if-else spaghetti:
///  - [transformPlayerStats]/[transformBulletStats] are PURE folds,
///    recomputed once per pick and cached;
///  - the event hooks are BEHAVIOR, dispatched by RunModifiers at fixed
///    points; bullet/player code never knows which upgrades exist.
abstract class UpgradeModifier {
  String get id;

  /// Bumped by RunModifiers when the same card is picked again.
  int stacks = 1;

  PlayerStats transformPlayerStats(PlayerStats stats) => stats;
  BulletStats transformBulletStats(BulletStats stats) => stats;

  void onFire(FireContext ctx) {}
  void onBounce(BounceContext ctx) {}
  void onBulletUpdate(BulletUpdateContext ctx, double dt) {}
  void onKill(KillContext ctx) {}
  void onPlayerDamaged(PlayerDamageContext ctx) {}
  void onCoinEarned(CoinContext ctx) {}
}
