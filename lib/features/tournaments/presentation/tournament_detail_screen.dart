import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/meta_scaffold.dart';
import '../domain/entities/tournament.dart';
import '../domain/repositories/tournament_repository.dart';
import 'widgets/tournament_countdown.dart';

/// Full tournament view: rules, the primary action (join/play/claim), and the
/// live leaderboard. Reads cache-first state from the repo stream so it stays
/// in sync after join/claim.
class TournamentDetailScreen extends StatelessWidget {
  const TournamentDetailScreen({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  Widget build(BuildContext context) {
    final repo = context.sessionDependencies.tournamentRepository;
    return MetaScaffold(
      title: 'TOURNAMENT',
      child: StreamBuilder<List<Tournament>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          final tournament = snapshot.data
              ?.where((t) => t.id == tournamentId)
              .cast<Tournament?>()
              .firstWhere((_) => true, orElse: () => null);
          if (tournament == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return _Body(tournament: tournament);
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.tournament});

  final Tournament tournament;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final t = tournament;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      children: [
        Text(t.name, style: textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(t.tagline, style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const Icon(Icons.schedule, size: 15, color: AppColors.ink300),
            const SizedBox(width: 4),
            TournamentCountdown(endsAt: t.endsAt, style: textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Rules.
        Text('THE RULES', style: textTheme.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final line in _ruleLines(t)) _RuleRow(line),
        const SizedBox(height: AppSpacing.lg),

        // Action / result.
        if (t.isEnded)
          _ResultPanel(tournament: t)
        else
          _PrimaryAction(tournament: t),
        const SizedBox(height: AppSpacing.lg),

        // Leaderboard.
        Text('STANDINGS', style: textTheme.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        _Leaderboard(tournamentId: t.id),
      ],
    );
  }

  static List<String> _ruleLines(Tournament t) {
    final c = t.toChallengeConfig();
    final lines = <String>['Same seeded board for everyone — pure skill.'];
    if (c.startingHearts != null) {
      lines.add(c.startingHearts == 1
          ? 'Start with a single heart.'
          : 'Start with ${c.startingHearts} hearts.');
    }
    if (c.forcedEnemyType != null) {
      lines.add('${_enemyLabel(c.forcedEnemyType!.name)} every wave.');
    }
    if (c.extraWallDamage > 0) {
      lines.add('+${c.extraWallDamage} wall damage on every bullet.');
    }
    if (c.scoreMultiplier != 1) {
      lines.add('Score ×${_trim(c.scoreMultiplier)}.');
    }
    if (c.randomUpgrades) {
      lines.add('Upgrades are dealt at random — no picking.');
    }
    return lines;
  }

  static String _enemyLabel(String name) {
    final spaced = name.replaceAllMapped(
        RegExp('([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}');
    return '${spaced[0].toUpperCase()}${spaced.substring(1)}s';
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toString();
}

class _RuleRow extends StatelessWidget {
  const _RuleRow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.chevron_right, size: 16, color: AppColors.amber400),
          const SizedBox(width: 4),
          Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.tournament});
  final Tournament tournament;

  @override
  Widget build(BuildContext context) {
    final joined = tournament.joined;
    return _BigButton(
      label: joined ? 'PLAY' : 'JOIN · ${tournament.entryFeeCoins} COINS',
      icon: joined ? Icons.play_arrow_rounded : Icons.login,
      onTap: () => joined
          ? context.push('${Routes.tournamentRun}/${tournament.id}')
          : _join(context, tournament),
    );
  }

  Future<void> _join(BuildContext context, Tournament t) async {
    final repo = context.sessionDependencies.tournamentRepository;
    final syncWorker = context.sessionDependencies.syncWorker;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.ink800,
        title: Text('Join ${t.name}?'),
        content: Text('Entry costs ${t.entryFeeCoins} coins.'),
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
    String? error;
    try {
      await repo.join(t.id);
      syncWorker.requestSync();
    } on TournamentException catch (e) {
      error = e.message;
    } on ApiException catch (e) {
      error = e.message;
    }
    messenger
      ..clearSnackBars()
      ..showSnackBar(
          SnackBar(content: Text(error ?? "You're in. Good luck, partner.")));
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.tournament});
  final Tournament tournament;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final t = tournament;
    final placed = t.joined && t.rank != null;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.ink800.withValues(alpha: 0.85),
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.amber600),
      ),
      child: Column(
        children: [
          Text('FINAL RESULT', style: textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            placed ? 'You placed #${t.rank}' : 'Tournament over',
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (placed) ...[
            const SizedBox(height: AppSpacing.xs),
            Text('Best score ${t.bestScore}',
                style: textTheme.bodySmall, textAlign: TextAlign.center),
          ],
          const SizedBox(height: AppSpacing.md),
          if (t.hasUnclaimedReward)
            _BigButton(
              label: 'CLAIM ${t.rewardCoins} COINS',
              icon: Icons.emoji_events,
              onTap: () => _claim(context, t),
            )
          else if (t.rewardClaimed)
            Text('Reward claimed. Well shot.',
                style: textTheme.labelMedium?.copyWith(color: AppColors.amber300))
          else
            Text('No reward this time — climb higher next round.',
                style: textTheme.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Future<void> _claim(BuildContext context, Tournament t) async {
    final repo = context.sessionDependencies.tournamentRepository;
    final syncWorker = context.sessionDependencies.syncWorker;
    final messenger = ScaffoldMessenger.of(context);
    await repo.claimReward(t);
    syncWorker.requestSync();
    messenger
      ..clearSnackBars()
      ..showSnackBar(
          SnackBar(content: Text('Claimed ${t.rewardCoins} coins. Well shot.')));
  }
}

class _Leaderboard extends StatelessWidget {
  const _Leaderboard({required this.tournamentId});
  final String tournamentId;

  @override
  Widget build(BuildContext context) {
    final repo = context.sessionDependencies.tournamentRepository;
    return FutureBuilder<TournamentBoard>(
      future: repo.leaderboard(tournamentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final board = snapshot.data!;
        if (board.standings.isEmpty) {
          return Text('No scores posted yet — be the first.',
              style: Theme.of(context).textTheme.bodySmall);
        }
        return Column(
          children: [
            for (final s in board.standings) _StandingRow(standing: s),
            if (board.shouldPinPlayer)
              _StandingRow(
                standing: TournamentStanding(
                  rank: board.playerRank!,
                  userId: 'me',
                  username: 'You',
                  score: board.playerScore ?? 0,
                  isPlayer: true,
                ),
                pinned: true,
              ),
          ],
        );
      },
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({required this.standing, this.pinned = false});
  final TournamentStanding standing;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final highlight = standing.isPlayer;
    return Container(
      margin: EdgeInsets.only(top: pinned ? AppSpacing.sm : 4),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.amber500.withValues(alpha: 0.12)
            : AppColors.ink800.withValues(alpha: 0.7),
        borderRadius: AppRadii.mdAll,
        border: Border.all(
            color: highlight ? AppColors.amber600 : AppColors.outlineFaint),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('#${standing.rank}', style: textTheme.labelMedium),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(standing.username,
                style: textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Text('${standing.score}', style: textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton(
      {required this.label, required this.icon, required this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.amber500,
      borderRadius: AppRadii.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.mdAll,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.onAmber),
              const SizedBox(width: 6),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: AppColors.onAmber)),
            ],
          ),
        ),
      ),
    );
  }
}
