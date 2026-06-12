import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
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
    required this._restoreSession,
    required this._signOut,
  }) : super(const AuthInitial());

  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignInAsGuest _signInAsGuest;
  final RestoreSession _restoreSession;
  final SignOut _signOut;

  /// Called from the splash screen: try to resume the stored session.
  Future<void> restoreSession() async {
    emit(const AuthLoading(AuthAction.restore));
    try {
      final user = await _restoreSession();
      emit(user != null ? AuthAuthenticated(user) : const AuthUnauthenticated());
    } catch (_) {
      emit(const AuthUnauthenticated());
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
    } catch (_) {
      emit(AuthError('Something went wrong. Please try again.', action: action));
      emit(const AuthUnauthenticated());
    }
  }
}
