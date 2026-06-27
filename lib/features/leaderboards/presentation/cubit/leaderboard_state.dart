part of 'leaderboard_cubit.dart';

enum LeaderboardStatus { loading, ready, error }

class LeaderboardState extends Equatable {
  const LeaderboardState({
    required this.tab,
    required this.status,
    this.board,
    this.refreshing = false,
    this.offline = false,
    this.error,
  });

  const LeaderboardState.initial()
      : tab = LeaderboardTab.daily,
        status = LeaderboardStatus.loading,
        board = null,
        refreshing = false,
        offline = false,
        error = null;

  final LeaderboardTab tab;
  final LeaderboardStatus status;
  final LeaderboardBoard? board;
  final bool refreshing;

  /// True when the latest refresh failed (offline) but a cached board is shown,
  /// so the UI can flag the standings as stale/last-synced rather than live.
  final bool offline;
  final String? error;

  LeaderboardState copyWith({
    LeaderboardTab? tab,
    LeaderboardStatus? status,
    LeaderboardBoard? board,
    bool? refreshing,
    bool? offline,
    String? error,
    bool clearError = false,
  }) {
    return LeaderboardState(
      tab: tab ?? this.tab,
      status: status ?? this.status,
      board: board ?? this.board,
      refreshing: refreshing ?? this.refreshing,
      offline: offline ?? this.offline,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [tab, status, board, refreshing, offline, error];
}
