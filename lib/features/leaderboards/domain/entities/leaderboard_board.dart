import 'package:equatable/equatable.dart';

/// The four boards the player can browse.
enum LeaderboardTab { daily, weekly, allTime, dailyChallenge }

extension LeaderboardTabX on LeaderboardTab {
  /// URL segment for GET /leaderboards/{board}.
  String get apiPath => switch (this) {
        LeaderboardTab.daily => 'daily',
        LeaderboardTab.weekly => 'weekly',
        LeaderboardTab.allTime => 'alltime',
        LeaderboardTab.dailyChallenge => 'daily-challenge',
      };

  /// Key the board is cached under in Drift.
  String get cacheKey => name;

  String get label => switch (this) {
        LeaderboardTab.daily => 'DAILY',
        LeaderboardTab.weekly => 'WEEKLY',
        LeaderboardTab.allTime => 'ALL-TIME',
        LeaderboardTab.dailyChallenge => 'CHALLENGE',
      };
}

class LeaderboardRow extends Equatable {
  const LeaderboardRow({
    required this.rank,
    required this.userId,
    required this.username,
    required this.score,
    required this.isPlayer,
  });

  final int rank;
  final String userId;
  final String username;
  final int score;
  final bool isPlayer;

  @override
  List<Object?> get props => [rank, userId, username, score, isPlayer];
}

class LeaderboardBoard extends Equatable {
  const LeaderboardBoard({
    required this.tab,
    required this.rows,
    required this.playerRank,
    required this.playerScore,
    required this.lastSynced,
  });

  final LeaderboardTab tab;
  final List<LeaderboardRow> rows;

  /// The requesting player's rank, even when outside the cached top-N.
  final int? playerRank;
  final int? playerScore;

  /// When the cache was last refreshed from the server (null = never).
  final DateTime? lastSynced;

  bool get isEmpty => rows.isEmpty;

  /// The player isn't among the visible rows but has a rank — pin them.
  bool get shouldPinPlayer =>
      playerRank != null && !rows.any((r) => r.isPlayer);

  @override
  List<Object?> get props => [tab, rows, playerRank, playerScore, lastSynced];
}
