import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/widgets/db_launch_button.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../economy/presentation/cubit/wallet_cubit.dart';
import '../../streak/presentation/cubit/daily_reward_cubit.dart';
import '../../streak/presentation/widgets/daily_reward_sheet.dart';
import '../domain/entities/home_summary.dart';
import 'cubit/home_cubit.dart';
import 'widgets/arena_home_backdrop.dart';
import 'widgets/daily_challenge_feature_card.dart';
import 'widgets/hero_orb_rig.dart';
import 'widgets/home_identity_bar.dart';
import 'widgets/home_stat_chips.dart';
import 'widgets/neon_wordmark.dart';

/// The living-arena main menu: personalized identity + stats, a neon-sign
/// wordmark, the hero launch orb, the daily-challenge event card, and the
/// meta-screen nav — over the cinematic arena backdrop, with a staggered
/// entrance. Surfaces the daily reward modal on the first open of the day.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.sessionDependencies;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WalletCubit(session.walletRepository)),
        BlocProvider(
          create: (_) => DailyRewardCubit(session.loginStreakRepository)..load(),
        ),
        BlocProvider(
          create: (_) => HomeCubit(
            profileRepository: session.profileRepository,
            statisticsRepository: session.statisticsRepository,
            leaderboardRepository: session.leaderboardRepository,
          )..load(),
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

  /// Entrance: fade + rise, staggered by [order].
  Widget _enter(Widget child, int order) => child
      .animate()
      .fadeIn(delay: (60 * order).ms, duration: 380.ms)
      .slideY(
        begin: 0.14,
        end: 0,
        delay: (60 * order).ms,
        duration: 380.ms,
        curve: Curves.easeOutCubic,
      );

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
          body: ArenaHomeBackdrop(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final pad = constraints.maxWidth > 600
                      ? AppSpacing.xxl
                      : AppSpacing.lg;
                  final orbD =
                      (constraints.maxHeight * 0.135).clamp(104.0, 132.0);
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: pad),
                        child: Column(
                          children: [
                            const SizedBox(height: AppSpacing.sm),
                            _enter(
                              BlocBuilder<HomeCubit, HomeState>(
                                builder: (context, state) => HomeIdentityBar(
                                  summary: _summaryOf(state),
                                ),
                              ),
                              0,
                            ),
                            const Spacer(flex: 2),
                            _enter(
                              NeonWordmark(style: textTheme.headlineLarge),
                              1,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            _enter(
                              Text('Bullets only bite after they bounce.',
                                  style: textTheme.bodyMedium,
                                  textAlign: TextAlign.center),
                              2,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _enter(
                              BlocBuilder<HomeCubit, HomeState>(
                                builder: (context, state) => HomeStatChips(
                                  summary: _summaryOf(state),
                                ),
                              ),
                              3,
                            ),
                            const Spacer(flex: 2),
                            _enter(
                              HeroOrbRig(
                                diameter: orbD,
                                child: DbLaunchButton(
                                  diameter: orbD,
                                  onPressed: () => context.push(Routes.game),
                                ),
                              ),
                              4,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _enter(const DailyChallengeFeatureCard(), 5),
                            const SizedBox(height: AppSpacing.sm),
                            _enter(
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
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: _NavTile(
                                      icon: Icons.emoji_events,
                                      label: 'AWARDS',
                                      onTap: () => context.push(Routes.awards),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: _NavTile(
                                      icon: Icons.query_stats,
                                      label: 'STATS',
                                      onTap: () =>
                                          context.push(Routes.statistics),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: _NavTile(
                                      icon: Icons.help_outline,
                                      label: 'GUIDE',
                                      onTap: () =>
                                          context.push(Routes.howToPlay),
                                    ),
                                  ),
                                ],
                              ),
                              6,
                            ),
                            const Spacer(flex: 2),
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

  HomeSummary _summaryOf(HomeState state) =>
      state is HomeLoaded ? state.summary : const HomeSummary.empty();
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
              Icon(icon, color: AppColors.amber300, size: 24),
              const SizedBox(height: AppSpacing.xxs),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, style: textTheme.labelSmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
