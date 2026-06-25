import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

import '../logging/app_logger.dart';

/// Android in-app updates via the Play "flexible" flow: the new version
/// downloads in the background while the player keeps using the app, then we
/// prompt them to restart to install.
///
/// It is a no-op everywhere except a release Android build installed through
/// Google Play — `in_app_update` can ONLY be exercised via Play, so debug/dev
/// runs and non-Android platforms short-circuit, and every call swallows its
/// errors (no network, sideloaded build, etc.) so a failed check never
/// disrupts the player.
class AppUpdater {
  const AppUpdater._();

  /// Once-per-process guard so revisiting the home screen doesn't re-trigger
  /// the check / re-download.
  static bool _attempted = false;

  /// Checks Play for an available update and, if a flexible update is allowed,
  /// downloads it in the background. Returns true once an update has finished
  /// downloading and is ready to install — the caller then prompts the player
  /// and calls [completeFlexibleUpdate]. Returns false (and never throws) in
  /// every other case.
  static Future<bool> checkAndDownloadFlexible() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    if (_attempted) return false;
    _attempted = true;

    try {
      final info = await InAppUpdate.checkForUpdate();

      // A download finished in a previous session but wasn't installed — it's
      // ready to go right now.
      if (info.installStatus == InstallStatus.downloaded) return true;

      if (info.updateAvailability != UpdateAvailability.updateAvailable ||
          !info.flexibleUpdateAllowed) {
        return false;
      }

      // Resolves when the background download completes (or the user declines).
      final result = await InAppUpdate.startFlexibleUpdate();
      return result == AppUpdateResult.success;
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[update] flexible update check failed');
      return false;
    }
  }

  /// Installs an already-downloaded flexible update — Play restarts the app to
  /// apply it. Call only after [checkAndDownloadFlexible] returned true and the
  /// player confirmed. Swallows errors.
  static Future<void> completeFlexibleUpdate() async {
    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[update] complete flexible update failed');
    }
  }
}
