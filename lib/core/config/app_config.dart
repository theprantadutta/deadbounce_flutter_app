import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration backed by the `.env` file (loaded in main.dart
/// before runApp). Nothing environment-specific is hardcoded in widget or
/// data code — copy `.env.example` to `.env` and edit there.
///
/// Debug builds talk to [API_BASE_URL_DEV], release builds to
/// [API_BASE_URL_PROD] — selected by [kDebugMode].
abstract final class AppConfig {
  static String get apiBaseUrl {
    final key = kDebugMode ? 'API_BASE_URL_DEV' : 'API_BASE_URL_PROD';
    final url = dotenv.env[key];
    if (url == null || url.isEmpty) {
      throw StateError('$key is missing from .env — copy .env.example to '
          '.env and fill it in.');
    }
    return url;
  }

  static String get apiV1 => '$apiBaseUrl/api/v1';

  /// Web (server) OAuth client ID for Google Sign-In, e.g.
  /// `351700332072-xxxx.apps.googleusercontent.com`. Empty string when not
  /// configured — google_sign_in then falls back to the
  /// `default_web_client_id` generated from google-services.json on Android.
  static String get googleServerClientId =>
      dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '';
}
