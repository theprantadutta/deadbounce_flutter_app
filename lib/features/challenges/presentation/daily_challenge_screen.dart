import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/db_button.dart';
import '../../../core/widgets/meta_scaffold.dart';
import '../../../core/widgets/utc_midnight_countdown.dart';
import 'cubit/daily_challenge_cubit.dart';

class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DailyChallengeCubit(context.sessionDependencies.dailyChallengeRepository)
            ..load(),
      child: const _DailyChallengeView(),
    );
  }
}

class _DailyChallengeView extends StatelessWidget {
  const _DailyChallengeView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MetaScaffold(
      title: 'DAILY CHALLENGE',
      child: BlocBuilder<DailyChallengeCubit, DailyChallengeState>(
        builder: (context, state) {
          return switch (state) {
            DailyChallengeLoading() =>
              const Center(child: CircularProgressIndicator()),
            DailyChallengeFailure(:final message) => _Message(message),
            DailyChallengeLoaded(:final overview) => ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.blue900.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.blue600),
                      ),
                      child: const Icon(Icons.bolt,
                          color: AppColors.blue300, size: 40),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(overview.definition.name,
                      style: textTheme.headlineLarge,
                      textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.xs),
                  Text(overview.definition.tagline,
                      style: textTheme.bodyLarge
                          ?.copyWith(color: AppColors.amber300),
                      textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.xl),
                  _RulesCard(rules: overview.definition.rules),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'YOUR BEST',
                          value: overview.bestScore?.toString() ?? '—',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StatCard(
                          label: 'ATTEMPTS',
                          value: '${overview.attemptCount}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: UtcMidnightCountdown(
                      prefix: 'New challenge in ',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DbPrimaryButton(
                    label: 'PLAY CHALLENGE',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => context.push(Routes.dailyChallengeRun),
                  ),
                ],
              ),
          };
        },
      ),
    );
  }
}

class _RulesCard extends StatelessWidget {
  const _RulesCard({required this.rules});

  final List<String> rules;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.ink800.withValues(alpha: 0.85),
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.outlineFaint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('THE RULES', style: textTheme.labelMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final rule in rules)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.chevron_right,
                      color: AppColors.amber400, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: Text(rule, style: textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.ink800.withValues(alpha: 0.85),
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.outlineFaint),
      ),
      child: Column(
        children: [
          Text(value, style: textTheme.headlineMedium),
          const SizedBox(height: 2),
          Text(label, style: textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
