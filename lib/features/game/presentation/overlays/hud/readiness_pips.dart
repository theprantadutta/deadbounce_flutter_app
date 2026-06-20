import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../game/hud_model.dart';

/// Subtle fire/dash readiness near the thumb zone: a fire pip that fills as
/// the shot cooldown recovers, and a dash pip that's lit when available.
/// Informational and unobtrusive — never blocks the arena.
class ReadinessPips extends StatelessWidget {
  const ReadinessPips({super.key, required this.hud});

  final HudModel hud;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<double>(
            valueListenable: hud.fireCharge,
            builder: (context, charge, _) => _Pip(
              icon: Icons.bolt,
              progress: charge,
              ready: charge >= 1,
              readyColor: AppColors.amber400,
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<bool>(
            valueListenable: hud.dashReady,
            builder: (context, ready, _) => _Pip(
              icon: Icons.swap_horiz,
              progress: ready ? 1 : 0,
              ready: ready,
              readyColor: AppColors.blue400,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pip extends StatelessWidget {
  const _Pip({
    required this.icon,
    required this.progress,
    required this.ready,
    required this.readyColor,
  });

  final IconData icon;
  final double progress;
  final bool ready;
  final Color readyColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 2,
              backgroundColor: AppColors.ink600,
              valueColor: AlwaysStoppedAnimation<Color>(
                ready ? readyColor : AppColors.ink300,
              ),
            ),
          ),
          Icon(
            icon,
            size: 13,
            color: ready ? readyColor : AppColors.ink300,
          ),
        ],
      ),
    );
  }
}
