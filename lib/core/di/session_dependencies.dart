import 'dart:async';

import '../../features/achievements/data/repositories/achievements_repository_impl.dart';
import '../../features/achievements/domain/repositories/achievements_repository.dart';
import '../../features/challenges/data/repositories/daily_challenge_repository_impl.dart';
import '../../features/challenges/domain/repositories/daily_challenge_repository.dart';
import '../../features/cosmetics/data/repositories/cosmetics_repository_impl.dart';
import '../../features/cosmetics/domain/repositories/cosmetics_repository.dart';
import '../../features/game/presentation/trickshot/trickshot_progress_repository.dart';
import '../../features/economy/data/repositories/wallet_repository_impl.dart';
import '../../features/economy/domain/repositories/wallet_repository.dart';
import '../../features/leaderboards/data/datasources/leaderboard_api.dart';
import '../../features/leaderboards/data/repositories/leaderboard_repository_impl.dart';
import '../../features/leaderboards/domain/repositories/leaderboard_repository.dart';
import '../../features/meta/data/repositories/meta_repository_impl.dart';
import '../../features/meta/domain/repositories/meta_repository.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/statistics/data/repositories/statistics_repository_impl.dart';
import '../../features/statistics/domain/repositories/statistics_repository.dart';
import '../../features/tournaments/data/datasources/tournament_api.dart';
import '../../features/tournaments/data/repositories/tournament_repository_impl.dart';
import '../../features/tournaments/domain/repositories/tournament_repository.dart';
import '../../features/runs/data/repositories/runs_repository_impl.dart';
import '../../features/runs/domain/repositories/runs_repository.dart';
import '../../features/streak/data/repositories/login_streak_repository_impl.dart';
import '../../features/streak/domain/repositories/login_streak_repository.dart';
import '../database/app_database.dart';
import '../database/connection/database_factory.dart';
import '../network/api_client.dart';
import '../sync/snapshot_restorer.dart';
import '../sync/sync_api.dart';
import '../sync/sync_outbox_writer.dart';
import '../sync/sync_status.dart';
import '../sync/sync_trigger_source.dart';
import '../sync/sync_worker.dart';

/// Everything that exists only while an account is signed in: the
/// per-account Drift database, the sync engine, and the game-data
/// repositories. Built when auth resolves a Firebase uid, torn down on
/// sign-out (different account → different database file).
class SessionDependencies {
  SessionDependencies._({
    required this.db,
    required this.outboxWriter,
    required this.syncApi,
    required this.syncStatus,
    required this.syncTriggers,
    required this.syncWorker,
    required this.snapshotRestorer,
    required this.runsRepository,
    required this.walletRepository,
    required this.loginStreakRepository,
    required this.dailyChallengeRepository,
    required this.achievementsRepository,
    required this.leaderboardRepository,
    required this.profileRepository,
    required this.settingsRepository,
    required this.statisticsRepository,
    required this.metaRepository,
    required this.tournamentRepository,
    required this.cosmeticsRepository,
    required this.trickShotProgressRepository,
  });

