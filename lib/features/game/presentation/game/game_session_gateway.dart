import '../../engine/upgrades/upgrade_card.dart';

/// Snapshot of run stats the game reports upward at run end (the cubit
/// turns it into a RunResult for the data layer).
class RunStatsSnapshot {
  const RunStatsSnapshot({
    required this.score,
    required this.waveReached,
    required this.kills,
    required this.bestChain,
    required this.maxBounceKill,
    required this.coinsEarned,
    required this.durationSeconds,
    required this.upgradesPicked,
    required this.enemyKills,
    required this.hitsTaken,
    this.causeOfDeath,
  });

  final int score;
  final int waveReached;
  final int kills;
  final int bestChain;
  final int maxBounceKill;
  final int coinsEarned;
  final double durationSeconds;
  final List<String> upgradesPicked;
  final Map<String, int> enemyKills;

  /// Times the player lost a heart this run (0 = flawless).
  final int hitsTaken;

  /// Source of the fatal blow — an enemy id (drifter/charger/splitter/
  /// turret/warden/smallDrifter) — used only for the death-beat copy.
  /// Null when unknown.
  final String? causeOfDeath;
}

/// How the Flame game talks to the run lifecycle owner (GameSessionCubit)
/// without importing any bloc code — fully fakeable in tests.
abstract interface class GameSessionGateway {
  /// Wave cleared; the game has paused itself. [choices] are the 3 drawn
  /// upgrade cards.
  void onWaveCleared(int wave, List<UpgradeCard> choices);

  /// Player died; the game is over.
  void onRunEnded(RunStatsSnapshot stats);
}
