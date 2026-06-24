import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';

import 'app.dart';
import 'core/config/game_balance_store.dart';
import 'core/legal/legal_consent_store.dart';
import 'core/logging/app_logger.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration first — AppConfig reads from this everywhere else.
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
  }

  // Device-level legal consent — loaded synchronously here so the router's
  // first-launch gate (Privacy Policy + Terms) can read it without async.
  final legalConsent = LegalConsentStore(await SharedPreferences.getInstance());

  runApp(DeadbounceApp(legalConsent: legalConsent));
}
