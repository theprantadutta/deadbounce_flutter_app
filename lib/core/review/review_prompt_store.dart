import 'package:shared_preferences/shared_preferences.dart';

/// Device-level throttle for the "rate this app" prompt.
///
/// Stored per-install in [SharedPreferences] (NOT the per-account Drift DB) —
/// a rating is a device action, independent of which account is signed in, and
/// mirrors [LegalConsentStore]'s device-level pattern. The rules keep the
/// native review sheet from nagging: we only ask a player with a few runs in,
/// never more than a small cap of times, and never inside a cooldown window.
/// (Google Play throttles server-side too, but we don't rely on that.)
///
/// [now] is injectable so the cooldown logic is unit-testable.
class ReviewPromptStore {
  ReviewPromptStore(this._prefs, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final SharedPreferences _prefs;
  final DateTime Function() _now;

  static const String _lastPromptedKey = 'review_last_prompted_ms';
  static const String _countKey = 'review_prompt_count';
  static const String _optedOutKey = 'review_opted_out';

  /// Don't ask until the player has this many runs behind them.
  static const int minRuns = 3;

  /// Never auto-prompt more than this many times, ever.
  static const int maxPrompts = 3;

  /// Minimum gap between auto-prompts.
  static const Duration cooldown = Duration(days: 14);

  int get _lastPromptedMs => _prefs.getInt(_lastPromptedKey) ?? 0;

  /// How many times the native prompt has been requested so far.
  int get promptCount => _prefs.getInt(_countKey) ?? 0;

  /// True once the user has been sent to rate manually — we stop auto-prompting.
  bool get optedOut => _prefs.getBool(_optedOutKey) ?? false;

  /// Whether the native review prompt may be shown right now.
  bool shouldPrompt(int runsPlayed) {
    if (optedOut) return false;
    if (runsPlayed < minRuns) return false;
    if (promptCount >= maxPrompts) return false;
    if (_lastPromptedMs == 0) return true;
    final since = _now().difference(
      DateTime.fromMillisecondsSinceEpoch(_lastPromptedMs),
    );
    return since >= cooldown;
  }

  /// Record that the prompt was requested (bumps the count + timestamp).
  Future<void> recordPrompted() async {
    await _prefs.setInt(_lastPromptedKey, _now().millisecondsSinceEpoch);
    await _prefs.setInt(_countKey, promptCount + 1);
  }

  /// Stop ever auto-prompting — called when the user taps the manual "Rate"
  /// button, so we don't also nag them with the native sheet afterwards.
  Future<void> optOut() async {
    await _prefs.setBool(_optedOutKey, true);
  }
}
