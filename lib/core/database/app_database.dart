import 'package:drift/drift.dart';

import 'daos/achievements_dao.dart';
import 'daos/challenge_dao.dart';
import 'daos/coin_ledger_dao.dart';
import 'daos/cosmetics_dao.dart';
import 'daos/leaderboard_cache_dao.dart';
import 'daos/meta_upgrades_dao.dart';
import 'daos/profile_dao.dart';
import 'daos/runs_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/stats_dao.dart';
import 'daos/streak_dao.dart';
import 'daos/sync_outbox_dao.dart';
import 'daos/tournament_dao.dart';
import 'tables/achievement_states_table.dart';
import 'tables/challenge_attempts_table.dart';
import 'tables/coin_balance_table.dart';
import 'tables/coin_ledger_table.dart';
import 'tables/cosmetics_table.dart';
import 'tables/daily_login_claims_table.dart';
import 'tables/leaderboard_cache_table.dart';
import 'tables/meta_upgrades_table.dart';
import 'tables/player_profile_table.dart';
import 'tables/player_stats_table.dart';
import 'tables/runs_table.dart';
import 'tables/settings_table.dart';
import 'tables/stat_counters_table.dart';
import 'tables/sync_outbox_table.dart';
import 'tables/tournament_table.dart';

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
    MetaUpgrades,
    Tournaments,
    TournamentLeaderboardCache,
    CosmeticOwned,
    CosmeticEquipped,
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
    MetaUpgradesDao,
    TournamentDao,
    CosmeticsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 4;

  /// Wipes all gameplay/account data on this device in one transaction,
  /// **preserving the settings table** (device preferences). Clearing the
  /// profile row resets `initialSyncCompleted`, so the next session re-pulls
  /// the server snapshot. Used by Settings → "Clear local data".
  Future<void> clearGameData() => transaction(() async {
        await delete(playerProfiles).go();
        await delete(playerStatsTable).go();
        await delete(statCounters).go();
        await delete(coinLedgerEntries).go();
        await delete(coinBalances).go();
        await delete(runs).go();
        await delete(achievementStates).go();
        await delete(dailyLoginClaims).go();
        await delete(challengeAttempts).go();
        await delete(leaderboardCacheEntries).go();
        await delete(leaderboardSyncMeta).go();
        await delete(syncOutbox).go();
        await delete(metaUpgrades).go();
        await delete(tournaments).go();
        await delete(tournamentLeaderboardCache).go();
        await delete(cosmeticOwned).go();
        await delete(cosmeticEquipped).go();
      });

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createIndexes();
        },
        // Stepwise migrations from v2 on.
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(metaUpgrades);
          }
          if (from < 3) {
            await m.createTable(tournaments);
            await m.createTable(tournamentLeaderboardCache);
            await m.addColumn(runs, runs.tournamentId);
          }
          if (from < 4) {
            await m.createTable(cosmeticOwned);
            await m.createTable(cosmeticEquipped);
          }
          // Indexes are added with IF NOT EXISTS, so this is safe on every
          // upgrade path — and crucially repairs installs created before the
          // indexes existed (onCreate-only would leave upgraders unindexed).
          await _createIndexes();
        },
      );

  /// The performance indexes, idempotent (IF NOT EXISTS) so both onCreate and
  /// every onUpgrade can call it.
  Future<void> _createIndexes() async {
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
  }
}
