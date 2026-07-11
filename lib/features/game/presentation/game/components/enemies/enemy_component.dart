import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import 'package:deadbounce_flutter_app/core/config/game_balance.dart';

import '../../../../engine/combat/bullet_state.dart';
import '../deadbounce_game.dart';
import '../bullet_component.dart';

/// Base of the roster: HP, hit flash, death (shatter + score + coins +
/// chain bookkeeping happen in the game's onEnemyKilled). Subclasses
/// implement [updateBehavior] and [renderShape].
abstract class EnemyComponent extends PositionComponent
    with HasGameReference<DeadbounceGame> {
  EnemyComponent({
    required this.maxHp,
    required this.bodyRadius,
    required this.color,
    required super.position,
    this.speedMult = 1,
  })  : hp = maxHp,
        super(anchor: Anchor.center, priority: 30);

  final int maxHp;
  int hp;
  final double bodyRadius;
  final Color color;
  final double speedMult;

  /// Stable id for stats counters ('drifter', 'charger'...).
  String get enemyId;

  double _hitFlash = 0;
  bool _dead = false;

  bool get isDead => _dead;

  /// Warden overrides: shield blocks low-bounce bullets.
  bool canBeDamagedBy(BulletState bullet) => true;

  /// Damage application. Returns true when this hit killed the enemy.
  bool receiveHit(int damage, BulletComponent bullet) {
    if (_dead || damage <= 0) return false;
    hp -= damage;
    _hitFlash = 0.12;
    if (hp <= 0) {
      die(killer: bullet);
      return true;
    }
    return false;
  }

  /// Bullet-less damage (Incendiary Trail). Bypasses the Warden shield —
  /// the trail only exists because a 2+ bounce bullet earned it.
  void receiveEnvironmentalDamage(int damage) {
    if (_dead || damage <= 0) return;
    hp -= damage;
    _hitFlash = 0.12;
    if (hp <= 0) die();
  }

  /// Restores HP up to [maxHp] (the Sawbones mender). No-op on the dead.
  void receiveHeal(int amount) {
    if (_dead || amount <= 0) return;
    if (hp >= maxHp) return;
    hp = (hp + amount).clamp(0, maxHp);
  }

  /// Death — also used by non-bullet sources (fire trails).
  void die({BulletComponent? killer}) {
    if (_dead) return;
    _dead = true;
    game.onEnemyKilled(this, killer);
    removeFromParent();
  }

  /// Subclass AI. Base update handles the flash timer.
  void updateBehavior(double dt);

  @override
  void update(double dt) {
    super.update(dt);
    if (_hitFlash > 0) _hitFlash -= dt;
    updateBehavior(dt);
  }

  /// Subclass silhouette, drawn around the local origin.
  void renderShape(Canvas canvas);

  @override
  void render(Canvas canvas) {
    // Fake glow halo in the enemy color, then the silhouette; white
    // flash overlay while recently hit.
    canvas.drawCircle(
      Offset.zero,
      bodyRadius * 1.6,
      Paint()..color = color.withValues(alpha: 0.16),
    );
    renderShape(canvas);
    if (_hitFlash > 0) {
      canvas.drawCircle(
        Offset.zero,
        bodyRadius,
        Paint()
          ..color = const Color(0xFFFFFFFF)
              .withValues(alpha: (_hitFlash / 0.12) * 0.7),
      );
    }
  }

  /// Steers gently toward the player, capped at [speed]. A separation force
  /// pushes overlapping neighbors apart so groups spread into arcs instead
  /// of stacking into a single blob (stacked enemies read as one enemy and
  /// hide the multi-kill fantasy).
  void seekPlayer(double dt, double speed) {
    final desired = game.player.position - position;
    if (desired.length2 < 1) return;
    desired.normalize();

    final cfg = GameBalance.I.enemies;
    if (cfg.separationStrength > 0) {
      final push = Vector2.zero();
      for (final other in game.aliveEnemies) {
        if (identical(other, this)) continue;
        final away = position - other.position;
        final minDist = bodyRadius + other.bodyRadius + cfg.separationPadding;
        final d2 = away.length2;
        if (d2 < 0.01 || d2 >= minDist * minDist) continue;
        // Away-vector weighted by how deep the overlap is (1 at full overlap
        // → 0 at the edge of the separation ring).
        final d = math.sqrt(d2);
        push.addScaled(away..scale(1 / d), 1 - d / minDist);
      }
      if (push.length2 > 0) {
        desired.addScaled(push, cfg.separationStrength);
        if (desired.length2 > 0.0001) desired.normalize();
      }
    }

    position.addScaled(desired, speed * speedMult * dt);
  }

  /// Keeps the body inside the arena bounds.
  void clampToArena() {
    position.x = position.x.clamp(bodyRadius, DeadbounceGame.arenaWidth - bodyRadius);
    position.y = position.y.clamp(bodyRadius, DeadbounceGame.arenaHeight - bodyRadius);
  }

  /// Touching the player?
  bool overlapsPlayer() =>
      position.distanceTo(game.player.position) <
      bodyRadius + game.player.bodyRadius;
}
