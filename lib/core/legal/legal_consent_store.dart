import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'legal_documents.dart';

/// Device-level record of which legal version the user has accepted.
///
/// Consent is stored per-install in [SharedPreferences] (NOT in the per-account
/// Drift database) because it gates the very first launch — before any sign-in,
/// when no account database exists yet — and because accepting the Privacy
/// Policy / Terms is a device action, independent of which account signs in.
///
/// Exposed as a [ChangeNotifier] so the router can use it as a
/// `refreshListenable`: accepting re-runs the redirect and lets the user
/// through. The accepted value is read synchronously from the already-loaded
/// preferences, so the router's redirect stays synchronous.
class LegalConsentStore extends ChangeNotifier {
  LegalConsentStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'legal_accepted_version';

  /// The legal version the user last accepted (0 if never).
  int get acceptedVersion => _prefs.getInt(_key) ?? 0;

  /// Whether the user has accepted the current [LegalDocuments.version].
  /// False on a fresh install and whenever the documents are bumped.
  bool get hasAcceptedCurrent => acceptedVersion >= LegalDocuments.version;

  /// Record acceptance of the current legal version and notify listeners
  /// (which triggers the router to let the user past the consent gate).
  Future<void> accept() async {
    await _prefs.setInt(_key, LegalDocuments.version);
    notifyListeners();
  }
}
