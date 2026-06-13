part of 'daily_reward_cubit.dart';

sealed class DailyRewardState extends Equatable {
  const DailyRewardState();

  @override
  List<Object?> get props => [];
}

final class DailyRewardLoading extends DailyRewardState {
  const DailyRewardLoading();
}

final class DailyRewardError extends DailyRewardState {
  const DailyRewardError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class DailyRewardReady extends DailyRewardState {
  const DailyRewardReady(this.streak);
  final StreakState streak;

  @override
  List<Object?> get props => [streak];
}

final class DailyRewardClaiming extends DailyRewardState {
  const DailyRewardClaiming(this.streak);
  final StreakState streak;

  @override
  List<Object?> get props => [streak];
}

final class DailyRewardClaimed extends DailyRewardState {
  const DailyRewardClaimed(this.streak, this.result);
  final StreakState streak;
  final StreakClaimResult result;

  @override
  List<Object?> get props => [streak, result];
}
