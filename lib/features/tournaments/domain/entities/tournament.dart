import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../../game/engine/challenge/challenge_config.dart';
import '../../../game/engine/waves/wave_definition.dart';

enum TournamentCadence {
  daily,
  weekly,
  monthly;

  static TournamentCadence fromName(String? name) =>
      TournamentCadence.values.firstWhere(
        (c) => c.name == name?.toLowerCase(),
        orElse: () => TournamentCadence.daily,
      );

  String get label => switch (this) {
        TournamentCadence.daily => 'DAILY',
        TournamentCadence.weekly => 'WEEKLY',
        TournamentCadence.monthly => 'MONTHLY',
      };
}

enum TournamentState {
  active,
  ended,
  upcoming;

  static TournamentState fromName(String? name) =>
      TournamentState.values.firstWhere(
        (s) => s.name == name?.toLowerCase(),
        orElse: () => TournamentState.active,
      );
}

/// A tournament + this player's entry state. The ruleset travels as
/// [configJson] (server-authoritative) and maps to the engine's
/// [ChallengeConfig] via [toChallengeConfig], so a tournament run reuses the
/// daily-challenge run path with a shared [seed] (fair board).
class Tournament extends Equatable {
  const Tournament({
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

  final String id;
  final TournamentCadence cadence;
  final TournamentState state;
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

  bool get isActive => state == TournamentState.active;
  bool get isEnded => state == TournamentState.ended;
  bool get hasUnclaimedReward =>
      isEnded && (rewardCoins ?? 0) > 0 && !rewardClaimed;

  /// The top (rank 1) payout, for a "win up to N" hint in the UI.
  int get topReward {
    final table = _decodeRewardTable();
    return table['1'] ?? (table.isEmpty ? 0 : table.values.reduce((a, b) => a > b ? a : b));
  }

  /// Maps the server ruleset onto the engine's run config.
  ChallengeConfig toChallengeConfig() {
    final Map<String, dynamic> m;
    try {
      m = jsonDecode(configJson) as Map<String, dynamic>;
    } catch (_) {
      return const ChallengeConfig();
    }
    return ChallengeConfig(
      forcedEnemyType: _enemyType(m['forced_enemy_type'] as String?),
      extraWallDamage: (m['extra_wall_damage'] as num?)?.toInt() ?? 0,
      startingHearts: (m['starting_hearts'] as num?)?.toInt(),
      scoreMultiplier: (m['score_multiplier'] as num?)?.toDouble() ?? 1,
      randomUpgrades: m['random_upgrades'] as bool? ?? false,
    );
  }

  Map<String, int> _decodeRewardTable() {
    try {
      final m = jsonDecode(rewardTableJson) as Map<String, dynamic>;
      return m.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return const {};
    }
  }

  static EnemyType? _enemyType(String? name) {
    if (name == null) return null;
    for (final e in EnemyType.values) {
      if (e.name == name) return e;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        cadence,
        state,
        name,
        tagline,
        startsAt,
        endsAt,
        seed,
        configJson,
        entryFeeCoins,
        rewardTableJson,
        joined,
        paid,
        bestScore,
        rank,
        rewardCoins,
        rewardClaimed,
      ];
}

/// One row of a tournament leaderboard.
class TournamentStanding extends Equatable {
  const TournamentStanding({
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

/// A tournament board with the player's pinned rank.
class TournamentBoard extends Equatable {
  const TournamentBoard({
    required this.standings,
    required this.playerRank,
    required this.playerScore,
  });

  final List<TournamentStanding> standings;
  final int? playerRank;
  final int? playerScore;

  bool get shouldPinPlayer =>
      playerRank != null && !standings.any((s) => s.isPlayer);

  @override
  List<Object?> get props => [standings, playerRank, playerScore];
}
