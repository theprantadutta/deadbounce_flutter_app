part of 'statistics_cubit.dart';

sealed class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

final class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

final class StatisticsError extends StatisticsState {
  const StatisticsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class StatisticsLoaded extends StatisticsState {
  const StatisticsLoaded(this.stats);
  final GameStatistics stats;

  @override
  List<Object?> get props => [stats];
}
