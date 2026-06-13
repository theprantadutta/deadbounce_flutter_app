part of 'daily_challenge_cubit.dart';

sealed class DailyChallengeState extends Equatable {
  const DailyChallengeState();

  @override
  List<Object?> get props => [];
}

final class DailyChallengeLoading extends DailyChallengeState {
  const DailyChallengeLoading();
}

final class DailyChallengeFailure extends DailyChallengeState {
  const DailyChallengeFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class DailyChallengeLoaded extends DailyChallengeState {
  const DailyChallengeLoaded(this.overview);
  final ChallengeOverview overview;

  @override
  List<Object?> get props => [overview];
}
