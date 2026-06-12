import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the Deadbounce JWT in platform secure storage (Keystore on
/// Android). The single write/read/clear surface for auth tokens — data
/// sources depend on this, never on FlutterSecureStorage directly.
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _accessTokenKey = 'deadbounce_access_token';

  final FlutterSecureStorage _storage;

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> clear() => _storage.delete(key: _accessTokenKey);
}
