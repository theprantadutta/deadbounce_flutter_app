import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_effects.dart';
import '../../../economy/presentation/cubit/wallet_cubit.dart';
import '../../../streak/presentation/cubit/daily_reward_cubit.dart';
import '../../domain/entities/home_summary.dart';

/// Top identity strip: avatar + name + tier on the left; coins, streak, and
/// profile/settings on the right. Replaces the old generic top bar.
class HomeIdentityBar extends StatelessWidget {
  const HomeIdentityBar({super.key, required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final effects = Theme.of(context).extension<AppEffects>()!;

    return Row(
      children: [
        // Avatar badge.
        Container(
          width: 42,
          height: 42,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: effects.brandGradient,
            shape: BoxShape.circle,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.ink900,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.amber300, size: 22),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Name + tier.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                summary.displayName,
                style: textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                summary.tier.label,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.amber300,
                  letterSpacing: 1.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        // Coins.
        _Pill(
          icon: Icons.paid,
          iconColor: AppColors.amber400,
          child: BlocBuilder<WalletCubit, int>(
            builder: (context, coins) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Text('$coins',
                  key: ValueKey(coins), style: textTheme.titleSmall),
            ),
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
              icon: Icons.local_fire_department,
              iconColor: streak > 0 ? AppColors.amber400 : AppColors.ink400,
              child: Text('$streak', style: textTheme.titleSmall),
            );
          },
        ),
        IconButton(
          tooltip: 'Profile',
          visualDensity: VisualDensity.compact,
          onPressed: () => context.push(Routes.profile),
          icon: const Icon(Icons.person_outline, size: 22),
        ),
        IconButton(
          tooltip: 'Settings',
          visualDensity: VisualDensity.compact,
          onPressed: () => context.push(Routes.settings),
          icon: const Icon(Icons.settings_outlined, size: 22),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.iconColor, required this.child});

  final IconData icon;
  final Color iconColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.ink800.withValues(alpha: 0.7),
        borderRadius: AppRadii.pillAll,
        border: Border.all(color: AppColors.outlineFaint),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 6),
          child,
        ],
      ),
    );
  }
}
