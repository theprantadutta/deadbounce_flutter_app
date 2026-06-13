import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/animated_arena_background.dart';
import '../../../../core/widgets/db_button.dart';
import '../../../../core/widgets/fitted_headline.dart';
import '../../../runs/domain/entities/run_result.dart';

/// End-of-run breakdown: score, kills, best chain, max bounce kill,
/// waves, coins with a count-up, new-record highlight.
class RunResultsOverlay extends StatelessWidget {
  const RunResultsOverlay({
    super.key,
    required this.result,
    required this.isNewBestScore,
    required this.onRetry,
    required this.onHome,
    this.unlockedAchievements = const [],
  });

  final RunResult result;
  final bool isNewBestScore;
  final VoidCallback onRetry;
  final VoidCallback onHome;
  final List<String> unlockedAchievements;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedArenaBackground(
      child: SafeArea(
        child: Center(
          // Scrolls only as a safety net on unusually short screens; the
          // compact layout fits a normal phone without scrolling.
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FittedHeadline('RUN OVER', style: textTheme.headlineLarge),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    result.isDailyChallenge
                        ? 'Daily challenge attempt logged.'
                        : 'Every legend eats dirt sometimes.',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (isNewBestScore)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: AppRadii.mdAll,
                          border: Border.all(color: AppColors.amber400),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.amber500.withValues(alpha: 0.35),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: Text(
                          '★ NEW BEST SCORE ★',
                          style: textTheme.labelLarge
                              ?.copyWith(color: AppColors.amber300),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  FittedHeadline(
                    '${result.score}',
                    style: textTheme.displayMedium,
                  ),
                  Text(
                    'SCORE',
                    style: textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Compact 2x2 stat grid keeps the screen scroll-free.
                  Row(
                    children: [
                      Expanded(
                        child: _StatCell(
                          label: 'WAVES',
                          value: '${result.waveReached}',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: _StatCell(
                          label: 'KILLS',
                          value: '${result.kills}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCell(
                          label: 'BEST CHAIN',
                          value: 'x${result.bestChain}',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: _StatCell(
                          label: 'HOTTEST KILL',
                          value: '${result.maxBounceKill} bnc',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _CoinCountUp(coins: result.coinsEarned),
                  if (unlockedAchievements.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _UnlockedAchievements(names: unlockedAchievements),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  DbPrimaryButton(
                    label: 'RIDE AGAIN',
                    icon: Icons.replay,
                    onPressed: onRetry,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DbSecondaryButton(
                    label: 'BACK TO CAMP',
                    icon: Icons.home_outlined,
                    onPressed: onHome,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.ink800.withValues(alpha: 0.75),
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: AppColors.outlineFaint),
      ),
      child: Column(
        children: [
          FittedHeadline(value, style: textTheme.titleLarge),
          const SizedBox(height: 2),
          Text(label, style: textTheme.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _UnlockedAchievements extends StatelessWidget {
  const _UnlockedAchievements({required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.ink800.withValues(alpha: 0.85),
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.blue700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events,
                  color: AppColors.amber400, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text('AWARD${names.length > 1 ? 'S' : ''} UNLOCKED',
                  style: textTheme.labelMedium
                      ?.copyWith(color: AppColors.amber300)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final name in names)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(name, style: textTheme.bodyMedium),
            ),
          const SizedBox(height: 4),
          Text('Claim them in Awards.', style: textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _CoinCountUp extends StatelessWidget {
  const _CoinCountUp({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: coins.toDouble()),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.paid, color: AppColors.amber400, size: 26),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '+${value.round()}',
            style:
                textTheme.headlineMedium?.copyWith(color: AppColors.amber300),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text('COINS EARNED', style: textTheme.labelSmall),
        ],
      ),
    );
  }
}
