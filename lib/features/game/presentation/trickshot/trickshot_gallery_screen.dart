import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/meta_scaffold.dart';
import '../../engine/trickshot/trickshot_catalog.dart';
import '../../engine/trickshot/trickshot_level.dart';
import 'trickshot_progress_repository.dart';

/// Lists the trick-shot puzzles with local (offline-first) progress: a cleared
/// check and best-shots-vs-par per level. Tapping one launches it.
class TrickShotGalleryScreen extends StatelessWidget {
  const TrickShotGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final repo = context.sessionDependencies.trickShotProgressRepository;
    return MetaScaffold(
      title: 'TRICK-SHOT GALLERY',
      child: StreamBuilder<Map<String, TrickShotProgress>>(
        stream: repo.watchProgress(),
        builder: (context, snapshot) {
          final progress = snapshot.data ?? const <String, TrickShotProgress>{};
          final cleared = progress.values.where((p) => p.cleared).length;
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            children: [
              Text(
                'Pure aim. Hit every mark with the bounces it demands — no enemies, '
                'no clock, just you and the geometry.',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$cleared / ${TrickShotCatalog.levels.length} cleared',
                style:
                    textTheme.labelMedium?.copyWith(color: AppColors.amber300),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final (i, level) in TrickShotCatalog.levels.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _LevelTile(
                    index: i + 1,
                    level: level,
                    progress: progress[level.id],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({required this.index, required this.level, this.progress});

  final int index;
  final TrickShotLevel level;
  final TrickShotProgress? progress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cleared = progress?.cleared ?? false;
    final best = progress?.bestShots;
    final underPar = best != null && best <= level.par;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('${Routes.trickShotRun}/${level.id}'),
        borderRadius: AppRadii.lgAll,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.ink800.withValues(alpha: 0.85),
            borderRadius: AppRadii.lgAll,
            border: Border.all(
              color: cleared ? AppColors.amber600 : AppColors.outlineFaint,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cleared
                      ? AppColors.amber500.withValues(alpha: 0.15)
                      : AppColors.blue900.withValues(alpha: 0.4),
                  borderRadius: AppRadii.mdAll,
                  border: Border.all(
                    color: cleared ? AppColors.amber600 : AppColors.blue600,
                  ),
                ),
                child: cleared
                    ? const Icon(Icons.check,
                        size: 22, color: AppColors.amber300)
                    : Text('$index',
                        style: textTheme.titleMedium
                            ?.copyWith(color: AppColors.blue200)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(level.name, style: textTheme.titleSmall),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${level.targets.length} target'
                            '${level.targets.length == 1 ? '' : 's'} · par ${level.par}',
                            style: textTheme.bodySmall
                                ?.copyWith(color: AppColors.ink300),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (best != null)
                          Text(
                            ' · best $best',
                            style: textTheme.bodySmall?.copyWith(
                              color: underPar
                                  ? AppColors.success
                                  : AppColors.amber300,
                            ),
                          ),
                      ],
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
