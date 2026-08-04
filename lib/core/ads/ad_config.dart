import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Where every ad unit id comes from.
///
/// **Debug builds ALWAYS use Google's official test units**, regardless of what
/// is in `.env`. Tapping your own live ads is the fastest way to have an AdMob
/// account suspended, and there is no appeal worth the trouble. Same rule as
/// `LoggingAnalyticsService`: development traffic never touches production.
///
/// A missing key in release simply disables that placement — the app runs fine
/// without ads, and a half-configured console can't crash anyone.
abstract final class AdConfig {
  // Google's documented sample units. Public, safe, always fill.
  static const _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _testInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const _testRewarded = 'ca-app-pub-3940256099942544/5224354917';

  static String _unit(String envKey, String testUnit) {
    if (kDebugMode) return testUnit;
    return dotenv.env[envKey] ?? '';
  }

  /// The death screen — the highest-intent moment in the game.
  static String get rewardedContinue =>
      _unit('ADMOB_REWARDED_CONTINUE', _testRewarded);

  /// First upgrade reroll of a run, free via ad.
  static String get rewardedReroll =>
      _unit('ADMOB_REWARDED_REROLL', _testRewarded);

  /// Results screen — double the run's coins.
  static String get rewardedDoubleCoins =>
      _unit('ADMOB_REWARDED_DOUBLE_COINS', _testRewarded);

  /// One per day, beside the login-streak claim.
  static String get rewardedDailyBonus =>
      _unit('ADMOB_REWARDED_DAILY_BONUS', _testRewarded);

  /// Meta screens only. Never Home, never in-run, never the results screen.
  static String get bannerMeta => _unit('ADMOB_BANNER_META', _testBanner);

  static String get interstitialBetweenRuns =>
      _unit('ADMOB_INTERSTITIAL_BETWEEN_RUNS', _testInterstitial);

  /// Devices allowed to see test ads against LIVE unit ids, so placements can
  /// be verified on a real device without generating invalid traffic.
  static List<String> get testDeviceIds {
    final raw = dotenv.env['ADMOB_TEST_DEVICE_IDS'] ?? '';
    return raw
        .split(',')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();
  }
}
