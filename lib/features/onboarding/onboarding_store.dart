import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-level record of whether the user has seen the interactive new-user
/// walkthrough.
///
/// Stored per-install in [SharedPreferences] (NOT the per-account Drift DB) and
/// exposed as a [ChangeNotifier] so the router can use it as a
/// `refreshListenable` — completing/skipping the tutorial re-runs the redirect
/// and lets the user through to Home. Mirrors [LegalConsentStore] exactly; the
/// difference is that this gate lives AFTER auth (the tutorial reuses the game
/// engine, which needs a signed-in session).
class OnboardingStore extends ChangeNotifier {
  OnboardingStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'onboarding_tutorial_completed';

  /// Whether the walkthrough has been completed or skipped on this device.
  /// False on a fresh install → first-time users are routed into it.
  bool get hasCompletedTutorial => _prefs.getBool(_key) ?? false;

  /// Mark the walkthrough done (on completion OR skip) and notify listeners,
  /// which triggers the router to allow Home.
  Future<void> markComplete() async {
    await _prefs.setBool(_key, true);
    notifyListeners();
  }
}
