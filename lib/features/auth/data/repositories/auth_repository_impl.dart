import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Composes the two-step Deadbounce auth flow:
///   1. sign in with Firebase (email / Google / anonymous),
///   2. exchange the Firebase ID token for a Deadbounce JWT and persist it.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthFirebaseDataSource firebaseDataSource,
    required AuthRemoteDataSource remoteDataSource,
    required this._tokenStorage,
  })  : _firebase = firebaseDataSource,
        _remote = remoteDataSource;

  final AuthFirebaseDataSource _firebase;
  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final idToken =
        await _firebase.signInWithEmail(email: email, password: password);
    return _exchange(idToken, isAnonymous: false);
  }

  @override
  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final idToken =
        await _firebase.signUpWithEmail(email: email, password: password);
    return _exchange(idToken, isAnonymous: false);
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    final idToken = await _firebase.signInWithGoogle();
    return _exchange(idToken, isAnonymous: false);
  }

  @override
  Future<AuthUser> signInAsGuest() async {
    final idToken = await _firebase.signInAnonymously();
    return _exchange(idToken, isAnonymous: true);
  }

  @override
  Future<AuthUser?> restoreSession() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) return null;

    try {
      final user = await _remote.getCurrentUser();
      return user.toEntity();
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        // Stale/expired token — wipe it so the next launch goes straight
        // to login instead of retrying a dead session.
        await _tokenStorage.clear();
        return null;
      }
      // Network/server trouble: don't destroy the session, just report
      // no restorable user for now.
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    await _tokenStorage.clear();
    await _firebase.signOut();
  }

  Future<AuthUser> _exchange(
    String firebaseIdToken, {
    required bool isAnonymous,
  }) async {
    try {
      final session = await _remote.authenticateWithFirebase(firebaseIdToken);
      await _tokenStorage.saveAccessToken(session.accessToken);
      return session.toEntity(isAnonymous: isAnonymous);
    } on ApiException catch (e) {
      throw AuthFailure(e.message);
    }
  }
}
