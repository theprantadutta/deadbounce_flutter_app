import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/utc_midnight_countdown.dart';

/// The daily challenge surfaced as a live "event" banner — a glowing bolt
/// badge, a pulsing TODAY chip, and the reset countdown.
class DailyChallengeFeatureCard extends StatelessWidget {
  const DailyChallengeFeatureCard({super.key});

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
            border: Border.all(color: AppColors.blue600),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue500.withValues(alpha: 0.18),
                blurRadius: 18,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.blue900.withValues(alpha: 0.5),
                  borderRadius: AppRadii.mdAll,
                  border: Border.all(color: AppColors.blue600),
                ),
                child: const Icon(Icons.bolt, color: AppColors.blue300, size: 26),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('DAILY CHALLENGE', style: textTheme.titleSmall),
                        const SizedBox(width: AppSpacing.xs),
                        const _LiveBadge(),
                      ],
                    ),
                    UtcMidnightCountdown(
                      prefix: 'Resets in ',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.blue300),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.amber500.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.amber500.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: AppColors.amber400,
              shape: BoxShape.circle,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 700.ms)
              .then()
              .fade(begin: 1, end: 0.3, duration: 700.ms),
          const SizedBox(width: 4),
          Text('TODAY',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.amber300,
                fontSize: 9,
                letterSpacing: 1,
              )),
        ],
      ),
    );
  }
}
