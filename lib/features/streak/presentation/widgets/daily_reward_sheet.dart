import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/db_button.dart';
import '../../domain/login_rewards.dart';
import '../cubit/daily_reward_cubit.dart';

/// Shows the daily-draw claim modal. Provide an already-loaded
/// [DailyRewardCubit].
Future<void> showDailyRewardSheet(
  BuildContext context,
  DailyRewardCubit cubit,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: const _DailyRewardSheet(),
    ),
  );
}

class _DailyRewardSheet extends StatelessWidget {
  const _DailyRewardSheet();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<DailyRewardCubit, DailyRewardState>(
      builder: (context, state) {
        final claimed = state is DailyRewardClaimed;
        final reward = switch (state) {
          DailyRewardReady(:final streak) => streak,
          DailyRewardClaiming(:final streak) => streak,
          DailyRewardClaimed(:final streak) => streak,
          _ => null,
        };
        final activeDay = reward?.todayCalendarDay ?? 1;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.ink800,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.outlineFaint)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.ink500,
                    borderRadius: AppRadii.pillAll,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('DAILY DRAW', style: textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  claimed
                      ? 'Pleasure doing business.'
                      : 'Step up and collect, partner.',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                _RewardCalendar(activeDay: activeDay, claimed: claimed),
                const SizedBox(height: AppSpacing.xl),
                if (claimed)
                  _ClaimedBanner(
                    coins: (state).result.coinsAwarded,
                    onClose: () => Navigator.of(context).pop(),
                  )
                else
                  DbPrimaryButton(
                    label: reward == null
                        ? 'CLAIM'
                        : 'CLAIM ${reward.todayReward} COINS',
                    icon: Icons.paid,
                    loading: state is DailyRewardClaiming,
                    onPressed: (reward?.canClaimToday ?? false)
                        ? () => context.read<DailyRewardCubit>().claim()
                        : null,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RewardCalendar extends StatelessWidget {
  const _RewardCalendar({required this.activeDay, required this.claimed});

  final int activeDay;
  final bool claimed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      alignment: WrapAlignment.center,
      children: [
        for (var day = 1; day <= LoginRewards.cycleLength; day++)
          _DayChip(
            day: day,
            coins: LoginRewards.coinsForDay(day),
            isToday: day == activeDay,
            isClaimedToday: claimed && day == activeDay,
            isBig: day == LoginRewards.cycleLength,
            textTheme: textTheme,
          ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.coins,
    required this.isToday,
    required this.isClaimedToday,
    required this.isBig,
    required this.textTheme,
  });

  final int day;
  final int coins;
  final bool isToday;
  final bool isClaimedToday;
  final bool isBig;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final accent = isBig ? AppColors.amber400 : AppColors.blue400;
    final highlighted = isToday;
    return Container(
      width: 78,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.ink600 : AppColors.ink700,
        borderRadius: AppRadii.mdAll,
        border: Border.all(
          color: highlighted ? accent : AppColors.outlineFaint,
          width: highlighted ? 1.6 : 1,
        ),
        boxShadow: highlighted
            ? [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 14)]
            : null,
      ),
      child: Column(
        children: [
          Text('DAY $day', style: textTheme.labelSmall),
          const SizedBox(height: 4),
          Icon(
            isClaimedToday ? Icons.check_circle : Icons.paid,
            color: isClaimedToday ? AppColors.success : accent,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            '$coins',
            style: textTheme.titleSmall?.copyWith(color: accent),
          ),
        ],
      ),
    );
  }
}

class _ClaimedBanner extends StatelessWidget {
  const _ClaimedBanner({required this.coins, required this.onClose});

  final int coins;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: coins.toDouble()),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.paid, color: AppColors.amber400, size: 26),
              const SizedBox(width: AppSpacing.xs),
              Text('+${value.round()}',
                  style: textTheme.headlineMedium
                      ?.copyWith(color: AppColors.amber300)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        DbPrimaryButton(label: 'RIDE ON', onPressed: onClose),
      ],
    );
  }
}
