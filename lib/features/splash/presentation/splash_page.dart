import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/db_loading_scene.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

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

  static const _tips = [
    'Bullets only bite after they bounce.',
    'Wardens fear the third bounce.',
    'Dash to dodge — aim to win.',
    'A dampened wall is a dead wall. Kill the turret.',
    'Every bounce: more damage, more speed.',
  ];

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
    var session = holder.maybeSession;
    while (session == null && mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 16));
      session = holder.maybeSession;
    }
    if (!mounted || session == null) return;

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
      child: DbLoadingScene(
        title: 'DEADBOUNCE',
        subtitle: _restoring ? 'Restoring your gunslinger…' : null,
        tips: _tips,
      ),
    );
  }
}
