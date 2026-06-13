import 'package:equatable/equatable.dart';

/// Everything the profile screen shows about the player.
class ProfileData extends Equatable {
  const ProfileData({
    required this.displayName,
    required this.isGuest,
    required this.runsPlayed,
    required this.totalKills,
    required this.bestScore,
    required this.bestChain,
    required this.bestBounceKill,
    required this.bestWave,
    required this.totalCoinsEarned,
    required this.totalPlayMs,
    required this.favoriteUpgradeId,
  });

  final String displayName;
  final bool isGuest;
  final int runsPlayed;
  final int totalKills;
  final int bestScore;
  final int bestChain;
  final int bestBounceKill;
  final int bestWave;
  final int totalCoinsEarned;
  final int totalPlayMs;

  /// Most-picked upgrade id across all runs, or null when none yet.
  final String? favoriteUpgradeId;

  Duration get totalPlayTime => Duration(milliseconds: totalPlayMs);

  @override
  List<Object?> get props => [
        displayName,
        isGuest,
        runsPlayed,
        totalKills,
        bestScore,
        bestChain,
        bestBounceKill,
        bestWave,
        totalCoinsEarned,
        totalPlayMs,
        favoriteUpgradeId,
      ];
}
