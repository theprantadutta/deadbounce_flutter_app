import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/meta_scaffold.dart';
import '../domain/entities/leaderboard_board.dart';
import 'cubit/leaderboard_cubit.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          LeaderboardCubit(context.sessionDependencies.leaderboardRepository)
            ..selectTab(LeaderboardTab.daily),
      child: const _LeaderboardView(),
    );
  }
}

class _LeaderboardView extends StatelessWidget {
  const _LeaderboardView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: LeaderboardTab.values.length,
      child: MetaScaffold(
        title: 'LEADERBOARDS',
        bottom: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          indicatorColor: AppColors.amber400,
          labelColor: AppColors.amber300,
          unselectedLabelColor: AppColors.ink300,
          onTap: (i) =>
              context.read<LeaderboardCubit>().selectTab(LeaderboardTab.values[i]),
          tabs: [
            for (final tab in LeaderboardTab.values) Tab(text: tab.label),
          ],
        ),
        child: BlocBuilder<LeaderboardCubit, LeaderboardState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: switch (state.status) {
                LeaderboardStatus.loading =>
                  const Center(child: CircularProgressIndicator()),
                LeaderboardStatus.error => _Empty(
                    message: state.error ??
                        'No gunslingers on the board yet. Draw first.',
                  ),
                LeaderboardStatus.ready =>
                  _BoardList(board: state.board, refreshing: state.refreshing),
              },
            );
          },
        ),
      ),
    );
  }
}

class _BoardList extends StatelessWidget {
  const _BoardList({required this.board, required this.refreshing});

  final LeaderboardBoard? board;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (board == null || board!.isEmpty) {
      return const _Empty(
          message: 'No gunslingers on the board yet. Draw first.');
    }

    return Column(
      children: [
        if (board!.lastSynced != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (refreshing)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  )
                else
                  const Icon(Icons.cloud_done,
                      size: 13, color: AppColors.ink300),
                const SizedBox(width: 6),
                Text(
                  refreshing
                      ? 'Refreshing…'
                      : 'Synced ${_ago(board!.lastSynced!)}',
                  style: textTheme.labelSmall,
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            itemCount: board!.rows.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, i) => _RankRow(row: board!.rows[i]),
          ),
        ),
        if (board!.shouldPinPlayer)
          _PinnedPlayer(
            rank: board!.playerRank!,
            score: board!.playerScore ?? 0,
          ),
      ],
    );
  }

  static String _ago(DateTime when) {
    final d = DateTime.now().toUtc().difference(when);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.row});

  final LeaderboardRow row;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final medal = switch (row.rank) {
      1 => AppColors.amber400,
      2 => AppColors.ink100,
      3 => AppColors.amber700,
      _ => null,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: row.isPlayer
            ? AppColors.amber900.withValues(alpha: 0.35)
            : AppColors.ink800.withValues(alpha: 0.8),
        borderRadius: AppRadii.mdAll,
        border: Border.all(
          color: row.isPlayer ? AppColors.amber500 : AppColors.outlineFaint,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${row.rank}',
              style: textTheme.titleMedium?.copyWith(color: medal),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              row.username,
              style: textTheme.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('${row.score}', style: textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _PinnedPlayer extends StatelessWidget {
  const _PinnedPlayer({required this.rank, required this.score});

  final int rank;
  final int score;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.amber900.withValues(alpha: 0.35),
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: AppColors.amber500),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('$rank', style: textTheme.titleMedium),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text('YOU', style: textTheme.titleSmall)),
          Text('$score', style: textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_outlined,
                size: 48, color: AppColors.ink400),
            const SizedBox(height: AppSpacing.md),
            Text(message,
                style: textTheme.bodyLarge, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
