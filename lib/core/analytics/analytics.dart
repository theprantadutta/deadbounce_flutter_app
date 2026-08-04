import 'analytics_service.dart';

/// The Phase 0 event taxonomy, as a typed API.
///
/// **Every analytics call in the app goes through here.** Call sites never
/// touch raw event-name strings, because a renamed event silently resets its
/// own history in Firebase — the names below are append-only. Add events;
/// don't rename them.
///
/// Shaped like [GameBalance.I] / `MusicManager.instance`: a swappable static
/// singleton, so the eight-odd cubits that emit events don't each have to
/// thread a dependency, and tests swap in a recorder and assert.
///
/// Defaults to [NoopAnalyticsService], so anything that forgets to call
/// [configure] (every widget test, for one) is silently inert.
class Analytics {
  Analytics._();

  static AnalyticsService _service = const NoopAnalyticsService();

  /// Installs the real backend. Called once from `main()` after Firebase init.
  static void configure(AnalyticsService service) => _service = service;

  /// Restores the no-op backend. Tests call this in `tearDown`.
  static void reset() => _service = const NoopAnalyticsService();

  /// The active transport — exposed for tests that want to assert on it.
  static AnalyticsService get service => _service;

  // ---- Firebase hard limits, enforced here so a bad value is clamped
  // rather than silently dropping the whole event. ----
  static const int _maxParams = 25;
  static const int _maxStringValueLength = 100;
  static const int _maxUserPropertyLength = 36;

  /// Drops nulls, clamps over-long strings, and caps the parameter count.
  static Map<String, Object> _clean(Map<String, Object?> raw) {
    final out = <String, Object>{};
    for (final entry in raw.entries) {
      if (out.length >= _maxParams) break;
      final value = entry.value;
      if (value == null) continue;
      out[entry.key] = value is String && value.length > _maxStringValueLength
          ? value.substring(0, _maxStringValueLength)
          : value;
    }
    return out;
  }

  static Future<void> _send(String name, [Map<String, Object?>? params]) =>
      _service.logEvent(name, params == null ? null : _clean(params));

  // ---- Identity ----

  /// Associates events with the signed-in account. Null on sign-out.
  /// Pass the **backend user id**, never an email.
  static Future<void> identify(String? userId) => _service.setUserId(userId);

  /// Durable cohorting dimensions, refreshed when lifetime stats change.
  static Future<void> setPlayerProperties({
    int? bestWave,
    int? runsPlayed,
    bool? isGuest,
  }) async {
    String clamp(String v) => v.length > _maxUserPropertyLength
        ? v.substring(0, _maxUserPropertyLength)
        : v;
    if (bestWave != null) {
      await _service.setUserProperty('best_wave', clamp('$bestWave'));
    }
    if (runsPlayed != null) {
      await _service.setUserProperty('runs_played', clamp('$runsPlayed'));
    }
    if (isGuest != null) {
      await _service.setUserProperty('is_guest', isGuest ? 'true' : 'false');
    }
  }

  // ---- Navigation ----

  static Future<void> screenView(String screenName) =>
      _service.logScreenView(screenName);

  // ---- Run lifecycle ----
  //
  // [mode] is one of `normal` / `daily` / `tournament` — the single most
  // important slice, because normal runs are the only ones that carry perks,
  // unlocks and coin sinks.

  static Future<void> runStart({
    required String mode,
    required String arenaId,
  }) =>
      _send('run_start', {'mode': mode, 'arena_id': arenaId});

  static Future<void> runEnd({
    required String mode,
    required int wave,
    required int score,
    required int kills,
    required int durationSeconds,
    required int coinsEarned,
    String? causeOfDeath,
  }) =>
      _send('run_end', {
        'mode': mode,
        'wave': wave,
        'score': score,
        'kills': kills,
        'duration_s': durationSeconds,
        'coins_earned': coinsEarned,
        'cause_of_death': causeOfDeath,
      });

  static Future<void> waveCleared({
    required String mode,
    required int wave,
  }) =>
      _send('wave_cleared', {'mode': mode, 'wave': wave});

  // ---- The upgrade draft ----

  static Future<void> upgradePicked({
    required String cardId,
    required String rarity,
    required int wave,
  }) =>
      _send('upgrade_picked', {
        'card_id': cardId,
        'rarity': rarity,
        'wave': wave,
      });

