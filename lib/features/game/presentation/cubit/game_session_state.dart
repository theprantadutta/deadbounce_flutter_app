part of 'game_session_cubit.dart';

sealed class GameSessionState extends Equatable {
  const GameSessionState();

  @override
  List<Object?> get props => [];
}

final class SessionIdle extends GameSessionState {
  const SessionIdle();
}

final class SessionPlaying extends GameSessionState {
  const SessionPlaying();
}

final class SessionPaused extends GameSessionState {
  const SessionPaused();
}

final class SessionUpgradePicking extends GameSessionState {
  const SessionUpgradePicking(
    this.waveCleared,
    this.choices, {
    this.rerollCost = 0,
    this.balance = 0,
  });

  final int waveCleared;
  final List<UpgradeCard> choices;

  /// Coin cost to reroll this draft (escalates per use in-run). 0 = reroll
  /// unavailable (challenges/tournaments keep seeded draws pure).
  final int rerollCost;

  /// Player coin balance at pick time — gates the reroll button.
  final int balance;

  bool get canReroll => rerollCost > 0 && balance >= rerollCost;

  @override
  List<Object?> get props =>
      [waveCleared, choices.map((c) => c.id).toList(), rerollCost, balance];
}

/// A fatal hit landed on a normal run and a paid buy-back is on the table.
/// The engine is frozen; the player buys the continue or lets the run end.
final class SessionAwaitingContinue extends GameSessionState {
  const SessionAwaitingContinue({
    required this.wave,
    required this.cost,
    required this.canAfford,
  });

  final int wave;
  final int cost;
  final bool canAfford;

  @override
  List<Object?> get props => [wave, cost, canAfford];
}

/// The brief death beat: a freeze + "what happened" before the results.
final class SessionRunEnding extends GameSessionState {
  const SessionRunEnding({
    required this.headline,
    required this.detail,
    required this.wave,
  });

  final String headline;
  final String detail;
  final int wave;

  @override
  List<Object?> get props => [headline, detail, wave];
}

final class SessionRunOver extends GameSessionState {
  const SessionRunOver(
    this.result, {
    required this.isNewBestScore,
    this.unlockedAchievements = const [],
  });

  final RunResult result;
  final bool isNewBestScore;

  /// Names of achievements unlocked by this run (for the results screen).
  final List<String> unlockedAchievements;

  @override
  List<Object?> get props => [result, isNewBestScore, unlockedAchievements];
}
