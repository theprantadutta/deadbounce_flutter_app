import 'package:drift/drift.dart';

import 'daos/achievements_dao.dart';
import 'daos/challenge_dao.dart';
import 'daos/coin_ledger_dao.dart';
import 'daos/leaderboard_cache_dao.dart';
import 'daos/profile_dao.dart';
import 'daos/runs_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/stats_dao.dart';
import 'daos/streak_dao.dart';
import 'daos/sync_outbox_dao.dart';
import 'tables/achievement_states_table.dart';
import 'tables/challenge_attempts_table.dart';
import 'tables/coin_balance_table.dart';
import 'tables/coin_ledger_table.dart';
import 'tables/daily_login_claims_table.dart';
import 'tables/leaderboard_cache_table.dart';
import 'tables/player_profile_table.dart';
import 'tables/player_stats_table.dart';
import 'tables/runs_table.dart';
import 'tables/settings_table.dart';
import 'tables/stat_counters_table.dart';
import 'tables/sync_outbox_table.dart';

part 'app_database.g.dart';

/// The client source of truth. Every gameplay/meta write lands here first
/// (synchronously with the UI); the backend is updated asynchronously via
/// the sync outbox. One database FILE per signed-in account — see
/// `connection/database_factory.dart`.
@DriftDatabase(
  tables: [
    PlayerProfiles,
    PlayerStatsTable,
    StatCounters,
    CoinLedgerEntries,
    CoinBalances,
    Runs,
    AchievementStates,
    DailyLoginClaims,
    ChallengeAttempts,
    LeaderboardCacheEntries,
    LeaderboardSyncMeta,
    SettingsEntries,
    SyncOutbox,
  ],
  daos: [
    ProfileDao,
    StatsDao,
    CoinLedgerDao,
    RunsDao,
    AchievementsDao,
    StreakDao,
    ChallengeDao,
    LeaderboardCacheDao,
    SettingsDao,
    SyncOutboxDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_sync_outbox_status_created '
            'ON sync_outbox (status, created_at)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_coin_ledger_created '
            'ON coin_ledger (created_at)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_runs_ended_at '
            'ON runs (ended_at DESC)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_challenge_attempts_date_score '
            'ON challenge_attempts (challenge_date, score DESC)',
          );
        },
        // schemaVersion 1 — add stepwise migrations here from v2 on.
        onUpgrade: (m, from, to) async {},
      );
}
