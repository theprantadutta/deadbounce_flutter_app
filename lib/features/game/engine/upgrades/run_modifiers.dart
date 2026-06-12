import '../combat/bullet_stats.dart';
import '../combat/player_stats.dart';
import 'upgrade_card.dart';
import 'upgrade_modifier.dart';

/// The active upgrade stack for one run: stat folding (cached) + hook
/// dispatch. Run-scoped — modifier instances may carry per-run state
/// (Last Stand's consumed flag).
class RunModifiers {
  final List<UpgradeModifier> _active = [];
  final List<String> pickedIds = [];

  PlayerStats? _cachedPlayerStats;
  BulletStats? _cachedBulletStats;

  List<UpgradeModifier> get active => List.unmodifiable(_active);

  /// Stacks of one card currently held.
  int stacksOf(String cardId) =>
      _active.where((m) => m.id == cardId).fold(0, (sum, m) => sum + m.stacks);

  void add(UpgradeCard card) {
    pickedIds.add(card.id);
    final existing = _active.where((m) => m.id == card.id).firstOrNull;
    if (existing != null) {
      existing.stacks++;
    } else {
      _active.add(card.buildModifier());
    }
    _cachedPlayerStats = null;
    _cachedBulletStats = null;
  }

  PlayerStats effectivePlayerStats() =>
      _cachedPlayerStats ??= _active.fold<PlayerStats>(
          PlayerStats.base(), (s, m) => m.transformPlayerStats(s));

  BulletStats effectiveBulletStats() =>
      _cachedBulletStats ??= _active.fold<BulletStats>(
          BulletStats.base(), (s, m) => m.transformBulletStats(s));

  void fire(FireContext ctx) {
    for (final m in _active) {
      m.onFire(ctx);
    }
  }

  void bounce(BounceContext ctx) {
    for (final m in _active) {
      m.onBounce(ctx);
    }
  }

  void bulletUpdate(BulletUpdateContext ctx, double dt) {
    for (final m in _active) {
      m.onBulletUpdate(ctx, dt);
    }
  }

  void kill(KillContext ctx) {
    for (final m in _active) {
      m.onKill(ctx);
    }
  }

  void playerDamaged(PlayerDamageContext ctx) {
    for (final m in _active) {
      m.onPlayerDamaged(ctx);
    }
  }

  void coinEarned(CoinContext ctx) {
    for (final m in _active) {
      m.onCoinEarned(ctx);
    }
  }
}
