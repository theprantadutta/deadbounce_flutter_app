import 'package:equatable/equatable.dart';

/// Everything a completed run produced. Built by the game layer at run
/// end and handed to [RunsRepository.recordCompletedRun] — the single
/// entry point into the data plane for gameplay.
class RunResult extends Equatable {
  const RunResult({
    required this.id,
    required this.score,
    required this.waveReached,
    required this.kills,
    required this.bestChain,
    required this.maxBounceKill,
    required this.duration,
    required this.coinsEarned,
    required this.arenaId,
    required this.upgradesPicked,
    required this.endedAt,
    this.enemyKills = const {},
    this.isDailyChallenge = false,
    this.challengeDate,
    this.challengeSeed,
  });

  final String id;
  final int score;
  final int waveReached;
  final int kills;
  final int bestChain;
  final int maxBounceKill;
  final Duration duration;
  final int coinsEarned;
  final String arenaId;

  /// Upgrade card ids in pick order.
  final List<String> upgradesPicked;
  final DateTime endedAt;

  /// Per-enemy-type kill counts for stat counters.
  final Map<String, int> enemyKills;

  final bool isDailyChallenge;

  /// UTC date yyyy-MM-dd of the challenge, when [isDailyChallenge].
  final String? challengeDate;
  final int? challengeSeed;

  @override
  List<Object?> get props => [
        id,
        score,
        waveReached,
        kills,
        bestChain,
        maxBounceKill,
        duration,
        coinsEarned,
        arenaId,
        upgradesPicked,
        endedAt,
        enemyKills,
        isDailyChallenge,
        challengeDate,
        challengeSeed,
      ];
}