  factory SessionDependencies.create({
    required String firebaseUid,
    required ApiClient apiClient,
  }) {
    final db = openAccountDatabase(firebaseUid);
    final outboxWriter = SyncOutboxWriter(db);
    final syncApi = SyncApi(apiClient);
    final syncStatus = SyncStatusNotifier();
    final syncTriggers = SyncTriggerSource();
    final syncWorker = SyncWorker(
      db: db,
      api: syncApi,
      status: syncStatus,
      triggers: syncTriggers,
    );
    final loginStreakRepository = LoginStreakRepositoryImpl(
      db: db,
      outboxWriter: outboxWriter,
    );

    return SessionDependencies._(
      db: db,
      outboxWriter: outboxWriter,
      syncApi: syncApi,
      syncStatus: syncStatus,
      syncTriggers: syncTriggers,
      syncWorker: syncWorker,
      snapshotRestorer: SnapshotRestorer(db: db, api: syncApi),
      runsRepository: RunsRepositoryImpl(db: db, outboxWriter: outboxWriter),
      walletRepository: WalletRepositoryImpl(
        db: db,
        outboxWriter: outboxWriter,
      ),
      loginStreakRepository: loginStreakRepository,
      dailyChallengeRepository: DailyChallengeRepositoryImpl(db: db),
      achievementsRepository: AchievementsRepositoryImpl(
        db: db,
        outboxWriter: outboxWriter,
        streakRepository: loginStreakRepository,
      ),
      leaderboardRepository: LeaderboardRepositoryImpl(
        db: db,
        api: LeaderboardApi(apiClient),
      ),
      profileRepository: ProfileRepositoryImpl(db),
      settingsRepository: SettingsRepositoryImpl(db),
      statisticsRepository: StatisticsRepositoryImpl(db),
      metaRepository: MetaRepositoryImpl(db: db, outboxWriter: outboxWriter),
      tournamentRepository: TournamentRepositoryImpl(
        db: db,
        api: TournamentApi(apiClient),
        outboxWriter: outboxWriter,
      ),
      cosmeticsRepository: CosmeticsRepositoryImpl(
        db: db,
        outboxWriter: outboxWriter,
      ),
      trickShotProgressRepository: TrickShotProgressRepository(db),
    );
  }

  final AppDatabase db;
  final SyncOutboxWriter outboxWriter;
  final SyncApi syncApi;
  final SyncStatusNotifier syncStatus;
  final SyncTriggerSource syncTriggers;
  final SyncWorker syncWorker;
  final SnapshotRestorer snapshotRestorer;
  final RunsRepository runsRepository;
  final WalletRepository walletRepository;
  final LoginStreakRepository loginStreakRepository;
  final DailyChallengeRepository dailyChallengeRepository;
  final AchievementsRepository achievementsRepository;
  final LeaderboardRepository leaderboardRepository;
  final ProfileRepository profileRepository;
  final SettingsRepository settingsRepository;
  final StatisticsRepository statisticsRepository;
  final MetaRepository metaRepository;
  final TournamentRepository tournamentRepository;
  final CosmeticsRepository cosmeticsRepository;
  final TrickShotProgressRepository trickShotProgressRepository;

  bool _started = false;
  bool _disposed = false;
  final Completer<void> _ready = Completer<void>();

  /// Completes once [start] has finished (snapshot restore + sync spin-up).
  /// The boot screen awaits this before routing into the authenticated app
  /// so screens never read a half-hydrated database.
  Future<void> get ready => _ready.future;

  /// One-time restore (when needed) + start the sync engine. Safe to call
  /// once per session; the boot flow owns the call.
  Future<void> start() async {
    if (_started || _disposed) return;
    _started = true;
    try {
      if (_disposed) return; // torn down before the restore began
      await snapshotRestorer.restoreIfNeeded();
    } on ApiException {
      // Offline at boot on an already-hydrated device is fine; a FRESH
      // device needs the network once — surfaced by the boot screen,
      // retried on next launch.
    } finally {
      // A sign-out mid-restore may have disposed us; don't spin the engine up
      // against a closing DB.
      if (!_disposed) {
        syncTriggers.start();
        // Don't block readiness on the first drain — fire and forget.
        unawaited(syncWorker.start());
      }
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  /// Settings → "Clear local data": wipe this device's gameplay/account data
  /// (device prefs kept) and re-pull the server snapshot in place, WITHOUT
  /// signing out (so anonymous accounts aren't orphaned). Offline, the re-pull
  /// is skipped and the sync engine retries it later.
  Future<void> clearLocalData() async {
    await db.clearGameData();
    try {
      await snapshotRestorer.restoreIfNeeded();
    } on ApiException {
      // Offline: profile row is gone so `initialSyncCompleted` is false again;
      // the next session start re-pulls the snapshot.
    }
    syncWorker.requestSync();
  }

  Future<void> dispose() async {
    _disposed = true;
    // syncWorker.dispose() awaits its in-flight drain, so by the time we close
    // the DB no batch is still settling against it.
    await syncWorker.dispose();
    await syncTriggers.dispose();
    syncStatus.dispose();
    await db.close();
  }
}
