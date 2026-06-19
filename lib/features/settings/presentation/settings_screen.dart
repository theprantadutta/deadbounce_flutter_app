import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app.dart';
import '../../../core/di/session_dependencies.dart';
import '../../../core/router/routes.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/util/open_external_link.dart';
import '../../../core/widgets/meta_scaffold.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../domain/entities/app_settings.dart';
import 'cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String _websiteUrl = 'https://pranta.dev';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SettingsCubit(context.sessionDependencies.settingsRepository)..load(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return MetaScaffold(
      title: 'SETTINGS',
      child: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, settings) {
          final cubit = context.read<SettingsCubit>();
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            children: [
              // ---- AUDIO ----
              const _SectionHeader('AUDIO'),
              _ToggleTile(
                icon: Icons.volume_up_outlined,
                label: 'Sound',
                value: settings.soundEnabled,
                onChanged: cubit.toggleSound,
              ),
              const SizedBox(height: AppSpacing.xs),
              _ToggleTile(
                icon: Icons.music_note_outlined,
                label: 'Music',
                value: settings.musicEnabled,
                onChanged: cubit.toggleMusic,
              ),

              // ---- GAME FEEL ----
              const _SectionHeader('GAME FEEL'),
              _ToggleTile(
                icon: Icons.vibration,
                label: 'Haptics',
                value: settings.hapticsEnabled,
                onChanged: cubit.toggleHaptics,
              ),
              const SizedBox(height: AppSpacing.xs),
              _ToggleTile(
                icon: Icons.screen_rotation_alt_outlined,
                label: 'Screen shake',
                subtitle: 'Camera kick on kills and bosses',
                value: settings.screenShakeEnabled,
                onChanged: cubit.toggleScreenShake,
              ),
              const SizedBox(height: AppSpacing.xs),
              _ToggleTile(
                icon: Icons.ac_unit,
                label: 'Hit-stop',
                subtitle: 'Brief freeze on big hits',
                value: settings.hitStopEnabled,
                onChanged: cubit.toggleHitStop,
              ),
              const SizedBox(height: AppSpacing.xs),
              _ToggleTile(
                icon: Icons.timeline,
                label: 'Aim guide',
                subtitle: 'Show the ricochet preview line',
                value: settings.aimGuideEnabled,
                onChanged: cubit.toggleAimGuide,
              ),
              const SizedBox(height: AppSpacing.xs),
              _ToggleTile(
                icon: Icons.bolt_outlined,
                label: 'Combat text',
                subtitle: 'Bounce counts and chain shouts',
                value: settings.combatTextEnabled,
                onChanged: cubit.toggleCombatText,
              ),
              const SizedBox(height: AppSpacing.xs),
              _SegmentedTile<ParticleQuality>(
                icon: Icons.auto_awesome_outlined,
                label: 'Particles',
                value: settings.particleQuality,
                options: const [
                  (ParticleQuality.low, 'Low'),
                  (ParticleQuality.medium, 'Med'),
                  (ParticleQuality.high, 'High'),
                ],
                onChanged: cubit.setParticleQuality,
              ),

              // ---- DATA & SYNC ----
              const _SectionHeader('DATA & SYNC'),
              _SyncSection(session: context.sessionDependencies),

              // ---- ACCOUNT ----
              const _SectionHeader('ACCOUNT'),
              _NavTile(
                icon: Icons.person_outline,
                label: 'Profile',
                onTap: () => context.push(Routes.profile),
              ),
              const SizedBox(height: AppSpacing.xs),
              _ActionTile(
                icon: Icons.logout,
                label: 'Sign out',
                destructive: true,
                onTap: () => _confirmSignOut(context),
              ),

              // ---- ABOUT ----
              const _SectionHeader('ABOUT'),
              _NavTile(
                icon: Icons.help_outline,
                label: 'How to play',
                onTap: () => context.push(Routes.howToPlay),
              ),
              const SizedBox(height: AppSpacing.xs),
              _NavTile(
                icon: Icons.favorite_outline,
                label: 'Credits',
                onTap: () => context.push(Routes.credits),
              ),
              const SizedBox(height: AppSpacing.xs),
              _NavTile(
                icon: Icons.public,
                label: 'Visit pranta.dev',
                external: true,
                onTap: () =>
                    openExternalLink(context, SettingsScreen._websiteUrl),
              ),
              const SizedBox(height: AppSpacing.xs),
              const _VersionRow(),

              // ---- DANGER ZONE ----
              const _SectionHeader('DANGER ZONE'),
              _ActionTile(
                icon: Icons.delete_sweep_outlined,
                label: 'Clear local data',
                destructive: true,
                onTap: () => _confirmClearData(context),
              ),

              // ---- DIAGNOSTICS (debug only) ----
              if (kDebugMode) ...[
                const _SectionHeader('DIAGNOSTICS'),
                _NavTile(
                  icon: Icons.bug_report_outlined,
                  label: 'View logs',
                  onTap: () => context.push(Routes.logs),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Text('Bullets only bite after they bounce.',
                    style: Theme.of(context).textTheme.labelSmall),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.ink800,
        title: const Text('Sign out?'),
        content: const Text(
            'Guest progress on this device stays put, but you\'ll need to '
            'sign back in to play.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('STAY'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );
    if ((confirmed ?? false) && context.mounted) {
      context.read<AuthCubit>().signOut();
    }
  }

  Future<void> _confirmClearData(BuildContext context) async {
    final session = context.sessionDependencies;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.ink800,
        title: const Text('Clear local data?'),
        content: const Text(
            'This wipes this device\'s progress (runs, coins, stats, perks). '
            'Synced progress restores from the cloud — but anything not yet '
            'synced is lost. You stay signed in. Best done while online.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('CLEAR DATA'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;

    messenger
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Clearing local data…')));
    await session.clearLocalData();
    messenger
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Local data cleared.')));
    router.go(Routes.home);
  }
}

/// Live sync status + a "Sync now" / "Retry failed" action.
class _SyncSection extends StatelessWidget {
  const _SyncSection({required this.session});

  final SessionDependencies session;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ValueListenableBuilder<SyncStatus>(
      valueListenable: session.syncStatus,
      builder: (context, status, _) {
        final (IconData icon, String line, Color color) = switch (status) {
          _ when status.failedCount > 0 => (
              Icons.cloud_off_outlined,
              '${status.failedCount} change(s) failed to sync',
              AppColors.error,
            ),
          _ when status.isSyncing || status.pendingCount > 0 => (
              Icons.cloud_sync_outlined,
              '${status.pendingCount} change(s) syncing…',
              AppColors.blue300,
            ),
          _ => (
              Icons.cloud_done_outlined,
              'All changes synced',
              AppColors.blue300,
            ),
        };
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: _tileBox(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(line, style: textTheme.bodyLarge)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _MiniButton(
                    label: 'Sync now',
                    onTap: session.syncWorker.requestSync,
                  ),
                  if (status.failedCount > 0) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _MiniButton(
                      label: 'Retry failed',
                      onTap: session.syncWorker.retryFailed,
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final value =
            info == null ? '—' : 'v${info.version} (${info.buildNumber})';
        return _InfoRow(
          icon: Icons.info_outline,
          label: 'Version',
          value: value,
        );
      },
    );
  }
}

// ---- shared tiles ----

BoxDecoration _tileBox() => BoxDecoration(
      color: AppColors.ink800.withValues(alpha: 0.8),
      borderRadius: AppRadii.mdAll,
      border: Border.all(color: AppColors.outlineFaint),
    );

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      decoration: _tileBox(),
      child: Row(
        children: [
          Icon(icon, color: AppColors.blue300, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: textTheme.bodyLarge),
                if (subtitle != null)
                  Text(subtitle!, style: textTheme.labelSmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.amber400,
          ),
        ],
      ),
    );
  }
}

/// A labeled N-way segmented selector.
class _SegmentedTile<T> extends StatelessWidget {
  const _SegmentedTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: _tileBox(),
      child: Row(
        children: [
          Icon(icon, color: AppColors.blue300, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: textTheme.bodyLarge)),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.ink900.withValues(alpha: 0.6),
              borderRadius: AppRadii.pillAll,
              border: Border.all(color: AppColors.outlineFaint),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (optValue, optLabel) in options)
                  _Segment(
                    label: optLabel,
                    selected: optValue == value,
                    onTap: () => onChanged(optValue),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.amber500 : Colors.transparent,
      borderRadius: AppRadii.pillAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.pillAll,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? AppColors.onAmber : AppColors.textSecondary,
                ),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.external = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool external;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.mdAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.md),
          decoration: _tileBox(),
          child: Row(
            children: [
              Icon(icon, color: AppColors.blue300, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child:
                    Text(label, style: Theme.of(context).textTheme.bodyLarge),
              ),
              Icon(
                external ? Icons.open_in_new : Icons.chevron_right,
                color: AppColors.ink300,
                size: external ? 16 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: _tileBox(),
      child: Row(
        children: [
          Icon(icon, color: AppColors.ink300, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: textTheme.bodyLarge)),
          Text(value, style: textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.mdAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.md),
          decoration: _tileBox(),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.md),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink700,
      borderRadius: AppRadii.pillAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.pillAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: AppColors.blue300),
          ),
        ),
      ),
    );
  }
}
