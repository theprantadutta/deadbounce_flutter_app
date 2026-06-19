import '../../../../core/network/api_client.dart';

/// Decoded server tournament (snake_case wire keys, matching the backend's
/// JSON naming). Mirrors the .NET TournamentDto.
class TournamentDto {
  const TournamentDto({
    required this.id,
    required this.cadence,
    required this.state,
    required this.name,
    required this.tagline,
    required this.startsAt,
    required this.endsAt,
    required this.seed,
    required this.configJson,
    required this.entryFeeCoins,
    required this.rewardTableJson,
    required this.joined,
    required this.paid,
    required this.bestScore,
    required this.rank,
    required this.rewardCoins,
    required this.rewardClaimed,
  });

  factory TournamentDto.fromJson(Map<String, dynamic> j) => TournamentDto(
        id: j['id'] as String,
        cadence: j['cadence'] as String? ?? 'Daily',
        state: j['state'] as String? ?? 'Active',
        name: j['name'] as String? ?? 'Tournament',
        tagline: j['tagline'] as String? ?? '',
        startsAt: DateTime.parse(j['starts_at'] as String).toUtc(),
        endsAt: DateTime.parse(j['ends_at'] as String).toUtc(),
        seed: (j['seed'] as num?)?.toInt() ?? 0,
        configJson: j['config_json'] as String? ?? '{}',
        entryFeeCoins: (j['entry_fee_coins'] as num?)?.toInt() ?? 0,
        rewardTableJson: j['reward_table_json'] as String? ?? '{}',
        joined: j['joined'] as bool? ?? false,
        paid: j['paid'] as bool? ?? false,
        bestScore: (j['best_score'] as num?)?.toInt() ?? 0,
        rank: (j['rank'] as num?)?.toInt(),
        rewardCoins: (j['reward_coins'] as num?)?.toInt(),
        rewardClaimed: j['reward_claimed'] as bool? ?? false,
      );

  final String id;
  final String cadence;
  final String state;
  final String name;
  final String tagline;
  final DateTime startsAt;
  final DateTime endsAt;
  final int seed;
  final String configJson;
  final int entryFeeCoins;
  final String rewardTableJson;
  final bool joined;
  final bool paid;
  final int bestScore;
  final int? rank;
  final int? rewardCoins;
  final bool rewardClaimed;
}

class TournamentBoardRowDto {
  const TournamentBoardRowDto({
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

class TournamentBoardDto {
  const TournamentBoardDto({
    required this.rows,
    required this.playerRank,
    required this.playerScore,
  });

  final List<TournamentBoardRowDto> rows;
  final int? playerRank;
  final int? playerScore;
}

class TournamentApi {
  TournamentApi(this._apiClient);

  final ApiClient _apiClient;

  Future<List<TournamentDto>> list() async {
    final json = await _apiClient.get('/tournaments');
    return (json['tournaments'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(TournamentDto.fromJson)
        .toList();
  }

  Future<TournamentDto> join(String id) async {
    final json = await _apiClient.post('/tournaments/$id/join');
    return TournamentDto.fromJson(json);
  }

  Future<TournamentBoardDto> leaderboard(String id, {int limit = 100}) async {
    final json = await _apiClient.get('/tournaments/$id/leaderboard?limit=$limit');
    final rows = (json['rows'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map((r) => TournamentBoardRowDto(
              rank: r['rank'] as int? ?? 0,
              userId: r['user_id'] as String? ?? '',
              username:
                  (r['username'] ?? r['display_name'] ?? 'Gunslinger') as String,
              score: r['score'] as int? ?? 0,
            ))
        .toList();
    final player = json['player'] as Map<String, dynamic>?;
    return TournamentBoardDto(
      rows: rows,
      playerRank: player?['rank'] as int?,
      playerScore: player?['score'] as int?,
    );
  }
}
