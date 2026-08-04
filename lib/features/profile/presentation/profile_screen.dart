import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/analytics/analytics.dart';
import '../../../core/router/routes.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/db_button.dart';
import '../../../core/widgets/meta_scaffold.dart';
import '../../../core/widgets/player_avatar.dart';
import '../../auth/domain/entities/account_link_result.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../domain/entities/profile_data.dart';
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
    final authState = context.watch<AuthCubit>().state;
    final photoUrl =
        authState is AuthAuthenticated ? authState.user.photoUrl : null;

    return MetaScaffold(
      title: 'PROFILE',
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return switch (state) {
            ProfileLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ProfileError(:final message) => Center(
              child: Text(message, style: textTheme.bodyLarge),
            ),
            ProfileLoaded(:final data) => ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              children: [
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.ink700,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.amber500, width: 2),
                    ),
                    child: PlayerAvatar(
                      photoUrl: photoUrl,
                      size: 78,
                      background: AppColors.ink700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  data.displayName,
                  style: textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
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
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_upload_outlined,
                              size: 14,
                              color: AppColors.ink300,
                            ),
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
                  const _LinkAccountButton(),
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

/// The guest→permanent upgrade CTA.
///
/// Stateful because the whole flow — picker, Firebase link, token re-exchange,
/// local write — is one user-visible action that must show a single spinner and
/// must not be double-tappable.
class _LinkAccountButton extends StatefulWidget {
  const _LinkAccountButton();

  @override
  State<_LinkAccountButton> createState() => _LinkAccountButtonState();
}

class _LinkAccountButtonState extends State<_LinkAccountButton> {
  bool _busy = false;

  Future<void> _link() async {
    if (_busy) return;
    setState(() => _busy = true);

    // Captured before the first await — the session can be torn down and
    // rebuilt underneath us if the user ends up switching accounts.
    final messenger = ScaffoldMessenger.of(context);
    final session = context.sessionDependencies;
    final profileCubit = context.read<ProfileCubit>();
    final authCubit = context.read<AuthCubit>();

    final result = await authCubit.linkWithGoogle();
    if (!mounted) return;
    setState(() => _busy = false);

    switch (result) {
      case AccountLinkSuccess(:final user):
        Analytics.accountLink(provider: 'google', result: 'success');
        // Local truth + the outbox event, atomically. Only after Firebase and
        // the backend have both accepted the link.
        await session.profileRepository.markAccountLinked(
          provider: 'google',
          displayName: user.displayName,
          photoUrl: user.photoUrl,
        );
        session.syncWorker.requestSync();
        await profileCubit.refresh();
        if (!mounted) return;
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Account linked. Your progress is safe now, partner.',
              ),
            ),
          );

      case AccountLinkCancelled():
        // Backed out of the picker — say nothing.
        Analytics.accountLink(provider: 'google', result: 'cancelled');

      case AccountLinkCredentialInUse(:final email):
        Analytics.accountLink(provider: 'google', result: 'credential_in_use');
        await _showConflictDialog(email);

      case AccountLinkFailed(:final message):
        Analytics.accountLink(provider: 'google', result: 'failed');
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// The one case we cannot resolve for them: that Google account already has
  /// its own Deadbounce progress, and we cannot merge two histories. Spell out
  /// exactly what is lost before offering the switch.
  Future<void> _showConflictDialog(String? email) async {
    final who = (email == null || email.isEmpty) ? 'That Google account' : email;
    final textTheme = Theme.of(context).textTheme;

    final switchAccounts = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.ink800,
        title: const Text('ALREADY CLAIMED'),
        content: Text(
          '$who already has its own Deadbounce progress.\n\n'
          'We can\'t merge two sets of progress. You can keep playing as a '
          'guest on this device, or sign in to that account instead — but this '
          "device's guest progress would be left behind.",
          style: textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('KEEP GUEST PROGRESS'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('SIGN IN INSTEAD'),
          ),
        ],
      ),
    );

    if (switchAccounts != true || !mounted) return;

    final authCubit = context.read<AuthCubit>();
    setState(() => _busy = true);
    // Signing in with the existing Google identity swaps the Firebase UID, so
    // _SessionScope tears this session down and builds the other account's.
    // Leave the screen first — it belongs to the session being disposed.
    await authCubit.signInWithGoogle();
    if (!mounted) return;
    setState(() => _busy = false);
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return DbSecondaryButton(
      label: 'LINK AN ACCOUNT',
      icon: Icons.link,
      loading: _busy,
      onPressed: _link,
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.data});

  final ProfileData data;

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
      ('Time in the dust', _fmt(data.totalPlayTime)),
    ];

    return Column(
      children: [
        for (final (label, value) in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.ink800.withValues(alpha: 0.8),
                borderRadius: AppRadii.mdAll,
                border: Border.all(color: AppColors.outlineFaint),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(value, style: Theme.of(context).textTheme.titleMedium),
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
