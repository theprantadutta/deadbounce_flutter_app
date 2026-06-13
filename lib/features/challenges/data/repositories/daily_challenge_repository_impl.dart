import '../../../../core/database/app_database.dart';
import '../../../../core/util/calendar_day.dart';
import '../../../game/engine/challenge/challenge_catalog.dart';
import '../../../game/engine/game_rng.dart';
import '../../domain/entities/challenge_overview.dart';
import '../../domain/repositories/daily_challenge_repository.dart';

class DailyChallengeRepositoryImpl implements DailyChallengeRepository {
  DailyChallengeRepositoryImpl({
    required this._db,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _now;

  @override
  Future<ChallengeOverview> getTodaysChallenge() async {
    final utcDate = CalendarDay.utc(_now());
    final seed = GameRng.dailySeed(_now().toUtc());
    final definition = ChallengeCatalog.forUtcDate(utcDate, seed);

    final best = await _db.challengeDao.bestAttemptFor(utcDate);
    final attempts = await _db.challengeDao.attemptsFor(utcDate);

    return ChallengeOverview(
      definition: definition,
      bestScore: best?.score,
      attemptCount: attempts.length,
    );
  }
}
