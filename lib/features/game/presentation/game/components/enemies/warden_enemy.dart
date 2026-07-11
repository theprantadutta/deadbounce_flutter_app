import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../engine/combat/bullet_state.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import '../../systems/sound_manager.dart';
import '../bullet_component.dart';
import '../enemy_projectile_component.dart';
import '../popup_text_component.dart';
import 'enemy_component.dart';

/// The mini-boss, every 5th wave: a large rotating shielded shape. The
/// shield blocks bullets with fewer than 3 bounces (they CLANG off);
/// only mastery of the ricochet gets through. Multi-phase HP — each
/// phase break drops the shield for a window and speeds it up.
class WardenEnemy extends EnemyComponent {
  WardenEnemy({
    required super.position,
    super.speedMult,
    double hpMult = 1,
    int appearance = 0,
  })  : _phaseMaxHp = (GameBalance.I.warden.phaseHp *
                hpMult *
                (1 + appearance * GameBalance.I.warden.hpScalePerAppearance))
            .ceil(),
        super(
          maxHp: (GameBalance.I.warden.phaseHp *
                  GameBalance.I.warden.phases *
                  hpMult *
                  (1 + appearance * GameBalance.I.warden.hpScalePerAppearance))
              .ceil(),
          bodyRadius: GameBalance.I.warden.radius,
          color: const Color(0xFFF7F3E9), // white-hot core
        );

  final int _phaseMaxHp;
  int _phase = 0; // 0..phases-1
  double _shieldDownTimer = 0;
  double _rotation = 0;
  double _speedBoost = 1;

  // Offense: a periodic telegraphed radial burst.
  double _attackTimer = 0;
  double _charge = 0; // seconds of wind-up remaining (>0 = telegraphing)
  bool get _charging => _charge > 0;

  bool get shieldUp => _shieldDownTimer <= 0;
  int get phasesTotal => GameBalance.I.warden.phases;

  /// HP within the current phase.
  int get phaseHp => hp - (phasesTotal - 1 - _phase) * _phaseMaxHp;

  @override
  String get enemyId => 'warden';

  @override
  Future<void> onLoad() async {
    game.hud.bossActive.value = true;
    game.hud.bossName.value = 'WARDEN';
    game.hud.bossPhases.value = phasesTotal;
    _pushBossHud();
  }

  @override
  void onRemove() {
    // Only drop the boss bar when the last Warden leaves the arena.
    final othersAlive =
        game.aliveEnemies.any((e) => e is WardenEnemy && e != this);
    if (!othersAlive) game.hud.bossActive.value = false;
    super.onRemove();
  }

  void _pushBossHud() {
    game.hud.bossPhase.value = _phase;
    game.hud.bossPhaseHp.value = phaseHp.clamp(0, _phaseMaxHp);
    game.hud.bossPhaseMaxHp.value = _phaseMaxHp;
  }

  @override
  bool canBeDamagedBy(BulletState bullet) =>
      !shieldUp || bullet.bounces >= GameBalance.I.warden.shieldMinBounces;

  @override
  bool receiveHit(int damage, BulletComponent bullet) {
    if (!canBeDamagedBy(bullet.state)) {
      // CLANG: reflect the bullet off the shield circle, no damage gain.
      final normal = (bullet.state.position - position)..normalize();
      final v = bullet.state.velocity;
      v.setFrom(v - normal * (2 * v.dot(normal)));
      bullet.state.position.addScaled(normal, 4);
      if (game.gameFeel.combatText) {
        game.world.add(PopupTextComponent.bounceCounter(
            'CLANG', position + normal * (bodyRadius + 30)));
      }
      game.juice.sound.play(Sfx.wardenClang);
      return false;
    }

    final wasPhase = (hp - 1) ~/ _phaseMaxHp;
    final killed = super.receiveHit(damage, bullet);
    if (killed) return true;

    final nowPhase = (hp - 1) ~/ _phaseMaxHp;
    if (nowPhase < wasPhase) {
      // Phase break: big moment + shield-down punish window.
      _phase = phasesTotal - 1 - nowPhase;
      _shieldDownTimer = GameBalance.I.warden.shieldDownDuration;
      _speedBoost += 0.35;
      game.juice.wardenFeedback(position.clone());
      _summonMinions();
    }
    return false;
  }

