import '../../../../core/network/api_client.dart';
import '../../domain/entities/leaderboard_board.dart';

/// Decoded server response for one board.
class LeaderboardDto {
  const LeaderboardDto({
    required this.rows,
    required this.playerRank,
    required this.playerScore,
  });

  final List<LeaderboardRowDto> rows;
  final int? playerRank;
  final int? playerScore;
}

class LeaderboardRowDto {
  const LeaderboardRowDto({
    required this.rank,
    required this.userId,
    required this.username,
    required this.score,
  });

  final int rank;
  final String userId;
  final String username;
  final int score;
}

class LeaderboardApi {
  LeaderboardApi(this._apiClient);

  final ApiClient _apiClient;

  Future<LeaderboardDto> fetch(LeaderboardTab tab, {int limit = 100}) async {
    final json =
        await _apiClient.get('/leaderboards/${tab.apiPath}?limit=$limit');

    final rows = (json['rows'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map((r) => LeaderboardRowDto(
              rank: r['rank'] as int? ?? 0,
              userId: r['user_id'] as String? ?? '',
              username: (r['username'] ??
                      r['display_name'] ??
                      'Gunslinger') as String,
              score: r['score'] as int? ?? 0,
            ))
        .toList();

    final player = json['player'] as Map<String, dynamic>?;

    return LeaderboardDto(
      rows: rows,
      playerRank: player?['rank'] as int?,
      playerScore: player?['score'] as int?,
    );
  }
}
