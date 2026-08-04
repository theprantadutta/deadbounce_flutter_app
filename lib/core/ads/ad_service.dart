/// Which rewarded placement is being shown. Kept as an enum so a placement
/// can't be requested by a typo'd string, and so analytics slices cleanly.
enum RewardedPlacement {
  /// The death screen — "watch an ad" beside "pay coins".
  continueRun,

  /// First upgrade reroll of a run.
  reroll,

  /// Results screen — double the run's coins.
  doubleCoins,

  /// Once a day, beside the login-streak claim.
  dailyBonus;

  String get analyticsName => switch (this) {
        RewardedPlacement.continueRun => 'continue',
        RewardedPlacement.reroll => 'reroll',
        RewardedPlacement.doubleCoins => 'double_coins',
        RewardedPlacement.dailyBonus => 'daily_bonus',
      };
}

/// Seam over the ad SDK.
///
/// Same shape as `SoundManager` / `AnalyticsService`: gameplay and UI depend on
/// this interface, a no-op implementation keeps tests and unsupported devices
/// working, and **every failure degrades to "no ad" rather than an error**. An
/// ad that won't load must never block a run, a reward, or a screen.
abstract interface class AdService {
  /// Initialises the SDK and resolves consent. Safe to call once at start-up.
  Future<void> start();

  /// True when the banner and interstitial should be suppressed because the
  /// player bought them away.
  ///
  /// Rewarded ads are deliberately NOT covered — they stay available to
  /// everyone. That's the genre norm and players expect to keep the opt-in
  /// bonus they paid nothing for.
  bool get adsRemoved;

  /// Called when entitlements change so the gate can update without a restart.
  void setAdsRemoved(bool removed);

  /// Whether a rewarded ad is ready to show for [placement].
  bool isRewardedReady(RewardedPlacement placement);

  /// Shows a rewarded ad. Returns true ONLY if the user earned the reward.
  ///
  /// A false return must always be safe to treat as "they didn't watch it" —
  /// no reward, no penalty, no error surfaced.
  Future<bool> showRewarded(RewardedPlacement placement);

  /// Shows the between-runs interstitial IF every pacing rule allows it.
  /// Returns true when one was actually shown.
  Future<bool> maybeShowInterstitial();

  /// The banner unit id for the meta screens, or null when banners are
  /// suppressed (entitlement, consent, or no configured unit).
  String? get bannerUnitId;

  Future<void> dispose();
}

/// Does nothing, successfully.
///
/// Used in tests, before start-up, and on any platform where ads aren't
/// supported — so call sites never branch on availability.
class NoopAdService implements AdService {
  const NoopAdService();

  @override
  Future<void> start() async {}

  @override
  bool get adsRemoved => true;

  @override
  void setAdsRemoved(bool removed) {}

  @override
  bool isRewardedReady(RewardedPlacement placement) => false;

  @override
  Future<bool> showRewarded(RewardedPlacement placement) async => false;

  @override
  Future<bool> maybeShowInterstitial() async => false;

  @override
  String? get bannerUnitId => null;

  @override
  Future<void> dispose() async {}
}
