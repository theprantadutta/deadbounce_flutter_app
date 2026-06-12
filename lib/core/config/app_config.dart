import 'package:flutter/foundation.dart';

/// Build-time configuration. Values come from `--dart-define` so nothing
/// environment-specific is hardcoded in widget/data code:
///
///   flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8394
///
/// Defaults: Android-emulator loopback in debug builds, the production
/// Traefik host otherwise.
abstract final class AppConfig {
  static const String _definedBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_definedBaseUrl.isNotEmpty) return _definedBaseUrl;
    // 10.0.2.2 is the Android emulator's alias for the host machine.
    return kDebugMode
        ? 'http://10.0.2.2:8394'
        : 'https://deadbounce.pranta.dev';
  }

  static String get apiV1 => '$apiBaseUrl/api/v1';

  /// Web (server) OAuth client ID for Google Sign-In, e.g.
  /// `351700332072-xxxx.apps.googleusercontent.com`.
  ///
  /// Optional on Android: when empty, google_sign_in falls back to the
  /// `default_web_client_id` that the google-services Gradle plugin
  /// generates from google-services.json (present once the Google provider
  /// is enabled in the Firebase console). Pass it explicitly via
  /// `--dart-define=GOOGLE_SERVER_CLIENT_ID=...` to override.
  static const String googleServerClientId =
      String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
}
