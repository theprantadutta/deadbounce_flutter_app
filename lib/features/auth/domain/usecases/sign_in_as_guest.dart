import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInAsGuest {
  const SignInAsGuest(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call() => _repository.signInAsGuest();
}
