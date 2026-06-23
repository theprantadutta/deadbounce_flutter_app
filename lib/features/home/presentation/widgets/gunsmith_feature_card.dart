import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

/// Home entry to the Gunsmith shop — a compact horizontal icon + label tile
/// styled to match the stat chips (soft accent border + faint glow, no heavy
/// edge). Shares a row with the Outfitter.
class GunsmithFeatureCard extends StatelessWidget {
  const GunsmithFeatureCard({super.key});

  static const Color _accent = AppColors.amber400;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(Routes.gunsmith),
        borderRadius: AppRadii.mdAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.ink800.withValues(alpha: 0.78),
            borderRadius: AppRadii.mdAll,
            border: Border.all(color: _accent.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(color: _accent.withValues(alpha: 0.12), blurRadius: 12),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Boxed icon badge, matching the Tournaments / Daily Challenge
              // cards (soft accent border + tint), just smaller.
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.amber500.withValues(alpha: 0.16),
                  borderRadius: AppRadii.smAll,
                  border: Border.all(color: _accent.withValues(alpha: 0.45)),
                ),
                child: const Icon(
                  Icons.handyman,
                  color: AppColors.amber300,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                // Scales down rather than truncating, so the name stays whole.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('GUNSMITH', style: textTheme.labelMedium),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
