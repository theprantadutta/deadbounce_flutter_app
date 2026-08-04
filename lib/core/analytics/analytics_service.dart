/// Transport seam over an analytics backend.
///
/// Deliberately tiny and stringly-typed at this layer — the *typed* API that
/// gameplay/UI code calls lives in [Analytics] (`analytics.dart`), which folds
/// down onto these three methods. Keeping the transport dumb means the Firebase
/// impl, the no-op, and a test fake all stay trivial.
///
/// Failures are swallowed by the impl (telemetry is never worth crashing a run
/// over) — mirrors the [SoundManager] / [AppReviewService] seams.
abstract interface class AnalyticsService {
  /// Records one event. [parameters] must contain only `String`/`num`/`bool`
  /// values — Firebase rejects anything else, and nulls are stripped by
  /// [Analytics] before they get here.
  Future<void> logEvent(String name, [Map<String, Object>? parameters]);

  /// Records a screen view. Separate from [logEvent] because Firebase has a
  /// first-class screen API that feeds its funnel/retention reports.
  Future<void> logScreenView(String screenName);

  /// Sets a durable user-scoped dimension (used for cohorting).
  /// A null [value] clears the property.
  Future<void> setUserProperty(String name, String? value);

  /// Associates subsequent events with an account. Pass null on sign-out.
  ///
  /// We send the **backend user id, never the Firebase uid or an email** —
  /// it's already the pseudonymous key the rest of the stack uses.
  Future<void> setUserId(String? id);
}

/// Does nothing, successfully. Used in tests, on unsupported platforms, and
/// any time analytics initialisation fails — call sites never branch.
class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {}

  @override
  Future<void> logScreenView(String screenName) async {}

  @override
  Future<void> setUserProperty(String name, String? value) async {}

  @override
  Future<void> setUserId(String? id) async {}
}
