import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/auth_user.dart';

/// Caches the authenticated [AuthUser] in platform secure storage so the app
/// can restore a session OFFLINE — without a `GET /auth/me` round-trip. The
/// single read/write/clear surface for the cached identity; the repository
/// depends on this, never on [FlutterSecureStorage] directly.
class AuthLocalDataSource {
  AuthLocalDataSource([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _userKey = 'deadbounce_cached_user';

  final FlutterSecureStorage _storage;

  Future<void> cacheUser(AuthUser user) =>
      _storage.write(key: _userKey, value: jsonEncode(_toJson(user)));

  Future<AuthUser?> readUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return _fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e, st) {
      // Corrupt cache shouldn't strand the user — drop it and move on.
      AppLogger.talker.handle(e, st, '[auth] cached user decode failed');
      await clear();
      return null;
    }
  }

  Future<void> clear() => _storage.delete(key: _userKey);

  Map<String, dynamic> _toJson(AuthUser u) => {
        'id': u.id,
        'is_anonymous': u.isAnonymous,
        'email': u.email,
        'username': u.username,
        'display_name': u.displayName,
        'photo_url': u.photoUrl,
      };

  AuthUser _fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        isAnonymous: json['is_anonymous'] as bool? ?? false,
        email: json['email'] as String?,
        username: json['username'] as String?,
        displayName: json['display_name'] as String?,
        photoUrl: json['photo_url'] as String?,
      );
}
