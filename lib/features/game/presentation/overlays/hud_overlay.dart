import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_effects.dart';
import '../game/hud_model.dart';

/// Minimal, readable, out of the thumb's way: hearts top-left, wave
/// center, score/coins top-right, pause button. Each value listens
/// independently — no full-overlay rebuilds at game speed.
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.hud, required this.onPause});

  final HudModel hud;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final effects = Theme.of(context).extension<AppEffects>()!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hearts.
            ValueListenableBuilder<int>(
              valueListenable: hud.hearts,
              builder: (context, hearts, _) => ValueListenableBuilder<int>(
                valueListenable: hud.maxHearts,
                builder: (context, maxHearts, _) => Row(
                  children: [
                    for (var i = 0; i < maxHearts; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Icon(
                          i < hearts
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 22,
                          color: i < hearts
                              ? AppColors.error
                              : AppColors.ink400,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // Wave + score + coins.
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: hud.wave,
                  builder: (context, wave, _) => Text(
                    'WAVE $wave',
                    style: textTheme.labelMedium
                        ?.copyWith(color: AppColors.blue300),
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: hud.score,
                  builder: (context, score, _) => Text(
                    '$score',
                    style: textTheme.headlineSmall,
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: hud.coins,
                  builder: (context, coins, _) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.paid,
                          size: 14, color: AppColors.amber400),
                      const SizedBox(width: 3),
                      Text(
                        '$coins',
                        style: textTheme.labelMedium
                            ?.copyWith(color: AppColors.amber300),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            DecoratedBox(
              decoration: effects.glassDecoration,
              child: IconButton(
                tooltip: 'Pause',
                onPressed: onPause,
                icon: const Icon(Icons.pause, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
