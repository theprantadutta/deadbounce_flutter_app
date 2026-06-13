import '../../features/challenges/data/repositories/daily_challenge_repository_impl.dart';
import '../../features/challenges/domain/repositories/daily_challenge_repository.dart';
import '../../features/economy/data/repositories/wallet_repository_impl.dart';
import '../../features/economy/domain/repositories/wallet_repository.dart';
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

    return SessionDependencies._(
      db: db,
      outboxWriter: outboxWriter,
      syncApi: syncApi,
      syncStatus: syncStatus,
      syncTriggers: syncTriggers,
      syncWorker: syncWorker,
      snapshotRestorer: SnapshotRestorer(db: db, api: syncApi),
      runsRepository: RunsRepositoryImpl(db: db, outboxWriter: outboxWriter),
      walletRepository:
          WalletRepositoryImpl(db: db, outboxWriter: outboxWriter),
      loginStreakRepository:
          LoginStreakRepositoryImpl(db: db, outboxWriter: outboxWriter),
      dailyChallengeRepository: DailyChallengeRepositoryImpl(db: db),
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

  bool _started = false;

  /// One-time restore (when needed) + start the sync engine. Safe to call
  /// once per session; the boot flow owns the call.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      await snapshotRestorer.restoreIfNeeded();
    } on ApiException {
      // Offline at boot on an already-hydrated device is fine; a FRESH
      // device needs the network once — surfaced by the boot screen,
      // retried on next launch.
    }
    syncTriggers.start();
    await syncWorker.start();
  }

  Future<void> dispose() async {
    await syncWorker.dispose();
    await syncTriggers.dispose();
    syncStatus.dispose();
    await db.close();
  }
}
