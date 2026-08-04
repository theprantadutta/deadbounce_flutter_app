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
    this.rerollEnabled = false,
  });

  final int waveCleared;
  final List<UpgradeCard> choices;

  /// Coin cost to reroll this draft. Escalates per PAID use in-run, and is 0
  /// while a Second Opinion charge is in hand.
  final int rerollCost;

  /// Player coin balance at pick time — gates the reroll button.
  final int balance;

  /// Whether rerolling is offered at all. Separate from [rerollCost] because
  /// zero now has two meanings: challenges/tournaments disable rerolls to keep
  /// seeded draws pure, while a Second Opinion charge makes one FREE. Reading
  /// "cost == 0" as unavailable would silently swallow the item the player
  /// bought.
  final bool rerollEnabled;

  /// Free rerolls are always takeable; paid ones need the coins.
  bool get canReroll =>
      rerollEnabled && (rerollCost == 0 || balance >= rerollCost);

  @override
  List<Object?> get props => [
        waveCleared,
        choices.map((c) => c.id).toList(),
        rerollCost,
        balance,
        rerollEnabled,
      ];
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
