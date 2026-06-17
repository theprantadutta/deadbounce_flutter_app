import 'package:equatable/equatable.dart';

/// The personalized snapshot the home screen shows: who the player is, their
/// best run, lifetime kills, and all-time rank. Read offline-first from the
/// local Drift store via `HomeCubit`.
class HomeSummary extends Equatable {
  const HomeSummary({
    required this.displayName,
    required this.isGuest,
    required this.bestScore,
    required this.totalKills,
    required this.rank,
  });

  const HomeSummary.empty()
      : displayName = 'Drifter',
        isGuest = true,
        bestScore = 0,
        totalKills = 0,
        rank = null;

  final String displayName;
  final bool isGuest;
  final int bestScore;
  final int totalKills;

  /// All-time leaderboard rank, or null when never synced on this device.
  final int? rank;

  /// Western progression tier derived from best score — a sense of climbing.
  HomeTier get tier => HomeTier.forScore(bestScore);

  @override
  List<Object?> get props =>
      [displayName, isGuest, bestScore, totalKills, rank];
}

/// Player rank flavor, climbing with best score.
enum HomeTier {
  greenhorn('GREENHORN', 0),
  drifter('DRIFTER', 1000),
  gunslinger('GUNSLINGER', 5000),
  sharpshooter('SHARPSHOOTER', 15000),
  outlaw('OUTLAW', 40000),
  legend('LEGEND', 100000);

  const HomeTier(this.label, this.minScore);

  final String label;
  final int minScore;

  static HomeTier forScore(int score) {
    var tier = HomeTier.greenhorn;
    for (final t in HomeTier.values) {
      if (score >= t.minScore) tier = t;
    }
    return tier;
  }
}
