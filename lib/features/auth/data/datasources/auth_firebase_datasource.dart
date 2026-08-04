import 'package:deadbounce_flutter_app/core/logging/app_logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/config/app_config.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Wraps the Firebase client SDK sign-in flows. Every provider funnels to
/// the same outcome: a signed-in [FirebaseAuth] user whose ID token the
/// remote datasource exchanges for a Deadbounce JWT.
class AuthFirebaseDataSource {
  AuthFirebaseDataSource({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  bool _googleInitialized = false;

  bool get isCurrentUserAnonymous =>
      _firebaseAuth.currentUser?.isAnonymous ?? false;

  /// True when Firebase still holds a persisted user (survives offline cold
  /// starts) — i.e. there is an identity we can silently re-exchange for a
  /// fresh Deadbounce JWT once back online.
  bool get hasCurrentUser => _firebaseAuth.currentUser != null;

  /// A fresh Firebase ID token for the CURRENT persisted user, or null if
  /// there is none. [forceRefresh] re-mints it (needed when the cached one
  /// may be stale). Network is required only when actually refreshing.
  Future<String?> currentUserIdToken({bool forceRefresh = true}) =>
      _firebaseAuth.currentUser?.getIdToken(forceRefresh) ??
      Future<String?>.value();

  /// A minimal identity rebuilt from Firebase's persisted user (offline-safe),
  /// or null if there is none. Used only as a fallback when no backend identity
  /// is cached yet — note [AuthUser.id] is the Firebase uid here, replaced by
  /// the authoritative backend id on the next online refresh.
  AuthUser? get firebaseIdentity {
    final u = _firebaseAuth.currentUser;
    if (u == null) return null;
    return AuthUser(
      id: u.uid,
      isAnonymous: u.isAnonymous,
      email: u.email,
      displayName: u.displayName,
      photoUrl: u.photoURL,
    );
  }

  Future<String> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      AppLogger.talker.info('[auth] email sign-in succeeded');
      return _idTokenOf(credential);
    } on FirebaseAuthException catch (e) {
      AppLogger.talker.warning('[auth] email sign-in failed: ${e.code}');
      throw AuthFailure(_friendlyMessage(e));
    }
  }

  Future<String> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      AppLogger.talker.info('[auth] email sign-up succeeded');
      return _idTokenOf(credential);
    } on FirebaseAuthException catch (e) {
      AppLogger.talker.warning('[auth] email sign-up failed: ${e.code}');
      throw AuthFailure(_friendlyMessage(e));
    }
  }

  /// Runs the interactive Google picker and returns a Firebase credential.
  /// Shared by [signInWithGoogle] and [linkWithGoogle] so both flows behave
  /// identically (same init, same cancellation semantics).
  Future<AuthCredential> _googleCredential() async {
    if (!_googleInitialized) {
      // serverClientId (the WEB OAuth client id) is what makes Google
      // return an ID token Firebase can verify. On Android it defaults
      // to the default_web_client_id generated from google-services.json,
      // so the dart-define override is optional there.
      await _googleSignIn.initialize(
        serverClientId: AppConfig.googleServerClientId.isEmpty
            ? null
            : AppConfig.googleServerClientId,
      );
      _googleInitialized = true;
    }

    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw AuthFailure('Google did not return an ID token.');
    }
    return GoogleAuthProvider.credential(idToken: idToken);
  }

  /// Maps a [GoogleSignInException] to our own failure types. Cancellation is
  /// a silent no-op everywhere, never an error.
  Never _throwGoogleFailure(GoogleSignInException e, String flow) {
    if (e.code == GoogleSignInExceptionCode.canceled) {
      AppLogger.talker.debug('[auth] google $flow canceled by user');
      throw const AuthCancelled();
    }
    AppLogger.talker.warning('[auth] google $flow failed: ${e.code.name}');
    throw AuthFailure('Google sign-in failed: ${e.description ?? e.code.name}');
  }

  Future<String> signInWithGoogle() async {
    try {
      final credential = await _googleCredential();
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      AppLogger.talker.info('[auth] google sign-in succeeded');
      return _idTokenOf(userCredential);
    } on GoogleSignInException catch (e) {
      _throwGoogleFailure(e, 'sign-in');
    } on FirebaseAuthException catch (e) {
      AppLogger.talker.warning('[auth] google sign-in failed: ${e.code}');
      throw AuthFailure(_friendlyMessage(e));
    }
  }

  /// Upgrades the CURRENT anonymous user into a permanent Google account.
  ///
  /// Uses `linkWithCredential`, which **preserves the Firebase UID** — that is
  /// the whole reason this is safe: the per-account Drift file is named
  /// `deadbounce_<uid>.sqlite`, so every run, coin and unlock survives the
  /// upgrade with no migration at all.
  ///
  /// Throws [AccountLinkConflict] when the chosen Google account is already
  /// attached to a different Deadbounce account — the one case we cannot
  /// resolve silently, because two sets of progress exist and only the user
  /// can decide which to keep.
  Future<String> linkWithGoogle() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw AuthFailure('You need to be signed in before linking.');
    }
    if (!user.isAnonymous) {
      throw AuthFailure('This account is already linked.');
    }

    try {
      final credential = await _googleCredential();
      final linked = await user.linkWithCredential(credential);
      AppLogger.talker.info('[auth] google link succeeded (uid preserved)');
      // Force a refresh: the cached token predates the link, so its claims
      // would still describe an anonymous user when the backend inspects them.
      return _idTokenOf(linked, forceRefresh: true);
    } on GoogleSignInException catch (e) {
      _throwGoogleFailure(e, 'link');
    } on FirebaseAuthException catch (e) {
      AppLogger.talker.warning('[auth] google link failed: ${e.code}');
      switch (e.code) {
        // The Google account already backs another Firebase user. Firebase
        // reports this two ways depending on platform/settings.
        case 'credential-already-in-use':
        case 'email-already-in-use':
        case 'account-exists-with-different-credential':
          throw AccountLinkConflict(email: e.email);
        case 'provider-already-linked':
          throw AuthFailure('This account is already linked to Google.');
        default:
          throw AuthFailure(_friendlyMessage(e));
      }
    }
  }

  Future<String> signInAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      AppLogger.talker.info('[auth] anonymous sign-in succeeded');
      return _idTokenOf(credential);
    } on FirebaseAuthException catch (e) {
      AppLogger.talker.warning('[auth] anonymous sign-in failed: ${e.code}');
      throw AuthFailure(_friendlyMessage(e));
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String> _idTokenOf(
    UserCredential credential, {
    bool forceRefresh = false,
  }) async {
    final token = await credential.user?.getIdToken(forceRefresh);
    if (token == null) {
      throw AuthFailure('Firebase did not return an ID token.');
    }
    return token;
  }

  String _friendlyMessage(FirebaseAuthException e) => switch (e.code) {
        'invalid-email' => 'That email address looks invalid.',
        'user-disabled' => 'This account has been disabled.',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'Email or password is incorrect.',
        'email-already-in-use' => 'An account already exists for that email.',
        'weak-password' => 'Password is too weak — use at least 6 characters.',
        'operation-not-allowed' =>
          'This sign-in method is not enabled. Contact support.',
        'too-many-requests' =>
          'Too many attempts. Wait a moment and try again.',
        'network-request-failed' => 'Network error. Check your connection.',
        _ => e.message ?? 'Authentication failed (${e.code}).',
      };
}
