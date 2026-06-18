import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_effects.dart';
import '../../../core/widgets/meta_scaffold.dart';
import '../domain/meta_catalog.dart';
import 'cubit/gunsmith_cubit.dart';

/// The Gunsmith: spend coins on permanent run-long perks.
class GunsmithScreen extends StatelessWidget {
  const GunsmithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.sessionDependencies;
    return BlocProvider(
      create: (_) => GunsmithCubit(
        meta: session.metaRepository,
        wallet: session.walletRepository,
      )..load(),
      child: const _GunsmithView(),
    );
  }
}

class _GunsmithView extends StatelessWidget {
  const _GunsmithView();

  Future<void> _buy(BuildContext context, MetaPerk perk) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<GunsmithCubit>().buy(perk);
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(error ?? '${perk.name} acquired, partner.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MetaScaffold(
      title: 'THE GUNSMITH',
      child: BlocBuilder<GunsmithCubit, GunsmithState>(
        builder: (context, state) {
          if (state is! GunsmithReady) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            children: [
              _BalanceHeader(balance: state.balance),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Spend your bounty on permanent iron — it rides with you every run.',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final perk in MetaCatalog.all)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _PerkTile(
                    perk: perk,
                    level: state.owned[perk.id] ?? 0,
                    balance: state.balance,
                    onBuy: () => _buy(context, perk),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.amber500.withValues(alpha: 0.12),
          borderRadius: AppRadii.pillAll,
          border: Border.all(color: AppColors.amber500.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.amber500.withValues(alpha: 0.18),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.paid, color: AppColors.amber400, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Text(_fmt(balance),
                style: textTheme.headlineSmall
                    ?.copyWith(color: AppColors.amber200)),
            const SizedBox(width: AppSpacing.xs),
            Text('IN THE POKE',
                style: textTheme.labelSmall?.copyWith(color: AppColors.ink300)),
          ],
        ),
      ),
    );
  }
}

class _PerkTile extends StatelessWidget {
  const _PerkTile({
    required this.perk,
    required this.level,
    required this.balance,
    required this.onBuy,
  });

  final MetaPerk perk;
  final int level;
  final int balance;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final effects = Theme.of(context).extension<AppEffects>()!;
    final maxed = level >= perk.maxLevel;
    final cost = perk.costForLevel(level);
    final affordable = balance >= cost;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.ink800.withValues(alpha: 0.85),
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.outlineFaint),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: effects.brandGradient,
              borderRadius: AppRadii.mdAll,
            ),
            child: Icon(perk.icon, color: AppColors.ink950, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(perk.name, style: textTheme.titleSmall),
                Text(perk.blurb, style: textTheme.bodySmall),
                const SizedBox(height: 6),
                _Pips(level: level, max: perk.maxLevel),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _BuyButton(
            maxed: maxed,
            cost: cost,
            affordable: affordable,
            onBuy: onBuy,
          ),
        ],
      ),
    );
  }
}

class _Pips extends StatelessWidget {
  const _Pips({required this.level, required this.max});

  final int level;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < max; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < level ? AppColors.amber400 : Colors.transparent,
                border: Border.all(
                  color: i < level ? AppColors.amber400 : AppColors.ink400,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BuyButton extends StatelessWidget {
  const _BuyButton({
    required this.maxed,
    required this.cost,
    required this.affordable,
    required this.onBuy,
  });

  final bool maxed;
  final int cost;
  final bool affordable;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (maxed) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: AppRadii.pillAll,
          border: Border.all(color: AppColors.success.withValues(alpha: 0.6)),
        ),
        child: Text('MAXED',
            style:
                textTheme.labelMedium?.copyWith(color: AppColors.success)),
      );
    }

    final enabled = affordable;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onBuy : null,
          borderRadius: AppRadii.pillAll,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.amber500.withValues(alpha: 0.14),
              borderRadius: AppRadii.pillAll,
              border:
                  Border.all(color: AppColors.amber500.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.paid, color: AppColors.amber400, size: 16),
                const SizedBox(width: 4),
                Text('$cost',
                    style: textTheme.labelLarge
                        ?.copyWith(color: AppColors.amber200)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _fmt(int n) {
  final s = n.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
