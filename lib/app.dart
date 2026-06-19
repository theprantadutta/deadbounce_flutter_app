import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/session_dependencies.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_firebase_datasource.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/restore_session.dart';
import 'features/auth/domain/usecases/sign_in_as_guest.dart';
import 'features/auth/domain/usecases/sign_in_with_email.dart';
import 'features/auth/domain/usecases/refresh_session.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up_with_email.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

/// Composition root. Two stages:
///  - app-wide graph (auth, network) built here once;
///  - [SessionDependencies] (per-account Drift DB + sync engine +
///    game-data repositories) built when auth lands on a Firebase uid and
///    torn down on sign-out — managed by [_SessionScope].
class DeadbounceApp extends StatefulWidget {
  const DeadbounceApp({super.key});

  @override
  State<DeadbounceApp> createState() => _DeadbounceAppState();
}

class _DeadbounceAppState extends State<DeadbounceApp> {
  late final TokenStorage _tokenStorage = TokenStorage();
  late final ApiClient _apiClient = ApiClient(_tokenStorage);
  late final AuthRepository _authRepository = _buildAuthRepository();
  late final _router = buildRouter();

  AuthRepository _buildAuthRepository() {
    final repo = AuthRepositoryImpl(
      firebaseDataSource: AuthFirebaseDataSource(),
      remoteDataSource: AuthRemoteDataSource(_apiClient),
      localDataSource: AuthLocalDataSource(),
      tokenStorage: _tokenStorage,
    );
    // Let the API client self-heal a 401 by silently re-exchanging the
    // Firebase identity for a fresh JWT (covers the expired-token case).
    _apiClient.attachSessionRefresher(
      () async =>
          await repo.refreshSessionToken() == SessionRefreshOutcome.refreshed,
    );
    return repo;
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authRepository,
      child: RepositoryProvider.value(
        value: _apiClient,
        child: BlocProvider(
          create: (_) => AuthCubit(
            signInWithEmail: SignInWithEmail(_authRepository),
            signUpWithEmail: SignUpWithEmail(_authRepository),
            signInWithGoogle: SignInWithGoogle(_authRepository),
            signInAsGuest: SignInAsGuest(_authRepository),
            restoreSession: RestoreSession(_authRepository),
            refreshSession: RefreshSession(_authRepository),
            signOut: SignOut(_authRepository),
          ),
          child: _SessionScope(
            apiClient: _apiClient,
            child: MaterialApp.router(
              title: 'Deadbounce',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.dark,
              routerConfig: _router,
            ),
          ),
        ),
      ),
    );
  }
}

/// Builds/tears down [SessionDependencies] in lockstep with auth state
/// and provides it (nullable) to the subtree. Pages behind the auth wall
/// read it with `context.sessionDependencies`.
class _SessionScope extends StatefulWidget {
  const _SessionScope({required this.apiClient, required this.child});

  final ApiClient apiClient;
  final Widget child;

  @override
  State<_SessionScope> createState() => _SessionScopeState();
}

class _SessionScopeState extends State<_SessionScope> {
  SessionDependencies? _session;
  String? _sessionUid;

  void _sync(AuthState state) {
    final firebaseUid = FirebaseAuth.instance.currentUser?.uid;

    if (state is AuthAuthenticated && firebaseUid != null) {
      if (_sessionUid == firebaseUid) return;
      final old = _session;
      final fresh = SessionDependencies.create(
        firebaseUid: firebaseUid,
        apiClient: widget.apiClient,
      );
      setState(() {
        _session = fresh;
        _sessionUid = firebaseUid;
      });
      old?.dispose();
      // Restore-if-needed + sync engine spin-up, off the build path.
      fresh.start();
    } else if (state is AuthUnauthenticated && _session != null) {
      final old = _session;
      setState(() {
        _session = null;
        _sessionUid = null;
      });
      old?.dispose();
    }
  }

  @override
  void dispose() {
    _session?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (_, state) => _sync(state),
      child: RepositoryProvider<SessionHolder>.value(
        value: SessionHolder(() => _session),
        child: widget.child,
      ),
    );
  }
}

/// Indirection so providers don't need rebuilding when the session
/// appears — pages always read the CURRENT session through the getter.
class SessionHolder {
  const SessionHolder(this._get);

  final SessionDependencies? Function() _get;

  SessionDependencies? get maybeSession => _get();

  /// For pages behind the auth wall, where a session must exist.
  SessionDependencies get session {
    final s = _get();
    assert(s != null, 'SessionDependencies read before sign-in completed');
    return s!;
  }
}

extension SessionContext on BuildContext {
  SessionDependencies get sessionDependencies =>
      read<SessionHolder>().session;
}
