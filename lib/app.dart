import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/ads/ad_service.dart';
import 'core/ads/google_ad_service.dart';
import 'core/analytics/analytics.dart';
import 'core/logging/app_logger.dart';
import 'core/audio/music_manager.dart';
import 'core/di/session_dependencies.dart';
import 'core/legal/legal_consent_store.dart';
import 'core/network/api_client.dart';
import 'core/review/app_review_service.dart';
import 'core/review/review_prompt_store.dart';
import 'core/router/app_router.dart';
import 'features/onboarding/onboarding_store.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_firebase_datasource.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/link_with_google.dart';
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
  const DeadbounceApp({
    super.key,
    required this.legalConsent,
    required this.reviewPromptStore,
    required this.onboarding,
  });

  /// Device-level legal-consent record (loaded in main before runApp), used by
  /// the router to gate the first launch behind the Privacy Policy + Terms.
  final LegalConsentStore legalConsent;

  /// Device-level throttle backing the in-app review prompt.
  final ReviewPromptStore reviewPromptStore;

  /// Device-level "seen the walkthrough" flag, used by the router to route
  /// first-time users into the interactive tutorial after sign-in.
  final OnboardingStore onboarding;

  @override
  State<DeadbounceApp> createState() => _DeadbounceAppState();
}

class _DeadbounceAppState extends State<DeadbounceApp>
    with WidgetsBindingObserver {
  late final TokenStorage _tokenStorage = TokenStorage();
  late final ApiClient _apiClient = ApiClient(_tokenStorage);
  late final AuthRepository _authRepository = _buildAuthRepository();
  late final AppReviewService _reviewService =
      InAppReviewService(widget.reviewPromptStore);

  /// App-wide, not per-account: the SDK and the consent state belong to the
  /// device, and tearing it down on sign-out would re-prompt for consent.
  late final AdService _adService = GoogleAdService();

  // Owned here (not in a BlocProvider's create:) so the router can observe it
  // for its auth redirect; closed in dispose().
  late final AuthCubit _authCubit = AuthCubit(
    signInWithEmail: SignInWithEmail(_authRepository),
    signUpWithEmail: SignUpWithEmail(_authRepository),
    signInWithGoogle: SignInWithGoogle(_authRepository),
    signInAsGuest: SignInAsGuest(_authRepository),
    linkWithGoogle: LinkWithGoogle(_authRepository),
    restoreSession: RestoreSession(_authRepository),
    refreshSession: RefreshSession(_authRepository),
    signOut: SignOut(_authRepository),
  );
  late final _router = buildRouter(
    authCubit: _authCubit,
    legalConsent: widget.legalConsent,
    onboarding: widget.onboarding,
  );

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initializes the SDK and resolves UMP consent. Fire-and-forget: nothing
    // in the boot path may wait on an ad network.
    unawaited(_adService.start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_adService.dispose());
    _authCubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Don't let the background music play while the app isn't on screen.
    switch (state) {
      case AppLifecycleState.resumed:
        MusicManager.instance.handleAppResumed();
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        MusicManager.instance.handleAppPaused();
      case AppLifecycleState.inactive:
        // Transient (system dialogs, app-switcher peek) — leave music alone.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authRepository,
      child: RepositoryProvider.value(
        value: _apiClient,
        child: RepositoryProvider<AppReviewService>.value(
          value: _reviewService,
          child: RepositoryProvider<AdService>.value(
            value: _adService,
          child: BlocProvider.value(
            value: _authCubit,
            child: _SessionScope(
              apiClient: _apiClient,
              adService: _adService,
              child: MaterialApp.router(
                title: 'Deadbounce',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.dark,
                routerConfig: _router,
              ),
            ),
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
  const _SessionScope({
    required this.apiClient,
    required this.adService,
    required this.child,
  });

  final ApiClient apiClient;
  final AdService adService;
  final Widget child;

  @override
  State<_SessionScope> createState() => _SessionScopeState();
}

class _SessionScopeState extends State<_SessionScope> {
  SessionDependencies? _session;
  String? _sessionUid;
  StreamSubscription<Set<String>>? _entitlementSub;

  /// Keeps the ad gate in step with what the player owns, so a just-completed
  /// Remove Ads purchase silences banners and interstitials immediately rather
  /// than after a restart.
  void _watchEntitlements(SessionDependencies session) {
    _entitlementSub?.cancel();
    _entitlementSub = session.storeRepository.watchEntitlements().listen(
      (owned) => widget.adService.setAdsRemoved(owned.contains('no_ads')),
      onError: (Object e, StackTrace st) =>
          AppLogger.talker.handle(e, st, '[ads] entitlement watch failed'),
    );
  }

  void _sync(AuthState state) {
    final firebaseUid = FirebaseAuth.instance.currentUser?.uid;

    // Identity for analytics: the BACKEND user id (already pseudonymous),
    // never the Firebase uid or an email. Guests are flagged so their
    // retention can be compared against linked accounts — the number that
    // justifies Phase 1.
    if (state is AuthAuthenticated) {
      Analytics.identify(state.user.id);
      Analytics.setPlayerProperties(isGuest: state.user.isAnonymous);
    } else if (state is AuthUnauthenticated) {
      Analytics.identify(null);
    }

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
      _watchEntitlements(fresh);
      // Restore-if-needed + sync engine spin-up, off the build path.
      fresh.start();
    } else if (state is AuthUnauthenticated && _session != null) {
      _entitlementSub?.cancel();
      _entitlementSub = null;
      // Signed out: assume ads are ON again until the next account says
      // otherwise, so one player's purchase can't silence ads for another.
      widget.adService.setAdsRemoved(false);
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
    _entitlementSub?.cancel();
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
  SessionDependencies get sessionDependencies => read<SessionHolder>().session;
}
