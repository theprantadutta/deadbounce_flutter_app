import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimens.dart';
import '../../game/hud_model.dart';
import '../upgrade_picker_overlay.dart';

/// A compact row of the drafted upgrades (icons + stack counts) so the
/// player can read their build at a glance mid-run. Long-press a chip to
/// see its name. Reuses `UpgradePickerOverlay.iconFor` for the icon map.
class UpgradeTray extends StatelessWidget {
  const UpgradeTray({super.key, required this.hud});

  final HudModel hud;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<HudUpgrade>>(
      valueListenable: hud.activeUpgrades,
      builder: (context, upgrades, _) {
        if (upgrades.isEmpty) return const SizedBox.shrink();
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final u in upgrades) _UpgradeChip(upgrade: u),
          ],
        );
      },
    );
  }
}

class _UpgradeChip extends StatelessWidget {
  const _UpgradeChip({required this.upgrade});
  final HudUpgrade upgrade;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: upgrade.stacks > 1
          ? '${upgrade.name} ×${upgrade.stacks}'
          : upgrade.name,
      triggerMode: TooltipTriggerMode.longPress,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.ink800.withValues(alpha: 0.7),
          borderRadius: AppRadii.smAll,
          border: Border.all(color: AppColors.ink500.withValues(alpha: 0.5)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              UpgradePickerOverlay.iconFor(upgrade.iconName),
              size: 16,
              color: AppColors.blue200,
            ),
            if (upgrade.stacks > 1)
              Positioned(
                right: -6,
                bottom: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: AppColors.amber500,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    '${upgrade.stacks}',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onAmber,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
