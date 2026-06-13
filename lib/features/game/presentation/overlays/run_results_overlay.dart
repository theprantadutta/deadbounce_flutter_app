import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/db_button.dart';
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

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: ColoredBox(
        color: Colors.black87,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'RUN OVER',
                      style: textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      result.isDailyChallenge
                          ? 'Daily challenge attempt logged.'
                          : 'Every legend eats dirt sometimes.',
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (isNewBestScore)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: AppRadii.mdAll,
                            border:
                                Border.all(color: AppColors.amber400),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.amber500
                                    .withValues(alpha: 0.35),
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
                    Text(
                      '${result.score}',
                      style: textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'SCORE',
                      style: textTheme.labelSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _StatRow(label: 'Waves survived', value: '${result.waveReached}'),
                    _StatRow(label: 'Kills', value: '${result.kills}'),
                    _StatRow(label: 'Best chain', value: 'x${result.bestChain}'),
                    _StatRow(
                        label: 'Hottest kill',
                        value: '${result.maxBounceKill} bounces'),
                    const Divider(height: AppSpacing.lg),
                    _CoinCountUp(coins: result.coinsEarned),
                    if (unlockedAchievements.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _UnlockedAchievements(names: unlockedAchievements),
                    ],
                    const SizedBox(height: AppSpacing.xl),
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
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textTheme.bodyMedium)),
          Text(value, style: textTheme.titleMedium),
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
