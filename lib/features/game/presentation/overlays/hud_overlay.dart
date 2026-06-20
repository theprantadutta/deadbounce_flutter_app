import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../game/hud_model.dart';
import 'hud/boss_bar.dart';
import 'hud/chain_meter.dart';
import 'hud/command_bar.dart';
import 'hud/readiness_pips.dart';
import 'hud/upgrade_tray.dart';
import 'hud/wave_banner.dart';

/// The in-play HUD: a unified neon "command bar" up top (life | wave +
/// progress | score/coins/pause), a live chain meter and boss bar beneath
/// it, a transient wave banner, and a thumb-zone strip (drafted-upgrade
/// tray + fire/dash readiness). Everything listens per-value so only tiny
/// widgets rebuild at game speed — no full-overlay rebuilds.
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.hud, required this.onPause});

  final HudModel hud;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Column(
          children: [
            CommandBar(hud: hud, onPause: onPause),
            BossBar(hud: hud),
            const SizedBox(height: AppSpacing.xs),
            // Hero chain meter + the transient wave banner share the top
            // band over the arena. The banner ignores pointer events.
            Stack(
              alignment: Alignment.topCenter,
              children: [
                ChainMeter(hud: hud),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xl),
                  child: WaveBanner(hud: hud),
                ),
              ],
            ),
            const Spacer(),
            // Thumb-zone strip: build on the left, readiness on the right.
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: UpgradeTray(hud: hud)),
                const SizedBox(width: AppSpacing.xs),
                ReadinessPips(hud: hud),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
