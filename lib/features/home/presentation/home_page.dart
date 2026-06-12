import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/widgets/db_button.dart';
import '../../../core/widgets/db_logo.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

/// Main menu: greeting, big PLAY action, placeholder tiles for settings
/// and profile (next phases), sign out.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _comingSoon(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what is coming soon, partner.')));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final effects = Theme.of(context).extension<AppEffects>()!;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) context.go(Routes.login);
      },
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final signingOut =
            state is AuthLoading && state.action == AuthAction.signOut;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient: effects.arenaGradient),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = constraints.maxWidth > 600
                      ? AppSpacing.xxl
                      : AppSpacing.lg;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                const DbLogo(size: 40, glow: false),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'HOWDY,',
                                        style: textTheme.labelSmall,
                                      ),
                                      Text(
                                        user?.label.toUpperCase() ??
                                            'GUNSLINGER',
                                        style: textTheme.titleLarge,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Sign out',
                                  onPressed: signingOut
                                      ? null
                                      : () =>
                                          context.read<AuthCubit>().signOut(),
                                  icon: signingOut
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.logout),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              'DEADBOUNCE',
                              style: textTheme.displayMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Bullets only bite after they bounce.',
                              style: textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            DbPrimaryButton(
                              label: 'PLAY',
                              icon: Icons.play_arrow_rounded,
                              onPressed: () => context.push(Routes.game),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _MenuTile(
                                    icon: Icons.settings_outlined,
                                    label: 'SETTINGS',
                                    onTap: () =>
                                        _comingSoon(context, 'Settings'),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: _MenuTile(
                                    icon: Icons.person_outline,
                                    label: 'PROFILE',
                                    onTap: () =>
                                        _comingSoon(context, 'Profile'),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (user?.isAnonymous ?? false)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
                                child: Text(
                                  'Riding as a guest — create an account to keep your progress.',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.amber300,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final effects = Theme.of(context).extension<AppEffects>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.lgAll,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: effects.glassDecoration,
          child: Column(
            children: [
              Icon(icon, color: AppColors.blue300, size: 28),
              const SizedBox(height: AppSpacing.xs),
              Text(label, style: textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}
