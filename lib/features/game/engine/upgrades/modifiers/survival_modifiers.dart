import '../../combat/player_stats.dart';
import '../upgrade_modifier.dart';

/// Last Stand — survive one fatal hit per run (the player is left at one
/// heart with extended i-frames; the game layer handles the spectacle).
class LastStandModifier extends UpgradeModifier {
  bool _consumed = false;

  bool get consumed => _consumed;

  @override
  String get id => 'last_stand';

  @override
  void onPlayerDamaged(PlayerDamageContext ctx) {
    if (_consumed || ctx.heartsAfter > 0) return;
    _consumed = true;
    ctx.preventDeath();
  }
}

/// Coin Magnet — run coins ×1.25 per stack, and a wider pickup radius.
class CoinMagnetModifier extends UpgradeModifier {
  @override
  String get id => 'coin_magnet';

  @override
  void onCoinEarned(CoinContext ctx) {
    for (var i = 0; i < stacks; i++) {
      ctx.amount *= 1.25;
    }
  }

  @override
  PlayerStats transformPlayerStats(PlayerStats stats) => stats.copyWith(
      coinPickupRadius: stats.coinPickupRadius * (1 + 0.6 * stacks));
}
