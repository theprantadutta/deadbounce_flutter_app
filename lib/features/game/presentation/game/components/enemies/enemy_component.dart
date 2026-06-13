import 'dart:ui';

import 'package:flame/components.dart';

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

  /// Steers gently toward the player, capped at [speed].
  void seekPlayer(double dt, double speed) {
    final toPlayer = game.player.position - position;
    if (toPlayer.length2 < 1) return;
    toPlayer.normalize();
    position.addScaled(toPlayer, speed * speedMult * dt);
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
