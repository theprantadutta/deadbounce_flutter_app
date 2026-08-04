/// Decides whether a between-runs interstitial may show.
///
/// Pure logic, no SDK — so the rules that decide how often a player is
/// interrupted are unit-testable rather than buried in ad-loading code.
///
/// **Every rule must pass.** The design target is roughly one interstitial per
/// 15–20 minutes of engaged play; the intent is that a player never thinks
/// "this game is full of ads", because the moment they do, the rewarded ads
/// (which carry the revenue) stop getting watched too.
class InterstitialGate {
  InterstitialGate({
    this.minRunsBetween = 4,
    this.minGap = const Duration(minutes: 3),
    this.minLifetimeRuns = 5,
    this.rewardedCooldown = const Duration(hours: 24),
  });

  /// Runs that must pass since the last interstitial.
  final int minRunsBetween;

  /// Wall-clock that must pass since the last interstitial.
  final Duration minGap;

  /// Lifetime runs before the FIRST interstitial is ever allowed — a player
  /// still learning the game must never be interrupted.
  final int minLifetimeRuns;

  /// After watching a rewarded ad, interstitials are suppressed for this long.
  /// Someone who opts in has already paid attention; taxing them again is how
  /// you train players to stop opting in.
  final Duration rewardedCooldown;

  int _runsSinceLast = 0;
  DateTime? _lastShown;
  DateTime? _lastRewardedWatch;

  /// Call at the end of every run.
  void recordRunFinished() => _runsSinceLast++;

  void recordInterstitialShown(DateTime now) {
    _lastShown = now;
    _runsSinceLast = 0;
  }

  void recordRewardedWatched(DateTime now) => _lastRewardedWatch = now;

  /// [lifetimeRuns] comes from player stats; [sessionEnding] is true when the
  /// player is leaving (quitting to Home), because an ad on the way out is
  /// pure annoyance with no session left to interrupt.
  bool shouldShow({
    required DateTime now,
    required int lifetimeRuns,
    required bool isNormalRun,
    required bool sessionEnding,
    required bool adsRemoved,
  }) {
    if (adsRemoved) return false;

    // Tournament and daily-challenge runs are competitive and seeded; an
    // interstitial mid-contest is the worst possible moment.
    if (!isNormalRun) return false;
    if (sessionEnding) return false;

    // Onboarding is sacred.
    if (lifetimeRuns < minLifetimeRuns) return false;

    if (_runsSinceLast < minRunsBetween) return false;

    final last = _lastShown;
    if (last != null && now.difference(last) < minGap) return false;

    final rewarded = _lastRewardedWatch;
    if (rewarded != null && now.difference(rewarded) < rewardedCooldown) {
      return false;
    }

    return true;
  }

  /// Exposed for diagnostics and tests.
  int get runsSinceLast => _runsSinceLast;
  DateTime? get lastShown => _lastShown;
  DateTime? get lastRewardedWatch => _lastRewardedWatch;
}
