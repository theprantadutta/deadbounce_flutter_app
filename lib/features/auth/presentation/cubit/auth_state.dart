part of 'auth_cubit.dart';

/// Which interactive flow is in flight — lets each button render its own
/// spinner instead of one global overlay.
enum AuthAction { email, google, guest, signUp, restore, signOut }

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// App just launched, nothing decided yet.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// An auth flow is running.
final class AuthLoading extends AuthState {
  const AuthLoading(this.action);

  final AuthAction action;

  @override
  List<Object?> get props => [action];
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final AuthUser user;

  @override
  List<Object?> get props => [user];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// A flow failed with a user-presentable message. UI shows it (snackbar)
/// and stays where it is.
final class AuthError extends AuthState {
  const AuthError(this.message, {required this.action});

  final String message;
  final AuthAction action;

  @override
  List<Object?> get props => [message, action];
}
