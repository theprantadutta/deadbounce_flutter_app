import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../analytics/analytics.dart';
import '../logging/app_logger.dart';
import 'ad_config.dart';
import 'ad_consent.dart';
import 'ad_service.dart';
import 'interstitial_gate.dart';

/// The real [AdService], over Google Mobile Ads.
///
/// Everything here is written so that a failure is invisible: an ad that won't
/// load, won't show, or was never configured simply doesn't appear. No error
/// reaches the player, and no code path waits on one.
class GoogleAdService implements AdService {
  GoogleAdService({
    AdConsent? consent,
    InterstitialGate? gate,
    this.lifetimeRuns = 0,
  })  : _consent = consent ?? AdConsent(),
        gate = gate ?? InterstitialGate();

  final AdConsent _consent;
  final InterstitialGate gate;

  /// Read at gate time; kept current by the run-end path.
  int lifetimeRuns;

  bool _started = false;
  bool _canRequest = false;
  bool _adsRemoved = false;

  final Map<RewardedPlacement, RewardedAd> _rewarded = {};
  final Set<RewardedPlacement> _loadingRewarded = {};
  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;

  @override
  bool get adsRemoved => _adsRemoved;

  @override
  void setAdsRemoved(bool removed) {
    if (_adsRemoved == removed) return;
    _adsRemoved = removed;
    if (removed) {
      // Drop what's already in hand so a just-purchased no-ads takes effect
      // immediately rather than after one more interruption.
      _interstitial?.dispose();
      _interstitial = null;
    } else {
      _preloadInterstitial();
    }
  }

  @override
  Future<void> start() async {
    if (_started) return;
    _started = true;

    try {
      await MobileAds.instance.initialize();

      final testDevices = AdConfig.testDeviceIds;
      if (testDevices.isNotEmpty) {
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: testDevices),
        );
      }

      // Consent BEFORE any request. In the EEA/UK, asking for an ad first is a
      // compliance breach, and AdMob refuses to serve rather than allow it.
      await _consent.gather();
      _canRequest = await _consent.canRequestAds();

      AppLogger.talker.info('[ads] initialized (canRequest=$_canRequest)');
      if (!_canRequest) return;

      // Warm the two that must be instant when asked for: the death-screen
      // continue, and the between-runs interstitial.
      _preloadRewarded(RewardedPlacement.continueRun);
      _preloadInterstitial();
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[ads] initialization failed');
    }
  }

  // ---- Rewarded ----

  String _unitFor(RewardedPlacement placement) => switch (placement) {
        RewardedPlacement.continueRun => AdConfig.rewardedContinue,
        RewardedPlacement.reroll => AdConfig.rewardedReroll,
        RewardedPlacement.doubleCoins => AdConfig.rewardedDoubleCoins,
        RewardedPlacement.dailyBonus => AdConfig.rewardedDailyBonus,
      };

  @override
  bool isRewardedReady(RewardedPlacement placement) =>
      _rewarded[placement] != null;

  void _preloadRewarded(RewardedPlacement placement) {
    if (!_canRequest) return;
    if (_rewarded.containsKey(placement)) return;
    if (!_loadingRewarded.add(placement)) return;

    final unitId = _unitFor(placement);
    if (unitId.isEmpty) {
      // No configured unit — this placement is simply off.
      _loadingRewarded.remove(placement);
      return;
    }

    RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingRewarded.remove(placement);
          _rewarded[placement] = ad;
        },
        onAdFailedToLoad: (error) {
          _loadingRewarded.remove(placement);
          // Expected regularly (no fill). Debug-level so it doesn't read as a
          // fault in the logs.
          AppLogger.talker.debug(
            '[ads] rewarded ${placement.analyticsName} failed to load: ${error.message}',
          );
        },
      ),
    );
  }

  @override
  Future<bool> showRewarded(RewardedPlacement placement) async {
    // Rewarded ads are NOT suppressed by the no-ads entitlement — they're
    // opt-in, and players who paid still expect to keep the bonus.
    final ad = _rewarded.remove(placement);
    if (ad == null) {
      // Nothing in hand. Start loading for next time and report "not watched"
      // so the caller falls back to its coin path.
      _preloadRewarded(placement);
      Analytics.adRewardResult(
        placement: placement.analyticsName,
        result: 'unavailable',
      );
      return false;
    }

    Analytics.adRewardStarted(placement: placement.analyticsName);

    final completer = Completer<bool>();
    var earned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.talker
            .warning('[ads] rewarded show failed: ${error.message}');
        ad.dispose();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      await ad.show(onUserEarnedReward: (_, _) => earned = true);
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[ads] rewarded show threw');
      if (!completer.isCompleted) completer.complete(false);
    }

    final result = await completer.future;

    // Watching one buys a day's peace from interstitials.
    if (result) gate.recordRewardedWatched(DateTime.now());

    Analytics.adRewardResult(
      placement: placement.analyticsName,
      result: result ? 'earned' : 'abandoned',
    );

    // Have the next one ready before it's asked for.
    _preloadRewarded(placement);
    return result;
  }

  // ---- Interstitial ----

  void _preloadInterstitial() {
    if (!_canRequest || _adsRemoved) return;
    if (_interstitial != null || _loadingInterstitial) return;

    final unitId = AdConfig.interstitialBetweenRuns;
    if (unitId.isEmpty) return;

    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingInterstitial = false;
          _interstitial = ad;
        },
        onAdFailedToLoad: (error) {
          _loadingInterstitial = false;
          AppLogger.talker
              .debug('[ads] interstitial failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Call at the end of every run so the pacing gate can count.
  @override
  void recordRunFinished() => gate.recordRunFinished();

  @override
  Future<bool> maybeShowInterstitial({
    bool isNormalRun = true,
    bool sessionEnding = false,
  }) async {
    if (!_canRequest || _adsRemoved) return false;

    final allowed = gate.shouldShow(
      now: DateTime.now(),
      lifetimeRuns: lifetimeRuns,
      isNormalRun: isNormalRun,
      sessionEnding: sessionEnding,
      adsRemoved: _adsRemoved,
    );
    if (!allowed) return false;

    final ad = _interstitial;
    if (ad == null) {
      // Gate said yes but nothing is loaded. Don't consume the allowance —
      // leave the gate untouched so the next eligible moment can still fire.
      _preloadInterstitial();
      return false;
    }
    _interstitial = null;

    final completer = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.talker
            .warning('[ads] interstitial show failed: ${error.message}');
        ad.dispose();
        if (!completer.isCompleted) completer.complete();
      },
    );

    try {
      await ad.show();
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[ads] interstitial show threw');
      if (!completer.isCompleted) completer.complete();
    }

    await completer.future;
    gate.recordInterstitialShown(DateTime.now());
    Analytics.adInterstitialShown();
    _preloadInterstitial();
    return true;
  }

  // ---- Banner ----

  @override
  String? get bannerUnitId {
    if (!_canRequest || _adsRemoved) return null;
    final unitId = AdConfig.bannerMeta;
    return unitId.isEmpty ? null : unitId;
  }

  @override
  Future<bool> isPrivacyOptionsRequired() => _consent.isPrivacyOptionsRequired();

  @override
  Future<void> showPrivacyOptions() => _consent.showPrivacyOptions();

  @override
  Future<void> dispose() async {
    for (final ad in _rewarded.values) {
      ad.dispose();
    }
    _rewarded.clear();
    _interstitial?.dispose();
    _interstitial = null;
  }
}
