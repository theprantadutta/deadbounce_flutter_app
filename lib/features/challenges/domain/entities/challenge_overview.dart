import 'package:equatable/equatable.dart';

import '../../../game/engine/challenge/challenge_catalog.dart';

/// Today's challenge plus the player's local best attempt.
class ChallengeOverview extends Equatable {
  const ChallengeOverview({
    required this.definition,
    required this.bestScore,
    required this.attemptCount,
  });

  final DailyChallengeDefinition definition;

  /// Null when the player hasn't attempted today's challenge yet.
  final int? bestScore;
  final int attemptCount;

  @override
  List<Object?> get props => [definition.utcDate, bestScore, attemptCount];
}
