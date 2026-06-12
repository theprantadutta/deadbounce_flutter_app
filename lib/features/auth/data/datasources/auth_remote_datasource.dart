import '../../../../core/network/api_client.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';

/// Talks to the Deadbounce backend auth endpoints.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// Exchanges a Firebase ID token for a Deadbounce session (JWT + user).
  Future<AuthSessionModel> authenticateWithFirebase(String firebaseIdToken) async {
    final json = await _apiClient.post(
      '/auth/firebase',
      body: {
        'firebase_token': firebaseIdToken,
        'time_zone_offset_minutes': DateTime.now().timeZoneOffset.inMinutes,
      },
    );
    return AuthSessionModel.fromJson(json);
  }

  /// Fetches the current user for the stored JWT. Throws [ApiException]
  /// with 401 when the token is expired/invalid.
  Future<UserModel> getCurrentUser() async {
    final json = await _apiClient.get('/auth/me');
    return UserModel.fromJson(json);
  }

  Future<void> logout() => _apiClient.post('/auth/logout');
}
