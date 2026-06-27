import '../../../../core/database/app_database.dart';

/// One trick-shot level's local progress.
class TrickShotProgress {
  const TrickShotProgress({required this.cleared, required this.bestShots});

  final bool cleared;

  /// Fewest shots used to clear, or null if not cleared yet.
  final int? bestShots;
}

/// Local-only (offline-first) persistence for Trick-Shot Gallery progress:
/// per-level cleared flag + best (fewest) shots. Single-player puzzle progress —
/// it lives on-device and is not synced (no leaderboard).
class TrickShotProgressRepository {
  TrickShotProgressRepository(this._db);

  final AppDatabase _db;

  /// levelId → progress, live.
  Stream<Map<String, TrickShotProgress>> watchProgress() =>
      _db.trickShotDao.watchAll().map((rows) => {
            for (final r in rows)
              r.levelId:
                  TrickShotProgress(cleared: r.cleared, bestShots: r.bestShots),
          });

  /// Records a clear, keeping the fewest shots across attempts.
  Future<void> recordClear(String levelId, int shots) => _db.trickShotDao
      .recordClear(levelId, shots, DateTime.now().toUtc().millisecondsSinceEpoch);
}
