import '../entities/run_result.dart';

abstract interface class RunsRepository {
  /// THE run-end write: in one Drift transaction persists the run row,
  /// the coin ledger transaction for run earnings, lifetime stat deltas
  /// and counters, the challenge attempt (when applicable), and enqueues
  /// all sync outbox events (runCompleted, coinTxn, statsDelta,
  /// scoreSubmit, challengeResult). Gameplay never blocks on network.
  Future<void> recordCompletedRun(RunResult result);

  Future<List<RunResult>> recentRuns({int limit});

  Future<RunResult?> bestRun();
}
