import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../game/hud_model.dart';

/// A transient "WAVE N" banner that sweeps in at the start of each wave and
/// fades away, so the player feels the cadence without a modal. Re-keyed on
/// the wave value so it replays on every change.
class WaveBanner extends StatelessWidget {
  const WaveBanner({super.key, required this.hud});

  final HudModel hud;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return IgnorePointer(
      child: ValueListenableBuilder<int>(
        valueListenable: hud.wave,
        builder: (context, wave, _) {
          if (wave < 1) return const SizedBox.shrink();
          return Text(
            'WAVE $wave',
            key: ValueKey(wave),
            style: textTheme.displaySmall?.copyWith(
              color: AppColors.amber300,
              letterSpacing: 4,
              shadows: const [
                Shadow(color: Color(0x99FFB718), blurRadius: 24),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 200.ms)
              .slideY(begin: 0.4, end: 0, curve: Curves.easeOutCubic)
              .then(delay: 900.ms)
              .fadeOut(duration: 350.ms)
              .slideY(begin: 0, end: -0.2);
        },
      ),
    );
  }
}
