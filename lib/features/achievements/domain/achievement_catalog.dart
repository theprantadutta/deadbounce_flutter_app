/// Everything an achievement evaluator needs: the just-finished run plus
/// the player's lifetime aggregates. Achievements are evaluated locally
/// and offline; only claims (with their coin reward) sync to the backend,
/// which validates the id + reward against its mirror of this catalog.
class AchievementContext {
  const AchievementContext({
    required this.runScore,
    required this.runWave,
    required this.runBestChain,
    required this.runMaxBounceKill,
    required this.runUpgradesPicked,
    required this.runHitsTaken,
    required this.runIsDailyChallenge,
    required this.lifetimeKills,
    required this.lifetimeCoinsEarned,
    required this.runsPlayed,
    required this.bestScore,
    required this.bestWave,
    required this.bestChain,
    required this.bestBounceKill,
    required this.currentStreak,
    required this.lifetimeEnemyKills,
  });

  final int runScore;
  final int runWave;
  final int runBestChain;
  final int runMaxBounceKill;
  final int runUpgradesPicked;
  final int runHitsTaken;
  final bool runIsDailyChallenge;

  final int lifetimeKills;
  final int lifetimeCoinsEarned;
  final int runsPlayed;
  final int bestScore;
  final int bestWave;
  final int bestChain;
  final int bestBounceKill;
  final int currentStreak;
  final Map<String, int> lifetimeEnemyKills;

  int enemyKills(String id) => lifetimeEnemyKills[id] ?? 0;
}

/// A single achievement. [progress] returns the player's current progress
/// toward [target]; unlocked when progress >= target. [coinReward] MUST
/// match the backend's AchievementDefinitions entry.
class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.name,
    required this.flavor,
    required this.iconName,
    required this.coinReward,
    required this.target,
    required this.progress,
    this.secret = false,
  });

  final String id;
  final String name;
  final String flavor;
  final String iconName;
  final int coinReward;
  final int target;
  final bool secret;
  final int Function(AchievementContext) progress;
}

abstract final class AchievementCatalog {
  static int _flag(bool met) => met ? 1 : 0;

