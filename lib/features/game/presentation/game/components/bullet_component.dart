import 'dart:ui';

import 'package:flame/components.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../engine/combat/bullet_state.dart';
import '../../../engine/combat/bullet_stats.dart';
import '../../../engine/physics/ricochet_solver.dart';
import '../../../engine/physics/swept_circle.dart';
import 'package:deadbounce_flutter_app/core/config/game_balance.dart';
import '../../../engine/upgrades/upgrade_modifier.dart';
import '../systems/sound_manager.dart';
import 'deadbounce_game.dart';
import 'popup_text_component.dart';

/// A live bullet: solver-driven movement in fixed substeps, swept hits
/// against enemies, polyline trail that heats up amber → white-hot per
/// bounce. Persists after kills — chains are the whole point.
class BulletComponent extends PositionComponent
    with HasGameReference<DeadbounceGame> {
  BulletComponent({required this.state, required this.stats})
      : super(
          position: state.position,
          anchor: Anchor.center,
          priority: 40,
        );

  final BulletState state;
  final BulletStats stats;

  static const double _substep = 1 / 120;
  static const int _trailLength = 14;

  double _accumulator = 0;
  int _lastPopupBounce = 0;
  final List<Vector2> _trail = [];

  @override
  void update(double dt) {
    super.update(dt);
    _accumulator += dt;

    while (_accumulator >= _substep) {
      _accumulator -= _substep;
      _step(_substep);
      if (isRemoved || isRemoving) return;
    }
  }

  void _step(double dt) {
    state.age += dt;
    if (state.isExpired(stats)) {
      removeFromParent();
      return;
    }

    final bouncesBefore = state.bounces;

    game.solver.advance(
      state,
      stats,
      dt,
      onBounce: _onBounce,
      onSubSegment: _sweepEnemies,
    );

    if (state.bounces != bouncesBefore) {
      // New straight segment: previous per-segment hit dedup resets.
      state.hitEnemyIds.clear();
    }

    game.modifiers.bulletUpdate(
      BulletUpdateContext(bullet: state, stats: stats, world: game),
      dt,
    );

    position.setFrom(state.position);
    _trail.add(state.position.clone());
    if (_trail.length > _trailLength) _trail.removeAt(0);
  }

  void _onBounce(BounceResult bounce) {
    game.particles.bounceSparks(
      bounce.point,
      bounce.segment.normal,
      state.bounces,
      dampened: bounce.dampened,
    );
    // Dampened bounces don't count — dull generic thud, quiet. Real
    // bounces climb in pitch with the bounce count.
    game.juice.sound.play(
      bounce.dampened ? Sfx.bounce : Sfx.bounceFor(state.bounces),
      volume: bounce.dampened ? 0.35 : 1.0,
    );

    if (!bounce.dampened && !bounce.ghosted) {
      game.modifiers.bounce(BounceContext(
        bullet: state,
        stats: stats,
        wall: bounce.segment,
        bounceIndex: state.bounces,
        world: game,
      ));

      // Bounce counter popup once per new bounce ("x2", "x3"...).
      if (state.bounces >= 2 && state.bounces != _lastPopupBounce) {
        _lastPopupBounce = state.bounces;
        game.world.add(PopupTextComponent.bounceCounter(
          'x${state.bounces}',
          bounce.point + Vector2(0, -24),
        ));
      }
    }
  }

  /// Swept circle-vs-circle along the straight segment just traveled.
  void _sweepEnemies(Vector2 from, Vector2 to) {
    if (isRemoved || isRemoving) return;
    final damage = state.damageFor(stats);

    for (final enemy in game.aliveEnemies) {
      if (state.hitEnemyIds.contains(enemy.hashCode)) continue;

      final t = sweptCircleHitT(
        from,
        to,
        enemy.position,
        stats.radius + enemy.bodyRadius,
      );
      if (t == null) continue;

      state.hitEnemyIds.add(enemy.hashCode);

      if (damage <= 0) {
        // The core rule, made visible: direct hits pass through.
        game.particles.passThroughPing(enemy.position.clone());
        continue;
      }

      if (!enemy.canBeDamagedBy(state)) {
        enemy.receiveHit(damage, this); // Warden handles the CLANG path
        continue;
      }

      enemy.receiveHit(damage, this);
    }
  }

  @override
  void render(Canvas canvas) {
    final heat =
        (state.bounces / GameBalance.I.bullet.maxBounces).clamp(0.0, 1.0);
    final hot =
        Color.lerp(AppColors.amber500, const Color(0xFFFFFFFF), heat)!;

    // Trail: fading polyline in LOCAL coords (positions are world-space).
    if (_trail.length >= 2) {
      for (var i = 1; i < _trail.length; i++) {
        final alpha = (i / _trail.length) * 0.5;
        canvas.drawLine(
          (_trail[i - 1] - position).toOffset(),
          (_trail[i] - position).toOffset(),
          Paint()
            ..strokeWidth = stats.radius * 0.8 * (i / _trail.length)
            ..strokeCap = StrokeCap.round
            ..color = hot.withValues(alpha: alpha),
        );
      }
    }

    // Fake glow + core. Ghost-charged bullets glow blue.
    final glowColor =
        state.flags.ghostPassesRemaining > 0 ? AppColors.blue300 : hot;
    canvas.drawCircle(Offset.zero, stats.radius * 2.0,
        Paint()..color = glowColor.withValues(alpha: 0.22));
    canvas.drawCircle(
        Offset.zero, stats.radius, Paint()..color = glowColor);
    canvas.drawCircle(Offset.zero, stats.radius * 0.5,
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.85));
  }
}
