import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Upgrades the signed-in guest into a permanent Google account.
class LinkWithGoogle {
  const LinkWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call() => _repository.linkWithGoogle();
}
