import '../entities/challenge_overview.dart';

abstract interface class DailyChallengeRepository {
  /// Today's challenge (seed-derived, identical worldwide) plus the
  /// player's best local attempt.
  Future<ChallengeOverview> getTodaysChallenge();
}
