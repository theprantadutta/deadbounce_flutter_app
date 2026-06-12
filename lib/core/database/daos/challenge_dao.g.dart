// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_dao.dart';

// ignore_for_file: type=lint
mixin _$ChallengeDaoMixin on DatabaseAccessor<AppDatabase> {
  $ChallengeAttemptsTable get challengeAttempts =>
      attachedDatabase.challengeAttempts;
  ChallengeDaoManager get managers => ChallengeDaoManager(this);
}

class ChallengeDaoManager {
  final _$ChallengeDaoMixin _db;
  ChallengeDaoManager(this._db);
  $$ChallengeAttemptsTableTableManager get challengeAttempts =>
      $$ChallengeAttemptsTableTableManager(
        _db.attachedDatabase,
        _db.challengeAttempts,
      );
}
