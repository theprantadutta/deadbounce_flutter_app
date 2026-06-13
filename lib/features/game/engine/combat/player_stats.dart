import 'package:deadbounce_flutter_app/core/config/game_balance.dart';

/// Immutable player stats, folded through the active upgrade modifiers
/// whenever a card is picked.
class PlayerStats {
  const PlayerStats({
    required this.maxHearts,
    required this.fireCooldown,
    required this.previewBounces,
    required this.coinPickupRadius,
  });

  factory PlayerStats.base() {
    final t = GameBalance.I.player;
    return PlayerStats(
      maxHearts: t.maxHearts,
      fireCooldown: t.fireCooldown,
      previewBounces: t.previewBounces,
      coinPickupRadius: t.coinPickupRadius,
    );
  }

  final int maxHearts;
  final double fireCooldown;
  final int previewBounces;
  final double coinPickupRadius;

  PlayerStats copyWith({
    int? maxHearts,
    double? fireCooldown,
    int? previewBounces,
    double? coinPickupRadius,
  }) =>
      PlayerStats(
        maxHearts: maxHearts ?? this.maxHearts,
        fireCooldown:
            (fireCooldown ?? this.fireCooldown).clamp(
                GameBalance.I.player.minFireCooldown, double.infinity),
        previewBounces: previewBounces ?? this.previewBounces,
        coinPickupRadius: coinPickupRadius ?? this.coinPickupRadius,
      );
}
