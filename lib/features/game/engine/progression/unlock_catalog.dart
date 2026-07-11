/// Play-gated content unlocks (Phase 4 "meta soul"). Unlocks are a PURE
/// function of lifetime stats the app already tracks and syncs (best wave,
/// runs played, lifetime kills) — so there is no new table, no new sync event,
/// and it survives a reinstall for free (the underlying stats restore via the
/// snapshot). Content NOT listed here is always unlocked (the starting kit:
/// the 3 original arenas + the 12 original upgrade cards).
///
/// Gating applies to **normal runs only**. Daily challenges and tournaments
/// use the full catalog so they stay identical worldwide.
library;

/// The lifetime signals unlocks are gated on. A plain snapshot so the catalog
/// stays Flutter-free and unit-testable.
class UnlockStats {
  const UnlockStats({
    this.bestWave = 0,
    this.runsPlayed = 0,
    this.lifetimeKills = 0,
  });

  final int bestWave;
  final int runsPlayed;
  final int lifetimeKills;

  /// Everything unlocked — used for daily challenges / tournaments (no gating)
  /// and as a safe fallback.
  static const unlimited =
      UnlockStats(bestWave: 1 << 30, runsPlayed: 1 << 30, lifetimeKills: 1 << 30);
}

enum UnlockMetric { bestWave, runsPlayed, lifetimeKills }

/// One unlock condition: a metric crossing a threshold.
class UnlockRequirement {
  const UnlockRequirement(this.metric, this.threshold);

  final UnlockMetric metric;
  final int threshold;

  bool met(UnlockStats s) => switch (metric) {
        UnlockMetric.bestWave => s.bestWave >= threshold,
        UnlockMetric.runsPlayed => s.runsPlayed >= threshold,
        UnlockMetric.lifetimeKills => s.lifetimeKills >= threshold,
      };

  /// Player-facing hint, e.g. "Reach wave 8".
  String get label => switch (metric) {
        UnlockMetric.bestWave => 'Reach wave $threshold',
        UnlockMetric.runsPlayed => 'Play $threshold runs',
        UnlockMetric.lifetimeKills => '$threshold lifetime kills',
      };
}

abstract final class UnlockCatalog {
  /// Arena id → the milestone that reveals it. The 3 originals are absent =
  /// always unlocked. Thresholds escalate so runs keep revealing new geometry.
  static const Map<String, UnlockRequirement> arenas = {
    'arena_crossfire': UnlockRequirement(UnlockMetric.bestWave, 4),
    'arena_saloon': UnlockRequirement(UnlockMetric.bestWave, 7),
    'arena_hourglass': UnlockRequirement(UnlockMetric.bestWave, 10),
    'arena_chute': UnlockRequirement(UnlockMetric.bestWave, 13),
    'arena_wishbone': UnlockRequirement(UnlockMetric.runsPlayed, 10),
    'arena_fourposts': UnlockRequirement(UnlockMetric.bestWave, 17),
  };

  /// Card id → the milestone that adds it to the draft pool. The 12 originals
  /// are absent = always unlocked. The Phase-3 cards reveal with play.
  static const Map<String, UnlockRequirement> cards = {
    'long_fuse': UnlockRequirement(UnlockMetric.runsPlayed, 2),
    'greased_lead': UnlockRequirement(UnlockMetric.bestWave, 5),
    'rifling': UnlockRequirement(UnlockMetric.bestWave, 8),
    'flashpoint': UnlockRequirement(UnlockMetric.bestWave, 11),
    'chain_lightning': UnlockRequirement(UnlockMetric.bestWave, 14),
    'shrapnel': UnlockRequirement(UnlockMetric.lifetimeKills, 300),
    'fan_fire': UnlockRequirement(UnlockMetric.runsPlayed, 12),
    'vengeance': UnlockRequirement(UnlockMetric.bestWave, 18),
  };

  static bool _unlocked(
          Map<String, UnlockRequirement> reqs, String id, UnlockStats s) =>
      reqs[id]?.met(s) ?? true; // ungated content is always unlocked

  static bool isArenaUnlocked(String id, UnlockStats s) =>
      _unlocked(arenas, id, s);

  static bool isCardUnlocked(String id, UnlockStats s) =>
      _unlocked(cards, id, s);

  /// The subset of [all] card ids currently unlocked at [stats].
  static Set<String> unlockedCardIds(Iterable<String> all, UnlockStats stats) =>
      {for (final id in all) if (isCardUnlocked(id, stats)) id};

  /// The subset of [all] arenas currently unlocked at [stats] (never empty —
  /// the originals are always in).
  static List<T> unlockedArenas<T>(
          List<T> all, String Function(T) idOf, UnlockStats stats) =>
      [for (final a in all) if (isArenaUnlocked(idOf(a), stats)) a];
}
