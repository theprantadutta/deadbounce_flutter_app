import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../../../../core/theme/app_effects.dart';
import '../../game/hud_model.dart';

/// Boss health bar shown on Warden waves: the boss name, a per-phase HP
/// fill, and phase pips (spent vs remaining). Slides in when a Warden is
/// active and out when it falls.
class BossBar extends StatelessWidget {
  const BossBar({super.key, required this.hud});

  final HudModel hud;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: hud.bossActive,
      builder: (context, active, _) {
        if (!active) return const SizedBox.shrink();
        return _Bar(hud: hud)
            .animate()
            .fadeIn(duration: 250.ms)
            .slideY(begin: -0.4, end: 0, curve: Curves.easeOutCubic);
      },
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.hud});
  final HudModel hud;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final effects = Theme.of(context).extension<AppEffects>()!;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: effects.glassDecoration.copyWith(
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.45)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder<String>(
                valueListenable: hud.bossName,
                builder: (context, name, _) => Text(
                  name,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.error,
                    letterSpacing: 2,
                  ),
                ),
              ),
              _Pips(hud: hud),
            ],
          ),
          const SizedBox(height: 5),
          _PhaseHpBar(hud: hud),
        ],
      ),
    );
  }
}

class _PhaseHpBar extends StatelessWidget {
  const _PhaseHpBar({required this.hud});
  final HudModel hud;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: hud.bossPhaseMaxHp,
      builder: (context, maxHp, _) => ValueListenableBuilder<int>(
        valueListenable: hud.bossPhaseHp,
        builder: (context, hp, _) {
          final frac = maxHp <= 0 ? 0.0 : (hp / maxHp).clamp(0.0, 1.0);
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: frac,
              minHeight: 7,
              backgroundColor: AppColors.ink700,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.amber400),
            ),
          );
        },
      ),
    );
  }
}

class _Pips extends StatelessWidget {
  const _Pips({required this.hud});
  final HudModel hud;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: hud.bossPhases,
      builder: (context, phases, _) => ValueListenableBuilder<int>(
        valueListenable: hud.bossPhase,
        builder: (context, spent, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < phases; i++)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.circle,
                  size: 8,
                  color: i < (phases - spent)
                      ? AppColors.amber400
                      : AppColors.ink500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
