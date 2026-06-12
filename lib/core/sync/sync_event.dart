/// Every syncable mutation type the outbox can carry. Wire names are the
/// enum names verbatim; payload JSON keys are snake_case to match the
/// backend's serialization.
enum SyncEntityType {
  runCompleted,
  coinTxn,
  achievementUnlock,
  challengeResult,
  statsDelta,

  /// Leaderboard submission — separate from [runCompleted] so a score
  /// rejected by server sanity validation never blocks run-history
  /// ingestion.
  scoreSubmit,
  streakUpdate,
  accountLinked,
}
