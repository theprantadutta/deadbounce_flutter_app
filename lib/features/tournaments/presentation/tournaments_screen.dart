import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/meta_scaffold.dart';
import '../domain/entities/tournament.dart';
import 'cubit/tournaments_cubit.dart';
import 'widgets/tournament_card.dart';

class TournamentsScreen extends StatelessWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.sessionDependencies;
    return BlocProvider(
      create: (_) => TournamentsCubit(
        repository: session.tournamentRepository,
        syncWorker: session.syncWorker,
      ),
      child: const _TournamentsView(),
    );
  }
}

class _TournamentsView extends StatelessWidget {
  const _TournamentsView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MetaScaffold(
      title: 'TOURNAMENTS',
      child: BlocBuilder<TournamentsCubit, TournamentsState>(
        builder: (context, state) {
          if (state.status == TournamentsStatus.loading &&
              state.tournaments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final groups = state.byCadence;
          return RefreshIndicator(
            onRefresh: context.read<TournamentsCubit>().refresh,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              children: [
                if (state.offline) const _OfflineBanner(),
                if (groups.isEmpty)
                  _Empty(textTheme: textTheme)
                else
                  for (final entry in groups.entries) ...[
                    _SectionHeader(entry.key.label),
                    for (final t in entry.value) ...[
                      TournamentCard(
                        tournament: t,
                        onJoin: () => _join(context, t),
                        onPlay: () => context
                            .push('${Routes.tournamentRun}/${t.id}'),
                        onClaim: () => _claim(context, t),
                        onOpen: () =>
                            context.push('${Routes.tournamentDetail}/${t.id}'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _join(BuildContext context, Tournament t) async {
    final cubit = context.read<TournamentsCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.ink800,
        title: Text('Join ${t.name}?'),
        content: Text(
            'Entry costs ${t.entryFeeCoins} coins. Play as many times as you '
            'like before it ends — your best score counts.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('CANCEL')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('JOIN')),
        ],
      ),
    );
    if (confirmed != true) return;

    final error = await cubit.join(t.id);
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(error ?? "You're in. Good luck, partner."),
      ));
  }

  Future<void> _claim(BuildContext context, Tournament t) async {
    final messenger = ScaffoldMessenger.of(context);
    await context.read<TournamentsCubit>().claim(t);
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text('Claimed ${t.rewardCoins} coins. Well shot.'),
      ));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.ink800.withValues(alpha: 0.8),
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: AppColors.outlineFaint),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 18, color: AppColors.ink300),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              "You're offline — showing the last synced tournaments.",
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.textTheme});
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_outlined,
              size: 48, color: AppColors.ink300),
          const SizedBox(height: AppSpacing.md),
          Text('No tournaments running right now.',
              style: textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),
          Text('Check back soon — new ones drop daily.',
              style: textTheme.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
