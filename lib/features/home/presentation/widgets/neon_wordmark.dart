import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';

/// "DEADBOUNCE" rendered as a neon sign: amber glow halo with a slow white
/// shimmer sweeping across like a buzzing tube. Scales down to one line on
/// narrow screens.
class NeonWordmark extends StatelessWidget {
  const NeonWordmark({super.key, required this.style});

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final neon = (style ?? const TextStyle()).copyWith(
      color: AppColors.amber200,
      letterSpacing: 1.5,
      shadows: [
        Shadow(color: AppColors.amber500.withValues(alpha: 0.95), blurRadius: 14),
        Shadow(color: AppColors.amber500.withValues(alpha: 0.55), blurRadius: 30),
        Shadow(color: AppColors.blue500.withValues(alpha: 0.30), blurRadius: 46),
      ],
    );

    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text('DEADBOUNCE', style: neon, maxLines: 1),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          delay: 1800.ms,
          duration: 1500.ms,
          color: Colors.white.withValues(alpha: 0.5),
        );
  }
}
