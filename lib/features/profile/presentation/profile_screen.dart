import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/db_button.dart';
import '../../../core/widgets/meta_scaffold.dart';
import 'cubit/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProfileCubit(context.sessionDependencies.profileRepository)..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final syncStatus = context.sessionDependencies.syncStatus;

    return MetaScaffold(
      title: 'PROFILE',
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return switch (state) {
            ProfileLoading() =>
              const Center(child: CircularProgressIndicator()),
            ProfileError(:final message) =>
              Center(child: Text(message, style: textTheme.bodyLarge)),
            ProfileLoaded(:final data) => ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                children: [
                  const SizedBox(height: kToolbarHeight),
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: AppColors.ink700,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.amber500, width: 2),
                      ),
                      child: const Icon(Icons.person,
                          size: 44, color: AppColors.amber300),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(data.displayName,
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.ink700,
                        borderRadius: AppRadii.pillAll,
                      ),
                      child: Text(
                        data.isGuest ? 'GUEST ACCOUNT' : 'LINKED ACCOUNT',
                        style: textTheme.labelSmall?.copyWith(
                          color: data.isGuest
                              ? AppColors.amber300
                              : AppColors.success,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ValueListenableBuilder<SyncStatus>(
                    valueListenable: syncStatus,
                    builder: (context, status, _) {
                      if (!status.hasPendingWork) return const SizedBox.shrink();
                      return Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cloud_upload_outlined,
                                  size: 14, color: AppColors.ink300),
                              const SizedBox(width: 6),
                              Text(
                                status.failedCount > 0
                                    ? '${status.failedCount} change(s) failed to sync'
                                    : '${status.pendingCount} change(s) syncing…',
                                style: textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  if (data.isGuest) ...[
                    const SizedBox(height: AppSpacing.sm),
                    DbSecondaryButton(
                      label: 'LINK AN ACCOUNT',
                      icon: Icons.link,
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(const SnackBar(
                            content: Text(
                                'Account linking is coming soon, partner.'),
                          ));
                      },
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Text('LIFETIME', style: textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.sm),
                  _StatGrid(data: data),
                ],
              ),
          };
        },
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.data});

  final dynamic data;

  @override
  Widget build(BuildContext context) {
    final entries = <(String, String)>[
      ('Runs played', '${data.runsPlayed}'),
      ('Total kills', '${data.totalKills}'),
      ('Best score', '${data.bestScore}'),
      ('Best chain', 'x${data.bestChain}'),
      ('Best bounce kill', '${data.bestBounceKill}'),
      ('Furthest wave', '${data.bestWave}'),
      ('Coins earned', '${data.totalCoinsEarned}'),
      ('Time in the dust', _fmt(data.totalPlayTime as Duration)),
    ];

    return Column(
      children: [
        for (final (label, value) in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.ink800.withValues(alpha: 0.8),
                borderRadius: AppRadii.mdAll,
                border: Border.all(color: AppColors.outlineFaint),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(label,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  Text(value,
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static String _fmt(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m';
    return '${d.inSeconds}s';
  }
}