  static final List<AchievementDefinition> all = [
    AchievementDefinition(
      id: 'first_blood',
      name: 'FIRST BLOOD',
      flavor: 'Every legend starts with one.',
      iconName: 'water_drop',
      coinReward: 10,
      target: 1,
      progress: (c) => c.lifetimeKills.clamp(0, 1),
    ),
    AchievementDefinition(
      id: 'first_dance',
      name: 'FIRST DANCE',
      flavor: 'You finished a run. Many more to come.',
      iconName: 'sports_esports',
      coinReward: 15,
      target: 1,
      progress: (c) => c.runsPlayed.clamp(0, 1),
    ),
    AchievementDefinition(
      id: 'bank_shot',
      name: 'BANK SHOT',
      flavor: 'A kill three bounces in the making.',
      iconName: 'sports_tennis',
      coinReward: 25,
      target: 1,
      progress: (c) => _flag(c.bestBounceKill >= 3),
    ),
    AchievementDefinition(
      id: 'turret_down',
      name: 'TURRET DOWN',
      flavor: 'Silenced the wall gun.',
      iconName: 'gpp_bad',
      coinReward: 40,
      target: 1,
      progress: (c) => _flag(c.enemyKills('turret') >= 1),
    ),
    AchievementDefinition(
      id: 'chain_gang',
      name: 'CHAIN GANG',
      flavor: 'Three for the price of one bullet.',
      iconName: 'link',
      coinReward: 50,
      target: 1,
      progress: (c) => _flag(c.bestChain >= 3),
    ),
    AchievementDefinition(
      id: 'splitting_headache',
      name: 'SPLITTING HEADACHE',
      flavor: 'Put down 50 Splitters. They keep coming.',
      iconName: 'call_split',
      coinReward: 50,
      target: 50,
      progress: (c) => c.enemyKills('splitter').clamp(0, 50),
    ),
    AchievementDefinition(
      id: 'pacifist_no_more',
      name: 'PACIFIST NO MORE',
      flavor: 'A hundred notches on the iron.',
      iconName: 'local_fire_department',
      coinReward: 75,
      target: 100,
      progress: (c) => c.lifetimeKills.clamp(0, 100),
    ),
    AchievementDefinition(
      id: 'trick_shot_artist',
      name: 'TRICK SHOT ARTIST',
      flavor: 'Five bounces, one corpse.',
      iconName: 'auto_awesome',
      coinReward: 75,
      target: 1,
      progress: (c) => _flag(c.bestBounceKill >= 5),
    ),
    AchievementDefinition(
      id: 'daily_grind',
      name: 'DAILY GRIND',
      flavor: 'Answered the daily call.',
      iconName: 'event_available',
      coinReward: 80,
      target: 1,
      progress: (c) => _flag(c.runIsDailyChallenge),
    ),
    AchievementDefinition(
      id: 'seasoned_gun',
      name: 'SEASONED GUN',
      flavor: 'Twenty-five runs in the dust.',
      iconName: 'military_tech',
      coinReward: 100,
      target: 25,
      progress: (c) => c.runsPlayed.clamp(0, 25),
    ),
    AchievementDefinition(
      id: 'warden_slayer',
      name: 'WARDEN SLAYER',
      flavor: 'The big one fell to your third bounce.',
      iconName: 'shield_moon',
      coinReward: 100,
      target: 1,
      progress: (c) => _flag(c.enemyKills('warden') >= 1),
    ),
    AchievementDefinition(
      id: 'regular',
      name: 'REGULAR',
      flavor: 'Seven days straight. The arena knows your name.',
      iconName: 'calendar_month',
      coinReward: 100,
      target: 7,
      progress: (c) => c.currentStreak.clamp(0, 7),
    ),
    AchievementDefinition(
      id: 'full_house',
      name: 'FULL HOUSE',
      flavor: 'Five upgrades stacked in one run.',
      iconName: 'style',
      coinReward: 125,
      target: 1,
      progress: (c) => _flag(c.runUpgradesPicked >= 5),
    ),
    AchievementDefinition(
      id: 'untouchable',
      name: 'UNTOUCHABLE',
      flavor: 'Five waves, not a scratch.',
      iconName: 'verified_user',
      coinReward: 125,
      target: 1,
      progress: (c) => _flag(c.runWave >= 6 && c.runHitsTaken == 0),
    ),
    AchievementDefinition(
      id: 'quad_rustler',
      name: 'QUAD RUSTLER',
      flavor: 'Four in a single ricochet.',
      iconName: 'workspaces',
      coinReward: 150,
      target: 1,
      progress: (c) => _flag(c.bestChain >= 4),
    ),
    AchievementDefinition(
      id: 'collector',
      name: 'COLLECTOR',
      flavor: 'Ten thousand coins richer.',
      iconName: 'savings',
      coinReward: 150,
      target: 10000,
      progress: (c) => c.lifetimeCoinsEarned.clamp(0, 10000),
    ),
    AchievementDefinition(
      id: 'marathon',
      name: 'MARATHON',
      flavor: 'You reached wave twenty.',
      iconName: 'directions_run',
      coinReward: 200,
      target: 20,
      progress: (c) => c.bestWave.clamp(0, 20),
    ),
    AchievementDefinition(
      id: 'sharpshooter',
      name: 'SHARPSHOOTER',
      flavor: 'Twenty-five thousand in one run.',
      iconName: 'center_focus_strong',
      coinReward: 200,
      target: 1,
      progress: (c) => _flag(c.bestScore >= 25000),
    ),
    AchievementDefinition(
      id: 'century',
      name: 'CENTURY',
      flavor: 'One hundred runs. A true regular.',
      iconName: 'looks_one',
      coinReward: 250,
      target: 100,
      progress: (c) => c.runsPlayed.clamp(0, 100),
    ),
    AchievementDefinition(
      id: 'warden_collector',
      name: 'WARDEN COLLECTOR',
      flavor: 'Ten Wardens, ten graves.',
      iconName: 'shield',
      coinReward: 300,
      target: 10,
      secret: true,
      progress: (c) => c.enemyKills('warden').clamp(0, 10),
    ),
    AchievementDefinition(
      id: 'dedicated',
      name: 'DEDICATED',
      flavor: 'A month without missing a draw.',
      iconName: 'whatshot',
      coinReward: 300,
      target: 30,
      secret: true,
      progress: (c) => c.currentStreak.clamp(0, 30),
    ),
    AchievementDefinition(
      id: 'high_roller',
      name: 'HIGH ROLLER',
      flavor: 'Fifty thousand coins earned.',
      iconName: 'paid',
      coinReward: 350,
      target: 50000,
      progress: (c) => c.lifetimeCoinsEarned.clamp(0, 50000),
    ),
    AchievementDefinition(
      id: 'deep_run',
      name: 'DEEP RUN',
      flavor: 'Wave thirty-five. The deep dark.',
      iconName: 'explore',
      coinReward: 400,
      target: 35,
      secret: true,
      progress: (c) => c.bestWave.clamp(0, 35),
    ),
    AchievementDefinition(
      id: 'ricochet_royalty',
      name: 'RICOCHET ROYALTY',
      flavor: 'A hundred thousand points. Bow, peasants.',
      iconName: 'workspace_premium',
      coinReward: 500,
      target: 1,
      secret: true,
      progress: (c) => _flag(c.bestScore >= 100000),
    ),
  ];

  static AchievementDefinition byId(String id) =>
      all.firstWhere((a) => a.id == id);
}
