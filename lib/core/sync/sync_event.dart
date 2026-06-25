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

  /// A tournament run's score — best-of-window on the player's entry.
  tournamentScore,

  /// The player's full cosmetics aggregate (owned ids + equipped per slot),
  /// last-writer-wins by its own timestamp. Visual-only, client-authoritative.
  cosmeticState,

  /// The player's full Gunsmith meta-upgrade aggregate (perk id -> owned
  /// level), last-writer-wins by its own timestamp. Mirrors [cosmeticState] —
  /// the coin SPEND syncs as a coinTxn, this carries the perk OWNERSHIP so a
  /// paid perk survives reinstall.
  metaState,
}
