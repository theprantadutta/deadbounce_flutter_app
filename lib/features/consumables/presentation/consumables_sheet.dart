import 'package:flutter/material.dart';

import '../../../app.dart';
import '../../../core/analytics/analytics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/db_button.dart';
import '../domain/consumable_catalog.dart';
import '../domain/repositories/consumables_repository.dart';

/// The pre-run loadout sheet: buy one-run items and pick which to take.
///
/// Opened from the Home screen before a normal run. Returns the chosen item
/// ids, or null if the player backed out (which must NOT start a run).
///
/// **Skipped entirely when the player holds no stock** (see
/// [maybePickConsumables]). The fastest path from Home to playing has to stay
/// one tap for everyone who hasn't bought in — a shop everybody must walk
/// through before every run would tax the "one more run" loop, which is the
/// loop the whole game depends on.
Future<List<String>?> showConsumablesSheet(BuildContext context) {
  return showModalBottomSheet<List<String>>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _ConsumablesSheet(
      repository: context.sessionDependencies.consumablesRepository,
    ),
  );
}

/// Shows the loadout sheet only if there is something to load out with.
///
/// Returns the chosen ids (possibly empty) to start a run, or null when the
/// player dismissed the sheet — in which case the run must NOT start, or a
/// stray back-swipe would silently launch one.
Future<List<String>?> maybePickConsumables(BuildContext context) async {
  final repository = context.sessionDependencies.consumablesRepository;
  final stock = await repository.stock();
  final holdsSomething = stock.values.any((count) => count > 0);
  if (!context.mounted) return null;

  // Nothing to choose from — go straight to the run rather than showing an
  // empty shop to someone who just wants to play.
  if (!holdsSomething) return const <String>[];

  return showConsumablesSheet(context);
}

class _ConsumablesSheet extends StatefulWidget {
  const _ConsumablesSheet({required this.repository});

  final ConsumablesRepository repository;

  @override
  State<_ConsumablesSheet> createState() => _ConsumablesSheetState();
}

class _ConsumablesSheetState extends State<_ConsumablesSheet> {
  final Set<String> _selected = {};
  String? _busyId;

  Future<void> _buy(Consumable item) async {
    if (_busyId != null) return;
    setState(() => _busyId = item.id);
    final messenger = ScaffoldMessenger.of(context);

    String? error;
    try {
      await widget.repository.buy(item);
      Analytics.shopPurchase(
        shop: 'consumables',
        itemId: item.id,
        cost: item.cost,
      );
    } on ConsumablePurchaseException catch (e) {
      error = e.message;
    } catch (_) {
      error = 'Purchase failed. Try again.';
    }

    if (!mounted) return;
    setState(() => _busyId = null);
    if (error != null) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _toggle(String id, int held) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else if (held > 0 && _selected.length < ConsumableCatalog.maxEquipped) {
        _selected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return StreamBuilder<Map<String, int>>(
      stream: widget.repository.watchStock(),
      builder: (context, snapshot) {
        final stock = snapshot.data ?? const <String, int>{};

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.ink900,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: AppColors.amber500)),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SADDLE UP', style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Take up to ${ConsumableCatalog.maxEquipped} into this run. '
                  'They are spent when the run starts.',
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.ink200),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final item in ConsumableCatalog.all) ...[
                  _ConsumableRow(
                    item: item,
                    held: stock[item.id] ?? 0,
                    selected: _selected.contains(item.id),
                    busy: _busyId == item.id,
                    // Full loadout: everything unselected stops being tappable
                    // rather than silently doing nothing on tap.
                    selectable: _selected.contains(item.id) ||
                        _selected.length < ConsumableCatalog.maxEquipped,
                    onBuy: () => _buy(item),
                    onToggle: () => _toggle(item.id, stock[item.id] ?? 0),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                const SizedBox(height: AppSpacing.sm),
                DbPrimaryButton(
                  label: _selected.isEmpty
                      ? 'RIDE OUT EMPTY-HANDED'
                      : 'RIDE OUT (${_selected.length})',
                  onPressed: () =>
                      Navigator.pop(context, _selected.toList()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConsumableRow extends StatelessWidget {
  const _ConsumableRow({
    required this.item,
    required this.held,
    required this.selected,
    required this.busy,
    required this.selectable,
    required this.onBuy,
    required this.onToggle,
  });

  final Consumable item;
  final int held;
  final bool selected;
  final bool busy;
  final bool selectable;
  final VoidCallback onBuy;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final owned = held > 0;
    final canTap = owned && selectable;

    return Opacity(
      opacity: owned ? 1 : 0.6,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.ink800,
          borderRadius: AppRadii.mdAll,
          border: Border.all(
            color: selected ? AppColors.amber500 : AppColors.ink500,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: canTap ? onToggle : null,
              borderRadius: AppRadii.mdAll,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  selected ? Icons.check_circle : item.icon,
                  color: selected ? AppColors.amber400 : AppColors.ink200,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child:
                            Text(item.name, style: textTheme.labelLarge),
                      ),
                      if (owned) ...[
                        const SizedBox(width: 6),
                        Text('×$held',
                            style: textTheme.labelMedium
                                ?.copyWith(color: AppColors.amber300)),
                      ],
                    ],
                  ),
                  Text(
                    item.blurb,
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.ink200),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            DbSecondaryButton(
              label: '${item.cost}',
              icon: Icons.add,
              loading: busy,
              onPressed: onBuy,
            ),
          ],
        ),
      ),
    );
  }
}
