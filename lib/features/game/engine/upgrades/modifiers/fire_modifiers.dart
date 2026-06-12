import '../../physics/vector_utils.dart';
import '../upgrade_modifier.dart';

/// Ghost Round — every 4th shot passes through one wall (the solver
/// consumes the charge; the preview renders the pass-through).
class GhostRoundModifier extends UpgradeModifier {
  @override
  String get id => 'ghost_round';

  @override
  void onFire(FireContext ctx) {
    if (ctx.shotIndex % 4 == 0) {
      for (final shot in ctx.shots) {
        shot.flags.ghostPassesRemaining = 1;
      }
    }
  }
}

/// Echo Shot — 10% chance per stack to fire a free duplicate, slightly
/// delayed and jittered. Appended within the same fire event, so it
/// never consumes cooldown.
class EchoShotModifier extends UpgradeModifier {
  static const double _chancePerStack = 0.10;
  static const double _delaySeconds = 0.06;
  static const double _jitterRadians = 0.035; // ~2 degrees

  @override
  String get id => 'echo_shot';

  @override
  void onFire(FireContext ctx) {
    if (!ctx.world.rng.chance(_chancePerStack * stacks)) return;

    final originals = List.of(ctx.shots);
    for (final shot in originals) {
      final jitter =
          ctx.world.rng.range(-_jitterRadians, _jitterRadians);
      ctx.shots.add(PendingShot(
        direction: shot.direction.clone()..rotateBy(jitter),
        speed: shot.speed,
        delaySeconds: _delaySeconds,
      ));
    }
  }
}
