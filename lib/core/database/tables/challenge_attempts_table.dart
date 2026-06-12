import 'package:drift/drift.dart';

/// Daily-challenge attempts. challengeDate is the UTC date (yyyy-MM-dd) —
/// the challenge itself is global and seed-derived from that date.
@DataClassName('ChallengeAttemptRow')
class ChallengeAttempts extends Table {
  TextColumn get id => text()();
  TextColumn get challengeDate => text()();
  IntColumn get seed => integer()();
  IntColumn get score => integer()();
  TextColumn get runId => text().nullable()();
  IntColumn get completedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
