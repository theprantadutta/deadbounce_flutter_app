import 'package:equatable/equatable.dart';

/// Lifetime gameplay statistics, aggregated from the local Drift store
/// (`player_stats` + `stat_counters`). Read-only view for the Statistics
/// screen — distinct from `ProfileData`, which is account-focused.
class GameStatistics extends Equatable {
  const GameStatistics({
    required this.runsPlayed,
    required this.totalKills,
    required this.totalWavesCleared,
    required this.totalCoinsEarned,
    required this.totalPlayMs,
    required this.bestScore,
    required this.bestChain,
    required this.bestBounceKill,
    required this.bestWave,
    required this.enemyKills,
    required this.favoriteUpgradeId,
  });

  const GameStatistics.empty()
      : runsPlayed = 0,
        totalKills = 0,
        totalWavesCleared = 0,
        totalCoinsEarned = 0,
        totalPlayMs = 0,
        bestScore = 0,
        bestChain = 0,
        bestBounceKill = 0,
        bestWave = 0,
        enemyKills = const {},
        favoriteUpgradeId = null;

  final int runsPlayed;
  final int totalKills;
  final int totalWavesCleared;
  final int totalCoinsEarned;
  final int totalPlayMs;

  final int bestScore;
  final int bestChain;
  final int bestBounceKill;
  final int bestWave;

  /// Kills per enemy id ('drifter', 'small_drifter', 'charger', 'splitter',
  /// 'turret', 'warden').
  final Map<String, int> enemyKills;

  /// Most-picked upgrade id across all runs, or null when none yet.
  final String? favoriteUpgradeId;

  bool get hasPlayed => runsPlayed > 0;

  Duration get totalPlayTime => Duration(milliseconds: totalPlayMs);

  double get avgKillsPerRun => runsPlayed == 0 ? 0 : totalKills / runsPlayed;
  double get avgWavesPerRun =>
      runsPlayed == 0 ? 0 : totalWavesCleared / runsPlayed;
  double get avgCoinsPerRun =>
      runsPlayed == 0 ? 0 : totalCoinsEarned / runsPlayed;

  /// The enemy id the player has killed the most, or null when none yet.
  String? get mostKilledEnemyId {
    if (enemyKills.isEmpty) return null;
    return enemyKills.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  @override
  List<Object?> get props => [
        runsPlayed,
        totalKills,
        totalWavesCleared,
        totalCoinsEarned,
        totalPlayMs,
        bestScore,
        bestChain,
        bestBounceKill,
        bestWave,
        enemyKills,
        favoriteUpgradeId,
      ];
}
