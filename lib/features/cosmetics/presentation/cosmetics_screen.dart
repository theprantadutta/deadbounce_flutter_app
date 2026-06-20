import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/meta_scaffold.dart';
import '../domain/cosmetic_catalog.dart';
import 'cubit/cosmetics_cubit.dart';

/// The Outfitter: spend coins on visual-only trails, gunslinger skins, and
/// arena themes. Buying and equipping sync (survive reinstall).
class CosmeticsScreen extends StatelessWidget {
  const CosmeticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.sessionDependencies;
    return BlocProvider(
      create: (_) => CosmeticsCubit(
        cosmetics: session.cosmeticsRepository,
        wallet: session.walletRepository,
      )..load(),
      child: const _OutfitterView(),
    );
  }
}

class _OutfitterView extends StatelessWidget {
  const _OutfitterView();

  Future<void> _buy(BuildContext context, Cosmetic c) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<CosmeticsCubit>().buy(c);
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(error ?? '${c.name} acquired — equip it, partner.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return MetaScaffold(
      title: 'THE OUTFITTER',
      child: BlocBuilder<CosmeticsCubit, CosmeticsState>(
        builder: (context, state) {
          if (state is! CosmeticsReady) {
            return const Center(child: CircularProgressIndicator());
          }
          return DefaultTabController(
            length: CosmeticSlot.values.length,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                _BalanceHeader(balance: state.balance),
                const SizedBox(height: AppSpacing.sm),
                TabBar(
                  labelColor: AppColors.amber300,
                  unselectedLabelColor: AppColors.ink300,
                  indicatorColor: AppColors.amber400,
                  tabs: [
                    for (final slot in CosmeticSlot.values)
                      Tab(text: slot.label, icon: Icon(slot.icon, size: 18)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      for (final slot in CosmeticSlot.values)
                        _SlotList(
                          slot: slot,
                          state: state,
                          onBuy: (c) => _buy(context, c),
                          onEquip: (c) =>
                              context.read<CosmeticsCubit>().equip(c),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SlotList extends StatelessWidget {
  const _SlotList({
    required this.slot,
    required this.state,
    required this.onBuy,
    required this.onEquip,
  });

  final CosmeticSlot slot;
  final CosmeticsReady state;
  final void Function(Cosmetic) onBuy;
  final void Function(Cosmetic) onEquip;

  @override
  Widget build(BuildContext context) {
    final equippedId =
        state.equipped[slot] ?? CosmeticCatalog.defaultFor(slot).id;
    final items = CosmeticCatalog.forSlot(slot);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        for (final c in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _CosmeticTile(
              cosmetic: c,
              owned: c.isFree || state.owned.contains(c.id),
              equipped: c.id == equippedId,
              balance: state.balance,
              onBuy: () => onBuy(c),
              onEquip: () => onEquip(c),
            ),
          ),
      ],
    );
  }
}

class _CosmeticTile extends StatelessWidget {
  const _CosmeticTile({
    required this.cosmetic,
    required this.owned,
    required this.equipped,
    required this.balance,
    required this.onBuy,
    required this.onEquip,
  });

  final Cosmetic cosmetic;
  final bool owned;
  final bool equipped;
  final int balance;
  final VoidCallback onBuy;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.ink800.withValues(alpha: 0.85),
        borderRadius: AppRadii.lgAll,
        border: Border.all(
          color: equipped
              ? AppColors.amber500.withValues(alpha: 0.6)
              : AppColors.outlineFaint,
        ),
      ),
      child: Row(
        children: [
          _Swatch(cosmetic: cosmetic),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cosmetic.name, style: textTheme.titleSmall),
                Text(cosmetic.blurb, style: textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _ActionButton(
            owned: owned,
            equipped: equipped,
            cost: cosmetic.cost,
            affordable: balance >= cosmetic.cost,
            onBuy: onBuy,
            onEquip: onEquip,
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.cosmetic});
  final Cosmetic cosmetic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        borderRadius: AppRadii.mdAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cosmetic.primary, cosmetic.secondary],
        ),
        border: Border.all(color: AppColors.ink600),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.owned,
    required this.equipped,
    required this.cost,
    required this.affordable,
    required this.onBuy,
    required this.onEquip,
  });

  final bool owned;
  final bool equipped;
  final int cost;
  final bool affordable;
  final VoidCallback onBuy;
  final VoidCallback onEquip;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (equipped) {
      return Container(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: AppRadii.pillAll,
          border: Border.all(color: AppColors.success.withValues(alpha: 0.6)),
        ),
        child: Text('EQUIPPED',
            style: textTheme.labelMedium?.copyWith(color: AppColors.success)),
      );
    }

    if (owned) {
      return _Pill(
        onTap: onEquip,
        color: AppColors.blue500,
        textColor: AppColors.blue200,
        child: Text('EQUIP',
            style: textTheme.labelLarge?.copyWith(color: AppColors.blue200)),
      );
    }

    return Opacity(
      opacity: affordable ? 1 : 0.5,
      child: _Pill(
        onTap: affordable ? onBuy : null,
        color: AppColors.amber500,
        textColor: AppColors.amber200,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.paid, color: AppColors.amber400, size: 16),
            const SizedBox(width: 4),
            Text('$cost',
                style:
                    textTheme.labelLarge?.copyWith(color: AppColors.amber200)),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.onTap,
    required this.color,
    required this.textColor,
    required this.child,
  });

  final VoidCallback? onTap;
  final Color color;
  final Color textColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.pillAll,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: AppRadii.pillAll,
            border: Border.all(color: color.withValues(alpha: 0.6)),
          ),
          child: child,
        ),
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
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.paid, color: AppColors.amber400, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Text(_fmt(balance),
                style: textTheme.titleLarge
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

String _fmt(int n) {
  final s = n.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
