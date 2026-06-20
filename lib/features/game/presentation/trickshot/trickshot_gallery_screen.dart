import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/meta_scaffold.dart';
import '../../engine/trickshot/trickshot_catalog.dart';
import '../../engine/trickshot/trickshot_level.dart';

/// Lists the trick-shot puzzles. Tapping one launches it. (Best-score
/// persistence is a planned fast-follow; v1 is the ladder itself.)
class TrickShotGalleryScreen extends StatelessWidget {
  const TrickShotGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MetaScaffold(
      title: 'TRICK-SHOT GALLERY',
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          Text(
            'Pure aim. Hit every mark with the bounces it demands — no enemies, '
            'no clock, just you and the geometry.',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final (i, level) in TrickShotCatalog.levels.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _LevelTile(index: i + 1, level: level),
            ),
        ],
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({required this.index, required this.level});

  final int index;
  final TrickShotLevel level;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            context.push('${Routes.trickShotRun}/${level.id}'),
        borderRadius: AppRadii.lgAll,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.ink800.withValues(alpha: 0.85),
            borderRadius: AppRadii.lgAll,
            border: Border.all(color: AppColors.outlineFaint),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.blue900.withValues(alpha: 0.4),
                  borderRadius: AppRadii.mdAll,
                  border: Border.all(color: AppColors.blue600),
                ),
                child: Text('$index',
                    style: textTheme.titleMedium
                        ?.copyWith(color: AppColors.blue200)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(level.name, style: textTheme.titleSmall),
                    Text(
                      '${level.targets.length} target'
                      '${level.targets.length == 1 ? '' : 's'} · par ${level.par}',
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.ink300),
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
