import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/meta_scaffold.dart';
import '../domain/entities/achievement_view.dart';
import 'cubit/achievements_cubit.dart';

class AwardsScreen extends StatelessWidget {
  const AwardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.sessionDependencies;
    return BlocProvider(
      create: (_) => AchievementsCubit(
        repository: session.achievementsRepository,
        syncWorker: session.syncWorker,
      )..load(),
      child: const _AwardsView(),
    );
  }
}

class _AwardsView extends StatelessWidget {
  const _AwardsView();

  @override
  Widget build(BuildContext context) {
    return MetaScaffold(
      title: 'AWARDS',
      child: BlocBuilder<AchievementsCubit, AchievementsState>(
        builder: (context, state) {
          return switch (state) {
            AchievementsLoading() =>
              const Center(child: CircularProgressIndicator()),
            AchievementsError(:final message) => Center(
                child: Text(message,
                    style: Theme.of(context).textTheme.bodyLarge),
              ),
            AchievementsLoaded(:final views) => _Grid(views: views),
          };
        },
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.views});

  final List<AchievementView> views;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final unlocked = views.where((v) => v.isUnlocked).length;

    return Column(
      children: [
        SizedBox(height: kToolbarHeight + AppSpacing.xs),
        Text('$unlocked / ${views.length} UNLOCKED',
            style: textTheme.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.82,
            ),
            itemCount: views.length,
            itemBuilder: (context, i) => _AwardTile(view: views[i]),
          ),
        ),
      ],
    );
  }
}

class _AwardTile extends StatelessWidget {
  const _AwardTile({required this.view});

  final AchievementView view;

  static IconData _icon(String name) => switch (name) {
        'water_drop' => Icons.water_drop,
        'sports_esports' => Icons.sports_esports,
        'sports_tennis' => Icons.sports_tennis,
        'gpp_bad' => Icons.gpp_bad,
        'link' => Icons.link,
        'call_split' => Icons.call_split,
        'local_fire_department' => Icons.local_fire_department,
        'auto_awesome' => Icons.auto_awesome,
        'event_available' => Icons.event_available,
        'military_tech' => Icons.military_tech,
        'shield_moon' => Icons.shield_moon,
        'calendar_month' => Icons.calendar_month,
        'style' => Icons.style,
        'verified_user' => Icons.verified_user,
        'workspaces' => Icons.workspaces,
        'savings' => Icons.savings,
        'directions_run' => Icons.directions_run,
        'center_focus_strong' => Icons.center_focus_strong,
        'looks_one' => Icons.looks_one,
        'shield' => Icons.shield,
        'whatshot' => Icons.whatshot,
        'paid' => Icons.paid,
        'explore' => Icons.explore,
        'workspace_premium' => Icons.workspace_premium,
        _ => Icons.emoji_events,
      };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hidden = view.isHiddenSecret;
    final unlocked = view.isUnlocked;
    final claimable = view.isClaimable;

    final accentColor = claimable
        ? AppColors.amber400
        : unlocked
            ? AppColors.blue400
            : AppColors.ink500;

    return GestureDetector(
      onTap: claimable
          ? () => context.read<AchievementsCubit>().claim(view.definition.id)
          : null,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.ink800.withValues(alpha: unlocked ? 0.9 : 0.55),
          borderRadius: AppRadii.lgAll,
          border: Border.all(color: accentColor, width: claimable ? 1.6 : 1),
          boxShadow: claimable
              ? [
                  BoxShadow(
                      color: AppColors.amber500.withValues(alpha: 0.3),
                      blurRadius: 14)
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hidden
                  ? Icons.lock
                  : _icon(view.definition.iconName),
              color: unlocked ? accentColor : AppColors.ink400,
              size: 34,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              hidden ? '???' : view.definition.name,
              style: textTheme.labelMedium?.copyWith(
                color: unlocked ? AppColors.textPrimary : AppColors.ink300,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (claimable)
              Text('TAP TO CLAIM +${view.definition.coinReward}',
                  style: textTheme.labelSmall
                      ?.copyWith(color: AppColors.amber300),
                  textAlign: TextAlign.center)
            else if (view.isClaimed)
              const Icon(Icons.check_circle,
                  color: AppColors.success, size: 16)
            else if (hidden)
              Text('SECRET', style: textTheme.labelSmall)
            else if (!unlocked && view.definition.target > 1)
              _ProgressBar(fraction: view.progressFraction)
            else
              Text(view.definition.flavor,
                  style: textTheme.labelSmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadii.pillAll,
      child: LinearProgressIndicator(
        value: fraction,
        minHeight: 5,
        backgroundColor: AppColors.ink600,
        valueColor: const AlwaysStoppedAnimation(AppColors.blue400),
      ),
    );
  }
}
