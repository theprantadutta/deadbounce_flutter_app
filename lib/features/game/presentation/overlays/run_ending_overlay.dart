import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/fitted_headline.dart';

/// The death beat — a brief, dramatic pause over the frozen arena telling the
/// player what just happened (what felled them, which wave) before the results
/// screen. Auto-advances; tap anywhere to skip straight to the results.
class RunEndingOverlay extends StatelessWidget {
  const RunEndingOverlay({
    super.key,
    required this.headline,
    required this.detail,
    required this.wave,
    required this.onSkip,
  });

  final String headline;
  final String detail;
  final int wave;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onSkip,
      behavior: HitTestBehavior.opaque,
      child: ColoredBox(
        // Dim the frozen arena so they still see where they fell.
        color: AppColors.ink950.withValues(alpha: 0.82),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedHeadline(
                    headline,
                    style: textTheme.displaySmall?.copyWith(
                      color: AppColors.error,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: AppColors.error.withValues(alpha: 0.7),
                          blurRadius: 24,
                        ),
                        Shadow(
                          color: AppColors.error.withValues(alpha: 0.4),
                          blurRadius: 44,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    detail,
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'WAVE $wave',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.amber300,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'tap to continue',
                    style: textTheme.labelSmall
                        ?.copyWith(color: AppColors.ink400),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 240.ms)
                .scaleXY(
                  begin: 0.92,
                  end: 1,
                  duration: 320.ms,
                  curve: Curves.easeOutBack,
                ),
          ),
        ),
      ),
    );
  }
}
