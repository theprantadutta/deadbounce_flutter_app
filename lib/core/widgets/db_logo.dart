import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_effects.dart';
import 'fitted_headline.dart';

/// The Deadbounce logo: [Icons.airline_stops] (a trajectory path with a
/// bounce — the ricochet) set inside a rotated-diamond badge with the
/// brand amber→blue gradient ring, dark glass core and neon glow.
///
/// Used on the splash screen, auth screens and the home menu. The launcher
/// icon is intentionally left as the Flutter default for this pass — final
/// asset design is out of scope.
class DbLogo extends StatelessWidget {
  const DbLogo({super.key, this.size = 96, this.glow = true});

  /// Outer badge size (width == height).
  final double size;

  /// Whether to render the neon glow halo (disable in tight layouts).
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final effects = Theme.of(context).extension<AppEffects>()!;
    final borderWidth = size * 0.045;

    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          gradient: effects.brandGradient,
          borderRadius: BorderRadius.circular(size * 0.28),
          boxShadow: glow ? effects.amberGlow : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.ink900,
            borderRadius: BorderRadius.circular(size * 0.24),
          ),
          child: Transform.rotate(
            angle: -math.pi / 4,
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  effects.brandGradient.createShader(bounds),
              child: Icon(
                Icons.airline_stops_rounded,
                size: size * 0.56,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo + wordmark lockup used on splash and auth headers.
class DbLogoLockup extends StatelessWidget {
  const DbLogoLockup({super.key, this.logoSize = 96});

  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DbLogo(size: logoSize),
        SizedBox(height: logoSize * 0.45),
        FittedHeadline(
          'DEADBOUNCE',
          style: textTheme.displaySmall?.copyWith(fontSize: logoSize * 0.30),
        ),
        SizedBox(height: logoSize * 0.08),
        FittedHeadline(
          'NO DAMAGE TILL IT BOUNCES',
          style: textTheme.labelMedium?.copyWith(
            color: AppColors.blue300,
            letterSpacing: 3,
            fontSize: logoSize * 0.10,
          ),
        ),
      ],
    );
  }
}
