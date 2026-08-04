import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../logging/app_logger.dart';

/// The GDPR/UMP consent gate.
///
/// **No ad may load until this reports back.** In the EEA and UK, requesting a
/// personalised ad before consent is a straight compliance breach, and AdMob
/// will refuse to serve rather than let you do it. Everywhere else UMP returns
/// "not required" almost instantly, so the gate costs nothing.
///
/// Deliberately fail-open on ERRORS but fail-closed on consent: if the consent
/// SDK itself is unreachable we still let non-personalised serving proceed
/// (Google decides what to send), but we never claim consent we didn't get.
class AdConsent {
  AdConsent({ConsentInformation? consentInformation})
      : _consent = consentInformation ?? ConsentInformation.instance;

  final ConsentInformation _consent;

  bool _resolved = false;

  /// True once UMP has either collected consent or said it wasn't required.
  bool get isResolved => _resolved;

  /// Requests the consent info and shows the form if one is required.
  ///
  /// Safe to call more than once — UMP caches its own state, and repeated calls
  /// after resolution are cheap no-ops.
  Future<void> gather() async {
    final completer = Completer<void>();

    _consent.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        try {
          // Shows the form only when UMP says one is required; otherwise this
          // returns immediately.
          await ConsentForm.loadAndShowConsentFormIfRequired((error) {
            if (error != null) {
              AppLogger.talker
                  .warning('[ads] consent form error: ${error.message}');
            }
          });
        } catch (e, st) {
          AppLogger.talker.handle(e, st, '[ads] consent form failed');
        }
        _resolved = true;
        if (!completer.isCompleted) completer.complete();
      },
      (error) {
        // Couldn't reach the consent SDK. Mark resolved so the app isn't
        // permanently ad-free over a transient network problem — Google still
        // decides what it is willing to serve without consent signals.
        AppLogger.talker
            .warning('[ads] consent info update failed: ${error.message}');
        _resolved = true;
        if (!completer.isCompleted) completer.complete();
      },
    );

    return completer.future;
  }

  /// Whether ad requests are permitted right now.
  Future<bool> canRequestAds() async {
    try {
      return await _consent.canRequestAds();
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[ads] canRequestAds failed');
      return false;
    }
  }

  /// Whether a privacy-options entry point should be shown.
  ///
  /// True only in regions where Google's consent platform provides one (the
  /// EEA, UK and Switzerland), so the Settings row doesn't appear as a dead
  /// control everywhere else.
  Future<bool> isPrivacyOptionsRequired() async {
    try {
      return await _consent.getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[ads] privacy options check failed');
      return false;
    }
  }

  /// Reopens the consent form so a player can change their choice.
  ///
  /// Backs **Settings → Ad privacy**, which the Privacy Policy explicitly
  /// promises — so this has to keep working, not just exist.
  Future<void> showPrivacyOptions() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((error) {
        if (error != null) {
          AppLogger.talker
              .warning('[ads] privacy options form error: ${error.message}');
        }
      });
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[ads] privacy options form failed');
    }
  }

  /// Clears stored consent. Debug-only helper for re-testing the form —
  /// calling it in production would re-prompt everyone.
  Future<void> reset() async => _consent.reset();
}
