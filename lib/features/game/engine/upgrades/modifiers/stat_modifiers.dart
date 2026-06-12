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
