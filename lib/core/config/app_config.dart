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
}
