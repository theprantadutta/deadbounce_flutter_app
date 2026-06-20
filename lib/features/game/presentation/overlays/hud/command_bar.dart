import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_effects.dart';
import '../../game/hud_model.dart';

/// The top "command bar": one neon glass strip split into three zones —
/// life (left), wave + progress (center), score + coins + pause (right).
/// Each value listens independently so only tiny widgets rebuild at game
/// speed — no full-overlay rebuilds.
class CommandBar extends StatelessWidget {
  const CommandBar({super.key, required this.hud, required this.onPause});

  final HudModel hud;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final effects = Theme.of(context).extension<AppEffects>()!;

    return Container(
      decoration: effects.glassDecoration.copyWith(
        borderRadius: AppRadii.lgAll,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _HeartsZone(hud: hud),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _WaveZone(hud: hud)),
          const SizedBox(width: AppSpacing.sm),
          _ScoreZone(hud: hud),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            tooltip: 'Pause',
            onPressed: onPause,
            icon: const Icon(Icons.pause, size: 20),
            visualDensity: VisualDensity.compact,
            color: AppColors.ink100,
          ),
        ],
      ),
    );
  }
}

class _HeartsZone extends StatelessWidget {
  const _HeartsZone({required this.hud});
  final HudModel hud;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: hud.maxHearts,
      builder: (context, maxHearts, _) => ValueListenableBuilder<int>(
        valueListenable: hud.hearts,
        builder: (context, hearts, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < maxHearts; i++)
              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  i < hearts ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: i < hearts ? AppColors.error : AppColors.ink400,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WaveZone extends StatelessWidget {
  const _WaveZone({required this.hud});
  final HudModel hud;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: hud.wave,
          builder: (context, wave, _) => Text(
            'WAVE $wave',
            style: textTheme.labelMedium?.copyWith(color: AppColors.blue300),
          ),
        ),
        const SizedBox(height: 3),
        // Progress bar + "N left".
        ValueListenableBuilder<int>(
          valueListenable: hud.enemiesTotal,
          builder: (context, total, _) => ValueListenableBuilder<int>(
            valueListenable: hud.enemiesRemaining,
            builder: (context, remaining, _) {
              final cleared = total <= 0 ? 0.0 : (total - remaining) / total;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 64,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      child: LinearProgressIndicator(
                        value: cleared.clamp(0.0, 1.0),
                        minHeight: 5,
                        backgroundColor: AppColors.ink600,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.blue400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$remaining',
                    style: textTheme.labelSmall
                        ?.copyWith(color: AppColors.ink200),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ScoreZone extends StatelessWidget {
  const _ScoreZone({required this.hud});
  final HudModel hud;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: hud.score,
          builder: (context, score, _) => Text(
            _formatScore(score),
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 1),
        ValueListenableBuilder<int>(
          valueListenable: hud.coins,
          builder: (context, coins, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.paid, size: 13, color: AppColors.amber400),
              const SizedBox(width: 3),
              Text(
                '$coins',
                style:
                    textTheme.labelMedium?.copyWith(color: AppColors.amber300),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Group thousands so big scores stay readable (12450 -> 12,450).
  static String _formatScore(int score) {
    final s = score.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
