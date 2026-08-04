import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/fitted_headline.dart';

/// The one-per-run buy-back offer: a fatal hit landed, but coins can pull the
/// gunslinger back from the brink (once). Buy to revive at one heart with
/// mercy i-frames, or walk away and let the run end.
class ContinueOverlay extends StatelessWidget {
  const ContinueOverlay({
    super.key,
    required this.wave,
    required this.cost,
    required this.onBuy,
    required this.onDecline,
    this.onWatchAd,
  });

  final int wave;
  final int cost;
  final VoidCallback onBuy;
  final VoidCallback onDecline;

  /// Null when no rewarded ad is loaded. The button is only rendered when one
  /// is genuinely ready — offering "watch an ad" and then failing at the most
  /// emotionally loaded moment in the game is worse than not offering it.
  final VoidCallback? onWatchAd;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ColoredBox(
      color: AppColors.ink950.withValues(alpha: 0.86),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedHeadline(
                  'ONE MORE?',
                  style: textTheme.displaySmall?.copyWith(
                    color: AppColors.amber400,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: AppColors.amber400.withValues(alpha: 0.6),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'You fell on wave $wave. Buy back in — once.',
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                // Watch-an-ad first: it costs nothing, so burying it under the
                // coin price would read as pushing the paid option.
                if (onWatchAd != null) ...[
                  FilledButton.icon(
                    onPressed: onWatchAd,
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('WATCH AD  ·  FREE'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.blue400,
                      foregroundColor: AppColors.ink950,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                // Buy button.
                FilledButton.icon(
                  onPressed: onBuy,
                  icon: const Icon(Icons.paid),
                  label: Text('CONTINUE  ·  $cost'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.amber500,
                    foregroundColor: AppColors.ink950,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: onDecline,
                  child: Text(
                    'LET IT RIDE',
                    style: textTheme.labelLarge
                        ?.copyWith(color: AppColors.ink300, letterSpacing: 2),
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 220.ms)
                .scaleXY(
                  begin: 0.92,
                  end: 1,
                  duration: 300.ms,
                  curve: Curves.easeOutBack,
                ),
          ),
        ),
      ),
    );
  }
}
