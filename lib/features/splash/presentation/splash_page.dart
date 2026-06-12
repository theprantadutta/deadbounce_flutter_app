import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/widgets/db_logo.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

/// Brand splash: logo lockup fades in while [AuthCubit.restoreSession]
/// decides whether the stored session is still valid, then routes to
/// home or login.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.slow,
  )..forward();

  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);

  /// Keep the brand on screen at least this long, even on a fast restore.
  late final Future<void> _minimumHold =
      Future<void>.delayed(AppDurations.splash);

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().restoreSession();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _route(String location) async {
    await _minimumHold;
    if (mounted) context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    final effects = Theme.of(context).extension<AppEffects>()!;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _route(Routes.home);
        } else if (state is AuthUnauthenticated) {
          _route(Routes.login);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: effects.arenaGradient),
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final logoSize =
                      (constraints.maxWidth * 0.24).clamp(72.0, 120.0);
                  return DbLogoLockup(logoSize: logoSize);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
