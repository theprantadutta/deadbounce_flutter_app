import '../../combat/bullet_state.dart';
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

/// Fan Fire — every shot fans into three: the aimed slug plus two more at
/// ±14°. A wall of lead that turns a near-miss into a bank shot.
class FanFireModifier extends UpgradeModifier {
  static const double _spread = 0.244; // ~14°

  @override
  String get id => 'fan_fire';

  @override
  void onFire(FireContext ctx) {
    final originals = List.of(ctx.shots);
    for (final shot in originals) {
      for (final sign in const [-1.0, 1.0]) {
        ctx.shots.add(
          PendingShot(
            direction: shot.direction.clone()..rotateBy(_spread * sign),
            speed: shot.speed,
            // Carry a queued Ghost pass onto the fanned shots too.
            flags: BulletFlags(
              ghostPassesRemaining: shot.flags.ghostPassesRemaining,
            ),
          ),
        );
      }
    }
  }
}

/// Vengeance — take a hit and your NEXT shot answers with a rapid three-round
/// burst down the same line. Punished, then punishing.
class VengeanceModifier extends UpgradeModifier {
  bool _charged = false;

  @override
  String get id => 'vengeance';

  @override
  void onPlayerDamaged(PlayerDamageContext ctx) {
    // Only if the hit wasn't fatal — you have to live to retaliate.
    if (ctx.heartsAfter > 0) _charged = true;
  }

  @override
  void onFire(FireContext ctx) {
    if (!_charged) return;
    _charged = false;
    final originals = List.of(ctx.shots);
    for (final shot in originals) {
      for (final delay in const [0.05, 0.10]) {
        ctx.shots.add(
          PendingShot(
            direction: shot.direction.clone(),
            speed: shot.speed,
            delaySeconds: delay,
          ),
        );
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
      final jitter = ctx.world.rng.range(-_jitterRadians, _jitterRadians);
      ctx.shots.add(
        PendingShot(
          direction: shot.direction.clone()..rotateBy(jitter),
          speed: shot.speed,
          delaySeconds: _delaySeconds,
          // Inherit the source shot's flags (e.g. a queued Ghost pass) as an
          // OWN instance so the echo behaves like its source regardless of
          // modifier order, without sharing mutable state.
          flags: BulletFlags(
            ghostPassesRemaining: shot.flags.ghostPassesRemaining,
            hasSplit: shot.flags.hasSplit,
            trailCooldown: shot.flags.trailCooldown,
          ),
        ),
      );
    }
  }
}
