import 'package:deadbounce_flutter_app/core/logging/app_logger.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Composes the two-step Deadbounce auth flow:
///   1. sign in with Firebase (email / Google / anonymous),
///   2. exchange the Firebase ID token for a Deadbounce JWT and persist it,
///      caching the resulting identity so the session restores OFFLINE.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthFirebaseDataSource firebaseDataSource,
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required this._tokenStorage,
  })  : _firebase = firebaseDataSource,
        _remote = remoteDataSource,
        _local = localDataSource;

  final AuthFirebaseDataSource _firebase;
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final TokenStorage _tokenStorage;

  /// Firebase error codes that mean the identity is permanently gone — a
  /// signal to end the local session rather than retry.
  static const Set<String> _deadIdentityCodes = {
    'user-disabled',
    'user-not-found',
    'user-token-expired',
    'invalid-user-token',
    'user-mismatch',
  };

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

    // Offline-first: trust the locally cached identity. NO network call on the
    // cold-start path, so the user stays logged in with zero connectivity.
    final cached = await _local.readUser();
    if (cached != null) return cached;

    // Safety net for tokens stored before this cache existed: rebuild a
    // minimal identity from Firebase's persisted user (offline-safe). The next
    // online refresh replaces it with the authoritative backend identity.
    final firebaseIdentity = _firebase.firebaseIdentity;
    if (firebaseIdentity != null) {
      await _local.cacheUser(firebaseIdentity);
      return firebaseIdentity;
    }

    // A token with no identity anywhere — can't safely resume.
    AppLogger.talker.warning('[auth] token present but no identity to restore');
    return null;
  }

  @override
  Future<SessionRefreshOutcome> refreshSessionToken() async {
    // No persisted Firebase user *right now* isn't proof of a dead account
    // (Firebase rehydrates currentUser asynchronously) — treat as retry-later.
    if (!_firebase.hasCurrentUser) return SessionRefreshOutcome.unavailable;

    final String? idToken;
    try {
      idToken = await _firebase.currentUserIdToken(forceRefresh: true);
    } on FirebaseAuthException catch (e) {
      AppLogger.talker.warning('[auth] id-token refresh failed: ${e.code}');
      return _deadIdentityCodes.contains(e.code)
          ? SessionRefreshOutcome.identityRejected
          : SessionRefreshOutcome.unavailable;
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[auth] id-token refresh error');
      return SessionRefreshOutcome.unavailable;
    }
    if (idToken == null) return SessionRefreshOutcome.unavailable;

    try {
      final session = await _remote.authenticateWithFirebase(idToken);
      await _tokenStorage.saveAccessToken(session.accessToken);
      await _local
          .cacheUser(session.toEntity(isAnonymous: _firebase.isCurrentUserAnonymous));
      AppLogger.talker.info('[auth] session token refreshed');
      return SessionRefreshOutcome.refreshed;
    } on ApiException catch (e) {
      AppLogger.talker.warning('[auth] token re-exchange failed: ${e.message}');
      // The backend refused the (valid) Firebase token → identity is gone.
      // Anything else (offline, 5xx) is transient.
      return (e.statusCode == 401 || e.statusCode == 403)
          ? SessionRefreshOutcome.identityRejected
          : SessionRefreshOutcome.unavailable;
    }
  }

  @override
  Future<void> signOut() async {
    await _tokenStorage.clear();
    await _local.clear();
    await _firebase.signOut();
  }

  Future<AuthUser> _exchange(
    String firebaseIdToken, {
    required bool isAnonymous,
  }) async {
    try {
      final session = await _remote.authenticateWithFirebase(firebaseIdToken);
      await _tokenStorage.saveAccessToken(session.accessToken);
      final user = session.toEntity(isAnonymous: isAnonymous);
      await _local.cacheUser(user);
      AppLogger.talker.info('[auth] session established (anon=$isAnonymous)');
      return user;
    } on ApiException catch (e) {
      AppLogger.talker.warning('[auth] firebase exchange failed: ${e.message}');
      throw AuthFailure(e.message);
    }
  }
}
