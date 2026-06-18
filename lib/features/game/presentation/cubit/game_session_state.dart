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
  const SessionUpgradePicking(this.waveCleared, this.choices);

  final int waveCleared;
  final List<UpgradeCard> choices;

  @override
  List<Object?> get props => [waveCleared, choices.map((c) => c.id).toList()];
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
