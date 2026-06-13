import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/meta_scaffold.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../domain/entities/app_settings.dart';
import 'cubit/settings_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String appVersion = 'v1.0.0 — Phase 2';

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
    final textTheme = Theme.of(context).textTheme;

    return MetaScaffold(
      title: 'SETTINGS',
      child: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, settings) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            children: [
              Text('GAME', style: textTheme.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              _ToggleTile(
                icon: Icons.volume_up_outlined,
                label: 'Sound',
                value: settings.soundEnabled,
                onChanged: (v) =>
                    context.read<SettingsCubit>().toggleSound(v),
              ),
              const SizedBox(height: AppSpacing.xs),
              _ToggleTile(
                icon: Icons.vibration,
                label: 'Haptics',
                value: settings.hapticsEnabled,
                onChanged: (v) =>
                    context.read<SettingsCubit>().toggleHaptics(v),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('ACCOUNT', style: textTheme.labelMedium),
              const SizedBox(height: AppSpacing.sm),
              _ActionTile(
                icon: Icons.logout,
                label: 'Sign out',
                destructive: true,
                onTap: () => _confirmSignOut(context),
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Text(SettingsScreen.appVersion,
                    style: textTheme.labelSmall),
              ),
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: Text('Bullets only bite after they bounce.',
                    style: textTheme.labelSmall),
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
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.ink800.withValues(alpha: 0.8),
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: AppColors.outlineFaint),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.blue300, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
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
          decoration: BoxDecoration(
            color: AppColors.ink800.withValues(alpha: 0.8),
            borderRadius: AppRadii.mdAll,
            border: Border.all(color: AppColors.outlineFaint),
          ),
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
