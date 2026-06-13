import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../engine/upgrades/upgrade_card.dart';

/// Wave-clear pick: 3 animated cards with rarity-colored borders/glow.
class UpgradePickerOverlay extends StatelessWidget {
  const UpgradePickerOverlay({
    super.key,
    required this.waveCleared,
    required this.choices,
    required this.onPick,
  });

  final int waveCleared;
  final List<UpgradeCard> choices;
  final ValueChanged<UpgradeCard> onPick;

  static Color rarityColor(UpgradeRarity rarity) => switch (rarity) {
        UpgradeRarity.common => AppColors.ink200,
        UpgradeRarity.rare => AppColors.blue400,
        UpgradeRarity.epic => AppColors.amber400,
      };

  static IconData iconFor(String name) => switch (name) {
        'bolt' => Icons.bolt,
        'visibility' => Icons.visibility,
        'circle' => Icons.circle,
        'paid' => Icons.paid,
        'sports_tennis' => Icons.sports_tennis,
        'local_fire_department' => Icons.local_fire_department,
        'my_location' => Icons.my_location,
        'favorite' => Icons.favorite,
        'graphic_eq' => Icons.graphic_eq,
        'call_split' => Icons.call_split,
        'blur_on' => Icons.blur_on,
        'shield' => Icons.shield,
        _ => Icons.star,
      };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: ColoredBox(
        color: Colors.black54,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('WAVE $waveCleared CLEARED',
                        style: textTheme.headlineMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Pick your iron.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    for (final (index, card) in choices.indexed) ...[
                      _UpgradeCardTile(
                        card: card,
                        delay: Duration(milliseconds: 120 * index),
                        onTap: () => onPick(card),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UpgradeCardTile extends StatefulWidget {
  const _UpgradeCardTile({
    required this.card,
    required this.delay,
    required this.onTap,
  });

  final UpgradeCard card;
  final Duration delay;
  final VoidCallback onTap;

  @override
  State<_UpgradeCardTile> createState() => _UpgradeCardTileState();
}

class _UpgradeCardTileState extends State<_UpgradeCardTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late final Animation<double> _in = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = UpgradePickerOverlay.rarityColor(widget.card.rarity);

    return ScaleTransition(
      scale: _in,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: AppRadii.lgAll,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.ink800.withValues(alpha: 0.92),
              borderRadius: AppRadii.lgAll,
              border: Border.all(color: color, width: 1.6),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.ink700,
                    borderRadius: AppRadii.mdAll,
                  ),
                  child: Icon(
                    UpgradePickerOverlay.iconFor(widget.card.iconName),
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(widget.card.name,
                                style: textTheme.titleMedium),
                          ),
                          Text(
                            widget.card.rarity.name.toUpperCase(),
                            style: textTheme.labelSmall
                                ?.copyWith(color: color),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(widget.card.flavor, style: textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
