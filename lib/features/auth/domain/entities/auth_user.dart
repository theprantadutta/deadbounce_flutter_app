import 'package:equatable/equatable.dart';

/// The authenticated Deadbounce player as the app knows them — backend
/// identity (not the Firebase user).
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.isAnonymous,
    this.email,
    this.username,
    this.displayName,
    this.photoUrl,
  });

  final String id;
  final bool isAnonymous;
  final String? email;
  final String? username;
  final String? displayName;
  final String? photoUrl;

  /// Best display label for UI greetings.
  String get label =>
      displayName ?? username ?? (isAnonymous ? 'Drifter' : 'Gunslinger');

  @override
  List<Object?> get props =>
      [id, isAnonymous, email, username, displayName, photoUrl];
}
