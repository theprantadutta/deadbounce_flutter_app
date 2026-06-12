import '../../domain/entities/auth_user.dart';

/// Response of POST /auth/firebase — backend identity plus the Deadbounce
/// JWT. Field names are snake_case on the wire.
class AuthSessionModel {
  const AuthSessionModel({
    required this.userId,
    required this.accessToken,
    required this.isNewUser,
    this.email,
    this.username,
    this.displayName,
    this.photoUrl,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      userId: json['user_id'] as String,
      accessToken: json['access_token'] as String,
      isNewUser: json['is_new_user'] as bool? ?? false,
      email: json['email'] as String?,
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }

  final String userId;
  final String accessToken;
  final bool isNewUser;
  final String? email;
  final String? username;
  final String? displayName;
  final String? photoUrl;

  AuthUser toEntity({required bool isAnonymous}) => AuthUser(
        id: userId,
        isAnonymous: isAnonymous,
        email: email,
        username: username,
        displayName: displayName,
        photoUrl: photoUrl,
      );
}
