import '../../combat/bullet_stats.dart';
import '../../combat/player_stats.dart';
import '../upgrade_modifier.dart';

/// Rubber Walls — +1 damage per bounce per stack (1 → 2 → 3...). The
/// damage getter picks it up everywhere automatically, Warden included.
class RubberWallsModifier extends UpgradeModifier {
  @override
  String get id => 'rubber_walls';

  @override
  BulletStats transformBulletStats(BulletStats stats) =>
      stats.copyWith(damagePerBounce: stats.damagePerBounce + stacks);
}

/// Longer Sight — trajectory preview shows +1 bounce per stack.
class LongerSightModifier extends UpgradeModifier {
  @override
  String get id => 'longer_sight';

  @override
  PlayerStats transformPlayerStats(PlayerStats stats) =>
      stats.copyWith(previewBounces: stats.previewBounces + stacks);
}

/// Quickdraw — fire cooldown ×0.78 per stack (floored by tuning).
class QuickdrawModifier extends UpgradeModifier {
  @override
  String get id => 'quickdraw';

  @override
  PlayerStats transformPlayerStats(PlayerStats stats) {
    var cooldown = stats.fireCooldown;
    for (var i = 0; i < stacks; i++) {
      cooldown *= 0.78;
    }
    return stats.copyWith(fireCooldown: cooldown);
  }
}

/// Heart Container — +1 max HP per stack. The heal on pick is applied by
/// the game when the card lands (transforms must stay pure).
class HeartContainerModifier extends UpgradeModifier {
  @override
  String get id => 'heart_container';

  @override
  PlayerStats transformPlayerStats(PlayerStats stats) =>
      stats.copyWith(maxHearts: stats.maxHearts + stacks);
}

/// Heavy Caliber — bullet radius ×1.4 per stack. The solver and the
/// preview both read the radius, so bigger bullets genuinely bounce
/// earlier off walls and the aim line matches.
class HeavyCaliberModifier extends UpgradeModifier {
  @override
  String get id => 'heavy_caliber';

  @override
  BulletStats transformBulletStats(BulletStats stats) {
    var radius = stats.radius;
    for (var i = 0; i < stacks; i++) {
      radius *= 1.4;
    }
    return stats.copyWith(radius: radius);
  }
}

/// Long Fuse — +1.2s bullet lifetime per stack. A slug lives longer, so it
/// keeps threading kills deeper into a chain before it fizzles.
class LongFuseModifier extends UpgradeModifier {
  static const double _perStack = 1.2;

  @override
  String get id => 'long_fuse';

  @override
  BulletStats transformBulletStats(BulletStats stats) =>
      stats.copyWith(lifetime: stats.lifetime + _perStack * stacks);
}

/// Greased Lead — +0.03 speed-gain-per-bounce per stack (on top of the base
/// +12%). Deep ricochets accelerate harder — a hotter, faster kill line.
class GreasedLeadModifier extends UpgradeModifier {
  static const double _perStack = 0.03;

  @override
  String get id => 'greased_lead';

  @override
  BulletStats transformBulletStats(BulletStats stats) => stats.copyWith(
      speedGainPerBounce: stats.speedGainPerBounce + _perStack * stacks);
}

/// Rifling — +2 max bounces per stack. Bullets can ride the walls further,
/// which means both longer chains AND harder-hitting late bounces (damage
/// scales with the bounce count — the core rule does the rest).
class RiflingModifier extends UpgradeModifier {
  static const int _perStack = 2;

  @override
  String get id => 'rifling';

  @override
  BulletStats transformBulletStats(BulletStats stats) =>
      stats.copyWith(maxBounces: stats.maxBounces + _perStack * stacks);
}