  /// The escalating in-run coin sink — a leading indicator for coin demand,
  /// so it matters for Phase 3/5C sizing.
  static Future<void> draftReroll({
    required int cost,
    required int rerollIndex,
    required int wave,
  }) =>
      _send('draft_reroll', {
        'cost': cost,
        'reroll_index': rerollIndex,
        'wave': wave,
      });

  // ---- Continue-on-death (the future rewarded-ad slot) ----
  //
  // The offered/bought/declined triple is what tells us the take rate before
  // an ad option exists, so Phase 4 has a baseline to beat.

  static Future<void> continueOffered({
    required int wave,
    required int cost,
    required bool canAfford,
  }) =>
      _send('continue_offered', {
        'wave': wave,
        'cost': cost,
        'can_afford': canAfford,
      });

  static Future<void> continueBought({
    required int wave,
    required int cost,
  }) =>
      _send('continue_bought', {'wave': wave, 'cost': cost});

  static Future<void> continueDeclined({required int wave}) =>
      _send('continue_declined', {'wave': wave});

  // ---- Shops (the existing coin sinks) ----

  /// [shop] is `gunsmith` or `outfitter`.
  static Future<void> shopView(String shop) =>
      _send('shop_view', {'shop': shop});

  static Future<void> shopPurchase({
    required String shop,
    required String itemId,
    required int cost,
    int? level,
  }) =>
      _send('shop_purchase', {
        'shop': shop,
        'item_id': itemId,
        'cost': cost,
        'level': level,
      });

  // ---- Meta / retention loops ----

  static Future<void> tournamentJoin({
    required String tournamentId,
    required String cadence,
    required int entryFee,
  }) =>
      _send('tournament_join', {
        'tournament_id': tournamentId,
        'cadence': cadence,
        'entry_fee': entryFee,
      });

  static Future<void> dailyClaim({
    required int day,
    required int streak,
    required int reward,
  }) =>
      _send('daily_claim', {
        'day': day,
        'streak': streak,
        'reward': reward,
      });

  static Future<void> achievementClaim({
    required String achievementId,
    required int reward,
  }) =>
      _send('achievement_claim', {
        'achievement_id': achievementId,
        'reward': reward,
      });

  /// Guest → permanent account. [result] is `success` / `cancelled` /
  /// `credential_in_use` / `failed`.
  ///
  /// One event with a result dimension rather than four event names: Firebase
  /// caps distinct names, and a single funnel is far easier to read.
  static Future<void> accountLink({
    required String provider,
    required String result,
  }) =>
      _send('account_link', {'provider': provider, 'result': result});

  // ---- Real-money purchases ----
  //
  // Two events, not one per outcome: `purchase_started` is the denominator and
  // `purchase_result` carries what happened, so the drop-off between opening
  // the Play sheet and a granted entitlement is a single readable funnel.

  static Future<void> purchaseStarted({
    required String productId,
    required String kind,
  }) =>
      _send('purchase_started', {'product_id': productId, 'kind': kind});

  /// [result] is `granted` / `already_owned` / `cancelled` / `pending` /
  /// `error` / `verify_failed`. `verify_failed` is the one to watch — it means
  /// money changed hands and the server didn't confirm it.
  static Future<void> purchaseResult({
    required String productId,
    required String result,
  }) =>
      _send('purchase_result', {'product_id': productId, 'result': result});

  // ---- Ads ----
  //
  // started/result as a pair, same shape as the purchase funnel: the drop-off
  // between offering a rewarded ad and the reward landing is the number that
  // says whether a placement is worth keeping.

  static Future<void> adRewardStarted({required String placement}) =>
      _send('ad_reward_started', {'placement': placement});

  /// [result] is `earned` / `abandoned` / `unavailable`. A high `unavailable`
  /// rate means no fill, not player behaviour — very different problems.
  static Future<void> adRewardResult({
    required String placement,
    required String result,
  }) =>
      _send('ad_reward_result', {'placement': placement, 'result': result});

  static Future<void> adInterstitialShown() => _send('ad_interstitial_shown');

  static Future<void> trickshotClear({
    required String levelId,
    required int shots,
    required int par,
  }) =>
      _send('trickshot_clear', {
        'level_id': levelId,
        'shots': shots,
        'par': par,
      });
}
