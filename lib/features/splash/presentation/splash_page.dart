import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_dimens.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import 'widgets/boot_splash_scene.dart';

/// App boot loading screen: animated brand backdrop, rotating tips, and a
/// progress bar while [AuthCubit.restoreSession] resolves the session and
/// — for a signed-in account — the per-account database hydrates
/// (one-time snapshot restore). Routes to home or login when ready.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  /// Keep the brand on screen at least this long, even on a fast restore.
  final Future<void> _minimumHold =
      Future<void>.delayed(AppDurations.splash);
  bool _routing = false;
  bool _restoring = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().restoreSession();
  }

  Future<void> _onAuthenticated() async {
    if (_routing) return;
    _routing = true;

    // Capture the holder before any await so we never touch `context`
    // across an async gap.
    final holder = context.read<SessionHolder>();

    // Wait for _SessionScope to construct the per-account session, then for
    // its one-time restore + sync spin-up to finish.
    //
    // Polled rather than awaited because the session is created by an ancestor
    // widget's setState, which exposes no future. Two guards on what used to be
    // an unbounded 60Hz spin: a slower tick (the session lands in a frame or
    // two, so 16ms bought nothing but wasted wakeups on the boot path), and a
    // deadline — without one, a session that never arrives would spin forever,
    // burning battery behind a splash screen that would never move.
    const pollInterval = Duration(milliseconds: 50);
    final deadline = DateTime.now().add(const Duration(seconds: 15));

    var session = holder.maybeSession;
    while (session == null && mounted && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(pollInterval);
      session = holder.maybeSession;
    }
    if (!mounted) return;
    if (session == null) {
      // Nothing sane left to do here: the account graph never built, so every
      // authed screen would null-crash on `sessionDependencies`. Bounce back to
      // sign-in rather than sitting on the splash.
      AppLogger.talker
          .warning('[splash] session never materialized — returning to login');
      _routing = false;
      context.go(Routes.login);
      return;
    }

    setState(() => _restoring = true);
    await Future.wait([session.ready, _minimumHold]);
    if (mounted) context.go(Routes.home);
  }

  Future<void> _onUnauthenticated() async {
    if (_routing) return;
    _routing = true;
    await _minimumHold;
    if (mounted) context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _onAuthenticated();
        } else if (state is AuthUnauthenticated) {
          _onUnauthenticated();
        }
      },
      child: BootSplashScene(
        subtitle: _restoring ? 'Restoring your gunslinger…' : null,
      ),
    );
  }
}
