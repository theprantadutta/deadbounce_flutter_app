/// Player-chosen "feel"/accessibility options for a single run, resolved from
/// `AppSettings` and handed to [DeadbounceGame] (like the meta loadout). Kept
/// out of `GameBalance` so user preferences never mutate the tuning singleton.
/// Defaults reproduce the shipped behavior (everything on, medium particles).
class GameFeel {
  const GameFeel({
    this.screenShake = true,
    this.hitStop = true,
    this.aimGuide = true,
    this.combatText = true,
    this.particleBudget = 600,
  });

  /// Camera trauma shake on kills / chains / Warden hits.
  final bool screenShake;

  /// Time-freeze on multi-kills and Warden phase breaks.
  final bool hitStop;

  /// The predicted ricochet preview line while aiming.
  final bool aimGuide;

  /// Floating bounce counters and chain labels.
  final bool combatText;

  /// Max simultaneous particles the factory will spawn.
  final int particleBudget;
}
