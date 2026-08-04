import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'app.dart';
import 'core/analytics/analytics.dart';
import 'core/analytics/firebase_analytics_service.dart';
import 'core/analytics/logging_analytics_service.dart';
import 'core/config/game_balance_store.dart';
import 'core/legal/legal_consent_store.dart';
import 'core/logging/app_logger.dart';
import 'core/review/review_prompt_store.dart';
import 'features/onboarding/onboarding_store.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register the SIL Open Font License for the bundled fonts (Orbitron,
  // Rajdhani) so the attribution shows in the app's licenses page — the
  // google_fonts package used to do this; we bundle the fonts ourselves now.
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(
      const ['Orbitron'],
      await rootBundle.loadString('assets/fonts/Orbitron-OFL.txt'),
    );
    yield LicenseEntryWithLineBreaks(
      const ['Rajdhani'],
      await rootBundle.loadString('assets/fonts/Rajdhani-OFL.txt'),
    );
  });

  // Configuration first — AppConfig reads from this everywhere else.
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Telemetry. Debug builds log events locally and upload nothing — dev
  // sessions would visibly skew retention/funnel numbers at indie volume.
  Analytics.configure(
    kDebugMode
        ? const LoggingAnalyticsService()
        : FirebaseAnalyticsService(),
  );

  // Crash reporting, release-only for the same reason: a crash on a dev
  // machine must never count against production crash-free users.
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode,
  );

  // Portrait-first arena game.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Hide the top status bar for the whole app, from launch — keep the bottom
  // system nav. Neon arena, no clock/notifications bar anywhere.
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom],
  );

  // Debug-only setup: logging engine wiring + tuning-panel tweaks. Release
  // builds skip all of this and run with logging fully off (no overhead).
  if (kDebugMode) {
    // Route every Cubit state change/error through Talker.
    Bloc.observer = TalkerBlocObserver(talker: AppLogger.talker);
    // Capture framework + platform errors instead of losing them.
    FlutterError.onError = (details) {
      AppLogger.talker.handle(details.exception, details.stack, '[flutter]');
      FlutterError.presentError(details);
    };
    WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
      AppLogger.talker.handle(error, stack, '[platform]');
      return false;
    };
    await GameBalanceStore.load();
  } else {
    // Release: the same two hooks, routed to Crashlytics instead. Previously
    // unset in release, so uncaught framework/platform errors were simply
    // lost.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Device-level prefs, loaded once and shared. Both stores are per-install
  // (not per-account): consent gates the very first launch (pre-sign-in), and
  // the review throttle is a device action independent of who's signed in.
  final prefs = await SharedPreferences.getInstance();
  final legalConsent = LegalConsentStore(prefs);
  final reviewPromptStore = ReviewPromptStore(prefs);
  final onboarding = OnboardingStore(prefs);

  runApp(DeadbounceApp(
    legalConsent: legalConsent,
    reviewPromptStore: reviewPromptStore,
    onboarding: onboarding,
  ));
}
