import '../repositories/auth_repository.dart';

/// Silently re-mints the Deadbounce JWT from the current Firebase identity.
class RefreshSession {
  const RefreshSession(this._repository);

  final AuthRepository _repository;

  Future<SessionRefreshOutcome> call() => _repository.refreshSessionToken();
}
