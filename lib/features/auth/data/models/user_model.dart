import '../../domain/entities/auth_user.dart';

/// Response of GET /auth/me. Field names are snake_case on the wire.
class UserModel {
  const UserModel({
    required this.id,
    required this.isAnonymous,
    this.email,
    this.username,
    this.displayName,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      email: json['email'] as String?,
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }

  final String id;
  final bool isAnonymous;
  final String? email;
  final String? username;
  final String? displayName;
  final String? photoUrl;

  AuthUser toEntity() => AuthUser(
        id: id,
        isAnonymous: isAnonymous,
        email: email,
        username: username,
        displayName: displayName,
        photoUrl: photoUrl,
      );
}
