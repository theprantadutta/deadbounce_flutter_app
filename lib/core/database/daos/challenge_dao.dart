import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/challenge_attempts_table.dart';

part 'challenge_dao.g.dart';

@DriftAccessor(tables: [ChallengeAttempts])
class ChallengeDao extends DatabaseAccessor<AppDatabase>
    with _$ChallengeDaoMixin {
  ChallengeDao(super.db);

  Future<void> insertAttempt(ChallengeAttemptRow row) =>
      into(challengeAttempts).insert(row);

  Future<ChallengeAttemptRow?> bestAttemptFor(String utcDate) =>
      (select(challengeAttempts)
            ..where((a) => a.challengeDate.equals(utcDate))
            ..orderBy([(a) => OrderingTerm.desc(a.score)])
            ..limit(1))
          .getSingleOrNull();

  Future<List<ChallengeAttemptRow>> attemptsFor(String utcDate) =>
      (select(challengeAttempts)
            ..where((a) => a.challengeDate.equals(utcDate))
            ..orderBy([(a) => OrderingTerm.desc(a.score)]))
          .get();
}
