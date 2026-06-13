part of 'leaderboard_cubit.dart';

enum LeaderboardStatus { loading, ready, error }

class LeaderboardState extends Equatable {
  const LeaderboardState({
    required this.tab,
    required this.status,
    this.board,
    this.refreshing = false,
    this.error,
  });

  const LeaderboardState.initial()
      : tab = LeaderboardTab.daily,
        status = LeaderboardStatus.loading,
        board = null,
        refreshing = false,
        error = null;

  final LeaderboardTab tab;
  final LeaderboardStatus status;
  final LeaderboardBoard? board;
  final bool refreshing;
  final String? error;

  LeaderboardState copyWith({
    LeaderboardTab? tab,
    LeaderboardStatus? status,
    LeaderboardBoard? board,
    bool? refreshing,
    String? error,
    bool clearError = false,
  }) {
    return LeaderboardState(
      tab: tab ?? this.tab,
      status: status ?? this.status,
      board: board ?? this.board,
      refreshing: refreshing ?? this.refreshing,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [tab, status, board, refreshing, error];
}
