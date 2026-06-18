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

/// Top identity strip as a player HUD: a tappable avatar (with the login
/// streak fused on as an "on fire" badge) + name + tier on the left, a glowing
/// amber bounty/coins readout on the right, then settings.
class HomeIdentityBar extends StatelessWidget {
  const HomeIdentityBar({super.key, required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final effects = Theme.of(context).extension<AppEffects>()!;

    return Row(
      children: [
        // Tappable player card → Profile.
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push(Routes.profile),
              borderRadius: AppRadii.lgAll,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  children: [
                    BlocBuilder<DailyRewardCubit, DailyRewardState>(
                      builder: (context, state) => _AvatarBadge(
                        gradient: effects.brandGradient,
                        streak: _streakOf(state),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
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
                          Row(
                            children: [
                              const Icon(Icons.military_tech,
                                  size: 13, color: AppColors.amber300),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  summary.tier.label,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: AppColors.amber300,
                                    letterSpacing: 1.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        const _CoinReadout(),
        IconButton(
          tooltip: 'Settings',
          visualDensity: VisualDensity.compact,
          onPressed: () => context.push(Routes.settings),
          icon: const Icon(Icons.settings_outlined, size: 22),
        ),
      ],
    );
  }

  static int _streakOf(DailyRewardState state) => switch (state) {
        DailyRewardReady(:final streak) => streak.currentStreak,
        DailyRewardClaiming(:final streak) => streak.currentStreak,
        DailyRewardClaimed(:final streak) => streak.currentStreak,
        _ => 0,
      };
}

/// Gradient avatar with the streak count fused on as a flame badge.
class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.gradient, required this.streak});

  final Gradient gradient;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(gradient: gradient, shape: BoxShape.circle),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.ink900,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: AppColors.amber300, size: 24),
            ),
          ),
          if (streak > 0)
            Positioned(
              bottom: -4,
              right: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.ink950,
                  borderRadius: AppRadii.pillAll,
                  border: Border.all(color: AppColors.amber500),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amber500.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department,
                        size: 11, color: AppColors.amber400),
                    const SizedBox(width: 2),
                    Text('$streak',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.amber200,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        )),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Glowing amber bounty/coins readout.
class _CoinReadout extends StatelessWidget {
  const _CoinReadout();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.amber500.withValues(alpha: 0.12),
        borderRadius: AppRadii.pillAll,
        border: Border.all(color: AppColors.amber500.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.amber500.withValues(alpha: 0.18),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.paid, color: AppColors.amber400, size: 18),
          const SizedBox(width: 6),
          BlocBuilder<WalletCubit, int>(
            builder: (context, coins) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Text(
                _compact(coins),
                key: ValueKey(coins),
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.amber200,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact currency: 999, 1K, 1.2K, 12K, 1M, 1.2B — keeps the readout small
/// no matter how rich you get.
String _compact(int n) {
  if (n < 1000) return '$n';
  const units = ['K', 'M', 'B', 'T'];
  var v = n / 1000.0;
  var u = 0;
  while (v >= 1000 && u < units.length - 1) {
    v /= 1000;
    u++;
  }
  var str = v < 10 ? v.toStringAsFixed(1) : v.round().toString();
  if (str.endsWith('.0')) str = str.substring(0, str.length - 2);
  return '$str${units[u]}';
}
