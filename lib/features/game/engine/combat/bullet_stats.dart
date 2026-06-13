import 'package:deadbounce_flutter_app/core/config/game_balance.dart';

/// Immutable per-shot stats, built from [GameBalance] and folded through the
/// active upgrade modifiers at fire time.
class BulletStats {
  const BulletStats({
    required this.damagePerBounce,
    required this.speedGainPerBounce,
    required this.maxBounces,
    required this.lifetime,
    required this.radius,
  });

  factory BulletStats.base() {
    final t = GameBalance.I.bullet;
    return BulletStats(
      damagePerBounce: t.damagePerBounce,
      speedGainPerBounce: t.speedGainPerBounce,
      maxBounces: t.maxBounces,
      lifetime: t.lifetime,
      radius: t.radius,
    );
  }

  final int damagePerBounce;
  final double speedGainPerBounce;
  final int maxBounces;
  final double lifetime;
  final double radius;

  BulletStats copyWith({
    int? damagePerBounce,
    double? speedGainPerBounce,
    int? maxBounces,
    double? lifetime,
    double? radius,
  }) =>
      BulletStats(
        damagePerBounce: damagePerBounce ?? this.damagePerBounce,
        speedGainPerBounce: speedGainPerBounce ?? this.speedGainPerBounce,
        maxBounces: maxBounces ?? this.maxBounces,
        lifetime: lifetime ?? this.lifetime,
        radius: radius ?? this.radius,
      );
}
