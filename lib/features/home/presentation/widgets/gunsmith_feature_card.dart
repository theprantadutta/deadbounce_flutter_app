import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

/// Home entry to the Gunsmith shop — spend coins on permanent perks.
class GunsmithFeatureCard extends StatelessWidget {
  const GunsmithFeatureCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(Routes.gunsmith),
        borderRadius: AppRadii.lgAll,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.ink800.withValues(alpha: 0.85),
            borderRadius: AppRadii.lgAll,
            border: Border.all(color: AppColors.amber600),
            boxShadow: [
              BoxShadow(
                color: AppColors.amber500.withValues(alpha: 0.16),
                blurRadius: 18,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.amber900.withValues(alpha: 0.4),
                  borderRadius: AppRadii.mdAll,
                  border: Border.all(color: AppColors.amber600),
                ),
                child: const Icon(Icons.handyman,
                    color: AppColors.amber300, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('THE GUNSMITH', style: textTheme.titleSmall),
                    Text('Spend your bounty on permanent iron.',
                        style: textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.amber300),
            ],
          ),
        ),
      ),
    );
  }
}
