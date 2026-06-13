import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/widgets/animated_arena_background.dart';
import '../../../core/widgets/db_button.dart';
import '../../../core/widgets/db_logo.dart';
import '../../../core/widgets/utc_midnight_countdown.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../economy/presentation/cubit/wallet_cubit.dart';
import '../../streak/presentation/cubit/daily_reward_cubit.dart';
import '../../streak/presentation/widgets/daily_reward_sheet.dart';

/// Main menu: brand, Play, daily challenge entry with a reset countdown,
/// coin balance, streak indicator, and navigation to the meta screens —
/// over the living arena background. Surfaces the daily reward modal on
/// the first open of the day.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.sessionDependencies;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => WalletCubit(session.walletRepository),
        ),
        BlocProvider(
          create: (_) => DailyRewardCubit(session.loginStreakRepository)..load(),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  bool _rewardPrompted = false;

  void _maybePromptReward(DailyRewardState state) {
    if (_rewardPrompted) return;
    if (state is DailyRewardReady && state.streak.canClaimToday) {
      _rewardPrompted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDailyRewardSheet(context, context.read<DailyRewardCubit>());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) context.go(Routes.login);
      },
      child: BlocListener<DailyRewardCubit, DailyRewardState>(
        listener: (context, state) => _maybePromptReward(state),
        child: Scaffold(
          body: AnimatedArenaBackground(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final pad = constraints.maxWidth > 600
                      ? AppSpacing.xxl
                      : AppSpacing.lg;
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: pad),
                        child: Column(
                          children: [
                            const SizedBox(height: AppSpacing.sm),
                            const _TopBar(),
                            const Spacer(flex: 2),
                            const DbLogo(size: 96),
                            const SizedBox(height: AppSpacing.md),
                            Text('DEADBOUNCE',
                                style: textTheme.displayMedium,
                                textAlign: TextAlign.center),
                            const SizedBox(height: AppSpacing.xs),
                            Text('Bullets only bite after they bounce.',
                                style: textTheme.bodyMedium,
                                textAlign: TextAlign.center),
                            const Spacer(flex: 2),
                            DbPrimaryButton(
                              label: 'PLAY',
                              icon: Icons.play_arrow_rounded,
                              onPressed: () => context.push(Routes.game),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            const _DailyChallengeEntry(),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _NavTile(
                                    icon: Icons.leaderboard,
                                    label: 'BOARDS',
                                    onTap: () =>
                                        context.push(Routes.leaderboard),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: _NavTile(
                                    icon: Icons.emoji_events,
                                    label: 'AWARDS',
                                    onTap: () => context.push(Routes.awards),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(flex: 3),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        // Coins.
        _Pill(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.paid, color: AppColors.amber400, size: 18),
              const SizedBox(width: 6),
              BlocBuilder<WalletCubit, int>(
                builder: (context, coins) =>
                    Text('$coins', style: textTheme.titleSmall),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        // Streak.
        BlocBuilder<DailyRewardCubit, DailyRewardState>(
          builder: (context, state) {
            final streak = switch (state) {
              DailyRewardReady(:final streak) => streak.currentStreak,
              DailyRewardClaiming(:final streak) => streak.currentStreak,
              DailyRewardClaimed(:final streak) => streak.currentStreak,
              _ => 0,
            };
            return _Pill(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department,
                      color: streak > 0
                          ? AppColors.amber400
                          : AppColors.ink400,
                      size: 18),
                  const SizedBox(width: 6),
                  Text('$streak', style: textTheme.titleSmall),
                ],
              ),
            );
          },
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Profile',
          onPressed: () => context.push(Routes.profile),
          icon: const Icon(Icons.person_outline),
        ),
        IconButton(
          tooltip: 'Settings',
          onPressed: () => context.push(Routes.settings),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ink800.withValues(alpha: 0.7),
        borderRadius: AppRadii.pillAll,
        border: Border.all(color: AppColors.outlineFaint),
      ),
      child: child,
    );
  }
}

class _DailyChallengeEntry extends StatelessWidget {
  const _DailyChallengeEntry();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(Routes.dailyChallenge),
        borderRadius: AppRadii.lgAll,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.ink800.withValues(alpha: 0.85),
            borderRadius: AppRadii.lgAll,
            border: Border.all(color: AppColors.blue700),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.blue300, size: 26),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DAILY CHALLENGE', style: textTheme.titleSmall),
                    UtcMidnightCountdown(
                      prefix: 'Resets in ',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.ink300),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
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
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: effects.glassDecoration,
          child: Column(
            children: [
              Icon(icon, color: AppColors.amber300, size: 26),
              const SizedBox(height: AppSpacing.xs),
              Text(label, style: textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}
