import '../../engine/challenge/challenge_config.dart';

/// What a tournament run needs from the joined tournament: its id (for score
/// submission), the shared [seed] (fair board), and the [config] ruleset
/// (mapped from the server). Built from the cached tournament so it plays
/// offline.
class TournamentRunContext {
  const TournamentRunContext({
    required this.tournamentId,
    required this.seed,
    required this.config,
  });

  final String tournamentId;
  final int seed;
  final ChallengeConfig config;
}
