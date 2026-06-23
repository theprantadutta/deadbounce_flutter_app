import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart' show Curves;

import '../../../engine/combat/bullet_state.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import '../../../engine/upgrades/upgrade_modifier.dart';
import '../systems/sound_manager.dart';
import 'deadbounce_game.dart';
import 'enemies/enemy_component.dart';
import 'enemy_projectile_component.dart';

/// The lone neon gunslinger: a geometric orb — amber core, electric-blue
/// trim ring, hat-brim glow arc — that dashes between the arena's 3
/// anchors. Movement is not the skill; aiming is.
class PlayerComponent extends PositionComponent
    with HasGameReference<DeadbounceGame> {
  PlayerComponent({required this.anchors, super.position})
    : super(anchor: Anchor.center, priority: 45);

  final List<Vector2> anchors;
  double get bodyRadius => GameBalance.I.player.radius;

  int hearts = GameBalance.I.player.maxHearts;
  int anchorIndex = 1;
  double fireCooldownRemaining = 0;
  double _fireCooldownTotal = 0;
  double invulnRemaining = 0;
  int shotCounter = 0;
  bool _dashing = false;
  double _pulse = 0;

  bool get fireReady => fireCooldownRemaining <= 0;

  @override
  Future<void> onLoad() async {
    position.setFrom(anchors[anchorIndex]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt;
    if (fireCooldownRemaining > 0) fireCooldownRemaining -= dt;
    if (invulnRemaining > 0) invulnRemaining -= dt;
    game.hud.fireCharge.value = _fireCooldownTotal <= 0
        ? 1
        : (1 - fireCooldownRemaining / _fireCooldownTotal).clamp(0.0, 1.0);
  }

  Vector2 get muzzlePosition => position.clone();

  /// Tap-to-dash: snaps to the chosen anchor with a fast eased move and
  /// brief i-frames (it's a dodge).
  void dashTo(int index) {
    if (_dashing || index == anchorIndex || game.runEnded) return;
    anchorIndex = index.clamp(0, anchors.length - 1);
    _dashing = true;
    game.hud.dashReady.value = false;
    invulnRemaining = math.max(
      invulnRemaining,
      GameBalance.I.player.invulnAfterDash,
    );

    game.juice.sound.play(Sfx.dash);
    game.juice.haptics.medium();

    add(
      MoveToEffect(
        anchors[anchorIndex],
        EffectController(
          duration: GameBalance.I.player.dashDuration,
          curve: Curves.easeOutCubic,
        ),
        onComplete: () {
          _dashing = false;
          game.hud.dashReady.value = true;
        },
      ),
    );
  }

  /// Releases the aimed shot. [direction] must be normalized; [powerT]
  /// in [0,1] maps across the launch-speed range.
  void fire(Vector2 direction, double powerT) {
    if (!fireReady || game.runEnded) return;

    final playerStats = game.modifiers.effectivePlayerStats();
    final bulletStats = game.modifiers.effectiveBulletStats();
    fireCooldownRemaining = playerStats.fireCooldown;
    _fireCooldownTotal = playerStats.fireCooldown;
    shotCounter++;

    final speed =
        GameBalance.I.bullet.minSpeed +
        (GameBalance.I.bullet.maxSpeed - GameBalance.I.bullet.minSpeed) *
            powerT;

    final shots = [PendingShot(direction: direction, speed: speed)];
    game.modifiers.fire(
      FireContext(
        origin: muzzlePosition,
        shotIndex: shotCounter,
        shots: shots,
        world: game,
      ),
    );

    for (final shot in shots) {
      final state = BulletState(
        position: muzzlePosition,
        velocity: shot.direction.normalized()..scale(shot.speed),
        flags: shot.flags,
      );
      game.spawnBullet(state, bulletStats, delaySeconds: shot.delaySeconds);
    }

    game.particles.muzzleFlash(muzzlePosition, direction);
    game.juice.sound.play(Sfx.fire);
    game.juice.haptics.light();
  }

  void heal(int amount) {
    hearts = math.min(hearts + amount, game.effectiveMaxHearts());
    game.hud.hearts.value = hearts;
  }

  void takeContactDamage(EnemyComponent from) => _takeDamage(from.enemyId);

  void takeProjectileDamage(EnemyProjectileComponent from) =>
      _takeDamage('turret');

  /// Environmental damage from a hazard zone (e.g. a Powderkeg blast),
  /// attributed to [cause] for the death-beat copy.
  void takeHazardDamage(String cause) => _takeDamage(cause);

  void _takeDamage(String cause) {
    if (invulnRemaining > 0 || game.runEnded) return;

    hearts--;
    game.hitsTaken++;
    game.lastDamageSource = cause;
    final ctx = PlayerDamageContext(heartsAfter: hearts);
    game.modifiers.playerDamaged(ctx);

    if (hearts <= 0 && ctx.deathPrevented) {
      // Last Stand: back from the brink, big i-frame window.
      hearts = 1;
      invulnRemaining = 2.0;
      game.juice.addTrauma(0.6);
      game.juice.sound.play(Sfx.wardenPhase);
    } else {
      invulnRemaining =
          GameBalance.I.player.invulnAfterHit + game.metaInvulnBonus;
    }

    game.hud.hearts.value = hearts;
    game.juice.sound.play(Sfx.hurt);
    game.juice.haptics.heavy();
    game.juice.addTrauma(0.45);

    if (hearts <= 0) game.endRun();
  }

  @override
  void render(Canvas canvas) {
    // I-frame flicker.
    if (invulnRemaining > 0 && (invulnRemaining * 12).floor().isEven) {
      return;
    }

    final r = bodyRadius;
    final readyPulse = fireReady ? 0.5 + 0.5 * math.sin(_pulse * 4) : 0.0;

    // Equipped gunslinger skin (cosmetic, visual only): core + trim colors.
    final skin = game.cosmetics.gunslinger;
    final core = skin.primary;
    final trim = skin.secondary;
    final highlight = Color.lerp(core, const Color(0xFFFFFFFF), 0.6)!;

    // Glow halo (stronger when fire is ready).
    canvas.drawCircle(
      Offset.zero,
      r * 1.9,
      Paint()..color = core.withValues(alpha: 0.14 + readyPulse * 0.08),
    );

    // Trim ring.
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = trim,
    );

    // Core.
    canvas.drawCircle(Offset.zero, r * 0.72, Paint()..color = core);
    canvas.drawCircle(
      Offset(-r * 0.2, -r * 0.2),
      r * 0.22,
      Paint()..color = highlight,
    );

    // Hat-brim glow arc above.
    canvas.drawArc(
      Rect.fromCircle(center: Offset(0, -r * 0.55), radius: r * 0.85),
      math.pi + 0.35,
      math.pi - 0.7,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = trim,
    );
  }
}
