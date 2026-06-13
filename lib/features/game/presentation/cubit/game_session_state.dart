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

final class SessionRunOver extends GameSessionState {
  const SessionRunOver(this.result, {required this.isNewBestScore});

  final RunResult result;
  final bool isNewBestScore;

  @override
  List<Object?> get props => [result, isNewBestScore];
}
