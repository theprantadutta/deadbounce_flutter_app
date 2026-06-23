import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/meta_scaffold.dart';
import '../../game/engine/upgrades/upgrade_catalog.dart';
import '../domain/entities/game_statistics.dart';
import 'cubit/statistics_cubit.dart';

/// Lifetime stats: totals, personal bests, kills-by-enemy breakdown, and the
/// most-picked upgrade. Reads the local Drift aggregates via [StatisticsCubit].
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          StatisticsCubit(context.sessionDependencies.statisticsRepository)
            ..load(),
      child: const _StatisticsView(),
    );
  }
}

class _StatisticsView extends StatelessWidget {
  const _StatisticsView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MetaScaffold(
      title: 'STATISTICS',
      child: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          return switch (state) {
            StatisticsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            StatisticsError(:final message) => Center(
              child: Text(message, style: textTheme.bodyLarge),
            ),
            StatisticsLoaded(:final stats) when !stats.hasPlayed =>
              const _EmptyState(),
            StatisticsLoaded(:final stats) => _StatsBody(stats: stats),
          };
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.query_stats, size: 56, color: AppColors.ink400),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No runs logged yet.',
            style: textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Play a round and your legend starts here, partner.',
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats});

  final GameStatistics stats;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      children: [
        // Headline totals.
        Row(
          children: [
            Expanded(
              child: _HeroCard(
                label: 'RUNS',
                value: _fmtInt(stats.runsPlayed),
                icon: Icons.replay,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _HeroCard(
                label: 'KILLS',
                value: _fmtInt(stats.totalKills),
                icon: Icons.whatshot,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _HeroCard(
                label: 'IN THE DUST',
                value: _fmtDuration(stats.totalPlayTime),
                icon: Icons.schedule,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _Section(
          label: 'LIFETIME',
          rows: [
            ('Runs played', _fmtInt(stats.runsPlayed)),
            ('Total kills', _fmtInt(stats.totalKills)),
            ('Waves cleared', _fmtInt(stats.totalWavesCleared)),
            ('Coins earned', _fmtInt(stats.totalCoinsEarned)),
            ('Time in the dust', _fmtDuration(stats.totalPlayTime)),
            ('Avg kills / run', stats.avgKillsPerRun.toStringAsFixed(1)),
            ('Avg waves / run', stats.avgWavesPerRun.toStringAsFixed(1)),
            ('Avg coins / run', stats.avgCoinsPerRun.toStringAsFixed(0)),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _Section(
          label: 'PERSONAL BESTS',
          rows: [
            ('Best score', _fmtInt(stats.bestScore)),
            ('Best chain', 'x${stats.bestChain}'),
            ('Hottest bounce kill', '${stats.bestBounceKill} bounces'),
            ('Furthest wave', '${stats.bestWave}'),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _EnemyBreakdown(enemyKills: stats.enemyKills),
        const SizedBox(height: AppSpacing.lg),
        _FavoriteIron(upgradeId: stats.favoriteUpgradeId),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.ink800.withValues(alpha: 0.8),
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: AppColors.outlineFaint),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.amber400, size: 20),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: textTheme.titleMedium),
          ),
          const SizedBox(height: 2),
          Text(label, style: textTheme.labelSmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.rows});

  final String label;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final (rowLabel, value) in rows)
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
                  Expanded(child: Text(rowLabel, style: textTheme.bodyMedium)),
                  Text(value, style: textTheme.titleMedium),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _EnemyBreakdown extends StatelessWidget {
  const _EnemyBreakdown({required this.enemyKills});

  final Map<String, int> enemyKills;

  // Display order + label + icon for every enemy id the game records.
  static const List<(String, String, IconData)> _enemies = [
    ('drifter', 'Drifters', Icons.blur_on),
    ('small_drifter', 'Splinters', Icons.grain),
    ('charger', 'Chargers', Icons.bolt),
    ('splitter', 'Splitters', Icons.call_split),
    ('turret', 'Turrets', Icons.gps_fixed),
    ('warden', 'Wardens', Icons.shield),
    ('powderkeg', 'Powderkegs', Icons.local_fire_department),
    ('sawbones', 'Sawbones', Icons.healing),
    ('ironhide', 'Ironhides', Icons.security),
    ('mirror', 'Mirrors', Icons.flip),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final maxKills = enemyKills.values.fold(0, (m, v) => v > m ? v : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('KILLS BY ENEMY', style: textTheme.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.ink800.withValues(alpha: 0.8),
            borderRadius: AppRadii.lgAll,
            border: Border.all(color: AppColors.outlineFaint),
          ),
          child: Column(
            children: [
              for (final (id, label, icon) in _enemies)
                _EnemyRow(
                  label: label,
                  icon: icon,
                  count: enemyKills[id] ?? 0,
                  fraction: maxKills == 0
                      ? 0
                      : (enemyKills[id] ?? 0) / maxKills,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EnemyRow extends StatelessWidget {
  const _EnemyRow({
    required this.label,
    required this.icon,
    required this.count,
    required this.fraction,
  });

  final String label;
  final IconData icon;
  final int count;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.blue300),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(label, style: textTheme.bodyMedium)),
                    Text(
                      '$count',
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.amber300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: fraction.clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: AppColors.ink700,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.amber500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteIron extends StatelessWidget {
  const _FavoriteIron({required this.upgradeId});

  final String? upgradeId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    String name = 'None yet';
    String flavor = 'Pick more upgrades to crown a favorite.';
    final id = upgradeId;
    if (id != null) {
      final matches = UpgradeCatalog.all.where((c) => c.id == id);
      if (matches.isNotEmpty) {
        name = matches.first.name;
        flavor = matches.first.flavor;
      }
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.ink800.withValues(alpha: 0.85),
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.amber600),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: AppColors.amber400, size: 26),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FAVORITE IRON', style: textTheme.labelSmall),
                Text(name, style: textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(flavor, style: textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _fmtInt(int n) {
  // Thousands separators in the western voice. Group only the digits so a
  // negative sign never gets a stray comma.
  final neg = n < 0;
  final s = n.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return neg ? '-$buffer' : buffer.toString();
}

String _fmtDuration(Duration d) {
  if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
  if (d.inMinutes > 0) return '${d.inMinutes}m';
  return '${d.inSeconds}s';
}