  @override
  void updateBehavior(double dt) {
    final w = GameBalance.I.warden;
    _rotation += w.rotationSpeed * _speedBoost * dt;
    if (_shieldDownTimer > 0) _shieldDownTimer -= dt;

    // Attack cycle: idle count-up → telegraphed charge → radial burst.
    if (w.burstCount > 0) {
      if (_charging) {
        _charge -= dt;
        if (_charge <= 0) {
          _fireBurst(w);
          _attackTimer = 0;
        }
      } else {
        _attackTimer += dt;
        if (_attackTimer >= w.attackInterval) _charge = w.attackTelegraph;
      }
    }

    // Hold still while winding up so the charge reads as a clear tell.
    if (!_charging) seekPlayer(dt, w.speed * _speedBoost);
    clampToArena();
    if (overlapsPlayer()) game.player.takeContactDamage(this);

    _pushBossHud();
  }

  /// Fires [WardenBalance.burstCount] interceptable projectiles evenly around
  /// the circle — dodge the gaps or shoot them down (any bounce count).
  void _fireBurst(WardenBalance w) {
    for (var i = 0; i < w.burstCount; i++) {
      final angle = _rotation + i * (2 * math.pi / w.burstCount);
      final dir = Vector2(math.cos(angle), math.sin(angle));
      game.world.add(EnemyProjectileComponent(
        position: position + dir * (bodyRadius + 10),
        velocity: dir * w.projectileSpeed,
        cause: 'warden',
        color: AppColors.amber400,
        radiusOverride: GameBalance.I.turret.projectileRadius + 1,
      ));
    }
    game.juice.addTrauma(0.3);
    game.juice.sound.play(Sfx.wardenClang);
  }

  /// Spawns small-Drifter reinforcements on a phase break — turning the
  /// shield-down punish window into a real risk/reward decision.
  void _summonMinions() {
    final count = GameBalance.I.warden.summonOnPhaseBreak;
    if (count <= 0) return;
    game.spawner.spawnMinions(position.clone(), count,
        speedMult: speedMult, hpMult: 1);
  }

  @override
  void renderShape(Canvas canvas) {
    canvas.save();
    canvas.rotate(_rotation);

    // Core: rotating square-ish polygon, white hot.
    final core = Path();
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final p = Offset(
        bodyRadius * 0.62 * math.cos(angle),
        bodyRadius * 0.62 * math.sin(angle),
      );
      i == 0 ? core.moveTo(p.dx, p.dy) : core.lineTo(p.dx, p.dy);
    }
    core.close();
    canvas.drawPath(core, Paint()..color = color);

    // Amber shield ring (segmented) while up.
    if (shieldUp) {
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = AppColors.amber500.withValues(alpha: 0.9);
      for (var i = 0; i < 4; i++) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: bodyRadius),
          i * math.pi / 2 + 0.18,
          math.pi / 2 - 0.36,
          false,
          ring,
        );
      }
    }
    canvas.restore();

    // Burst telegraph: a warning ring that swells toward the body as the
    // charge burns down — reads the imminent radial spray.
    if (_charging) {
      final t = 1 - (_charge / GameBalance.I.warden.attackTelegraph)
          .clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset.zero,
        bodyRadius * (2.2 - t),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 + t * 4
          ..color = AppColors.error.withValues(alpha: 0.25 + t * 0.55),
      );
      // Faint spoke hints in the directions the burst will travel.
      final hint = Paint()
        ..strokeWidth = 2
        ..color = AppColors.amber300.withValues(alpha: 0.2 + t * 0.4);
      final n = GameBalance.I.warden.burstCount;
      for (var i = 0; i < n; i++) {
        final a = _rotation + i * (2 * math.pi / n);
        final d = Offset(math.cos(a), math.sin(a));
        canvas.drawLine(
          Offset(d.dx * bodyRadius, d.dy * bodyRadius),
          Offset(d.dx * bodyRadius * (1.4 + t * 0.6),
              d.dy * bodyRadius * (1.4 + t * 0.6)),
          hint,
        );
      }
    }

    // Phase HP bar above the boss (drawn unrotated).
    const barWidth = 110.0;
    const barHeight = 8.0;
    final top = Offset(-barWidth / 2, -bodyRadius - 26);
    canvas.drawRect(
      Rect.fromLTWH(top.dx, top.dy, barWidth, barHeight),
      Paint()..color = const Color(0x66000000),
    );
    final frac = (phaseHp / _phaseMaxHp).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(top.dx, top.dy, barWidth * frac, barHeight),
      Paint()..color = AppColors.amber400,
    );
    // Phase pips.
    for (var i = 0; i < phasesTotal; i++) {
      canvas.drawCircle(
        Offset(top.dx + 10 + i * 14, top.dy - 8),
        4,
        Paint()
          ..color = i >= _phase ? AppColors.amber400 : AppColors.ink400,
      );
    }
  }
}
