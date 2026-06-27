import 'package:deadbounce_flutter_app/core/database/app_database.dart';
import 'package:deadbounce_flutter_app/core/network/api_client.dart';
import 'package:deadbounce_flutter_app/core/storage/token_storage.dart';
import 'package:deadbounce_flutter_app/features/leaderboards/data/datasources/leaderboard_api.dart';
import 'package:deadbounce_flutter_app/features/leaderboards/data/repositories/leaderboard_repository_impl.dart';
import 'package:deadbounce_flutter_app/features/leaderboards/domain/entities/leaderboard_board.dart';
import 'package:deadbounce_flutter_app/features/leaderboards/domain/leaderboard_period.dart';
import 'package:drift/native.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

/// A LeaderboardApi that returns a fixed board without touching the network.
class _FakeApi extends LeaderboardApi {
  _FakeApi() : super(ApiClient(_NoTokenStorage()));
  @override
  Future<LeaderboardDto> fetch(LeaderboardTab tab, {int limit = 100}) async =>
      const LeaderboardDto(
        rows: [
          LeaderboardRowDto(rank: 1, userId: 'u1', username: 'Ace', score: 500),
        ],
        playerRank: 1,
        playerScore: 500,
      );
}

class _NoTokenStorage extends TokenStorage {
  @override
  Future<String?> readAccessToken() async => null;
}

void main() {
  setUpAll(() {
    dotenv.loadFromString(envString: 'API_BASE_URL_DEV=http://localhost');
  });

  group('leaderboardPeriodKey (mirrors the backend LeaderboardPeriod)', () {
    test('daily is yyyy-MM-dd (UTC)', () {
      expect(
        leaderboardPeriodKey(LeaderboardTab.daily, DateTime.utc(2026, 6, 27, 23)),
        '2026-06-27',
      );
    });

    test('all-time is the constant "alltime"', () {
      expect(
        leaderboardPeriodKey(LeaderboardTab.allTime, DateTime.utc(2026, 6, 27)),
        'alltime',
      );
    });

    test('daily-challenge is dc:yyyy-MM-dd (UTC)', () {
      expect(
        leaderboardPeriodKey(
            LeaderboardTab.dailyChallenge, DateTime.utc(2026, 6, 27)),
        'dc:2026-06-27',
      );
    });

    test('weekly is ISO yyyy-Www (the week\'s Thursday owns the year)', () {
      // 2026-01-01 is a Thursday → ISO week 1 of 2026.
      expect(leaderboardPeriodKey(LeaderboardTab.weekly, DateTime.utc(2026, 1, 1)),
          '2026-W01');
      // 2026-01-05 (Mon) starts ISO week 2.
      expect(leaderboardPeriodKey(LeaderboardTab.weekly, DateTime.utc(2026, 1, 5)),
          '2026-W02');
      // Year boundary: 2025-12-29 (Mon) belongs to 2026-W01 (Thursday = 2026-01-01).
      expect(
          leaderboardPeriodKey(LeaderboardTab.weekly, DateTime.utc(2025, 12, 29)),
          '2026-W01');
      // 2025-12-28 (Sun) is still 2025-W52.
      expect(
          leaderboardPeriodKey(LeaderboardTab.weekly, DateTime.utc(2025, 12, 28)),
          '2025-W52');
    });
  });

  group('LeaderboardRepositoryImpl period-aware cache', () {
    late AppDatabase db;
    late LeaderboardRepositoryImpl repo;
    DateTime now = DateTime.utc(2026, 6, 27, 12);

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = LeaderboardRepositoryImpl(db: db, api: _FakeApi(), clock: () => now);
    });
    tearDown(() => db.close());

    test('refresh caches the current period and getCached returns it', () async {
      await repo.refresh(LeaderboardTab.daily);
      final cached = await repo.getCached(LeaderboardTab.daily);
      expect(cached, isNotNull);
      expect(cached!.rows.single.username, 'Ace');
    });

    test('getCached returns null once the period rolls over', () async {
      await repo.refresh(LeaderboardTab.daily);
      now = DateTime.utc(2026, 6, 28, 12); // next UTC day → stale period
      expect(await repo.getCached(LeaderboardTab.daily), isNull);
    });
  });
}
