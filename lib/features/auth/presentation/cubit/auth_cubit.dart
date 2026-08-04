import 'dart:async';

import 'package:deadbounce_flutter_app/core/logging/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/account_link_result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/link_with_google.dart';
import '../../domain/usecases/refresh_session.dart';
import '../../domain/usecases/restore_session.dart';
import '../../domain/usecases/sign_in_as_guest.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this._signInWithEmail,
    required this._signUpWithEmail,
    required this._signInWithGoogle,
    required this._signInAsGuest,
    required this._linkWithGoogle,
    required this._restoreSession,
    required this._refreshSession,
    required this._signOut,
  }) : super(const AuthInitial());

  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignInAsGuest _signInAsGuest;
  final LinkWithGoogle _linkWithGoogle;
  final RestoreSession _restoreSession;
  final RefreshSession _refreshSession;
  final SignOut _signOut;

  /// Called from the splash screen: resume the stored session offline-first
  /// (no network), then reconcile with the server in the background.
  Future<void> restoreSession() async {
    emit(const AuthLoading(AuthAction.restore));
    try {
      final user = await _restoreSession();
      if (user == null) {
        emit(const AuthUnauthenticated());
        return;
      }
      emit(AuthAuthenticated(user));
      unawaited(_reconcileSession());
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[auth] restoreSession failed');
      emit(const AuthUnauthenticated());
    }
  }

  /// Background, non-blocking: silently refresh the JWT once connectivity
  /// allows. Only signs out when the server EXPLICITLY rejects the identity
  /// (account disabled/deleted) — never on a mere network/offline error, so an
  /// offline player is never kicked out.
  Future<void> _reconcileSession() async {
    final outcome = await _refreshSession();
    if (outcome == SessionRefreshOutcome.identityRejected) {
      AppLogger.talker.warning('[auth] session rejected by server — signing out');
      await signOut();
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _run(
        AuthAction.email,
        () => _signInWithEmail(email: email, password: password),
      );

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) =>
      _run(
        AuthAction.signUp,
        () => _signUpWithEmail(email: email, password: password),
      );

  Future<void> signInWithGoogle() =>
      _run(AuthAction.google, _signInWithGoogle.call);

  Future<void> signInAsGuest() => _run(AuthAction.guest, _signInAsGuest.call);

  /// Upgrades the signed-in guest to a permanent Google account.
  ///
  /// Deliberately does NOT go through [_run]: that helper emits
  /// [AuthUnauthenticated] on failure, which for a link would throw the player
  /// out of a session they never left. Here every failure path restores the
  /// exact state we started in — the guest keeps their session and their
  /// progress no matter what goes wrong.
  Future<AccountLinkResult> linkWithGoogle() async {
    final previous = state;
    if (previous is! AuthAuthenticated) {
      return const AccountLinkFailed('You need to be signed in first.');
    }

    emit(const AuthLoading(AuthAction.link));
    try {
      final user = await _linkWithGoogle();
      emit(AuthAuthenticated(user));
      return AccountLinkSuccess(user);
    } on AuthCancelled {
      emit(previous);
      return const AccountLinkCancelled();
    } on AccountLinkConflict catch (e) {
      emit(previous);
      return AccountLinkCredentialInUse(email: e.email);
    } on AuthFailure catch (e) {
      emit(previous);
      return AccountLinkFailed(e.message);
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[auth] account link failed');
      emit(previous);
      return const AccountLinkFailed(
        'Could not link your account. Please try again.',
      );
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading(AuthAction.signOut));
    try {
      await _signOut();
    } finally {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _run(AuthAction action, Future<AuthUser> Function() flow) async {
    emit(AuthLoading(action));
    try {
      final user = await flow();
      emit(AuthAuthenticated(user));
    } on AuthCancelled {
      // User backed out (e.g. dismissed the Google picker) — not an error.
      emit(const AuthUnauthenticated());
    } on AuthFailure catch (e) {
      emit(AuthError(e.message, action: action));
      emit(const AuthUnauthenticated());
    } catch (e, st) {
      AppLogger.talker.handle(e, st, '[auth] sign-in flow failed');
      emit(AuthError('Something went wrong. Please try again.', action: action));
      emit(const AuthUnauthenticated());
    }
  }
}
