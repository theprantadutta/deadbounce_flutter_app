import '../achievement_catalog.dart';
import '../entities/achievement_view.dart';

/// Run summary the achievement evaluator folds against lifetime stats.
class RunAchievementInput {
  const RunAchievementInput({
    required this.score,
    required this.wave,
    required this.bestChain,
    required this.maxBounceKill,
    required this.upgradesPicked,
    required this.hitsTaken,
    required this.isDailyChallenge,
  });

  final int score;
  final int wave;
  final int bestChain;
  final int maxBounceKill;
  final int upgradesPicked;
  final int hitsTaken;
  final bool isDailyChallenge;
}

abstract interface class AchievementsRepository {
  Future<List<AchievementView>> getAll();

  Stream<List<AchievementView>> watchAll();

  /// Evaluates every achievement against this run + the (already updated)
  /// lifetime stats, raising progress and unlocking newly-met ones.
  /// Returns the definitions unlocked by THIS evaluation (for a toast).
  Future<List<AchievementDefinition>> evaluateRun(RunAchievementInput run);

  /// Grants the coin reward for an unlocked achievement (ledger + outbox)
  /// and marks it claimed. No-op if not unlocked or already claimed.
  Future<void> claim(String achievementId);
}
