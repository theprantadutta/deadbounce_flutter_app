import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call() => _repository.signInWithGoogle();
}
