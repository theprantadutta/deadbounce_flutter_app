import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Brand effects as a [ThemeExtension]: neon glows, gradients and dark
/// glassmorphism decorations. Reached via
/// `Theme.of(context).extension<AppEffects>()!` so screens stay free of
/// raw shadow/gradient definitions.
@immutable
class AppEffects extends ThemeExtension<AppEffects> {
  const AppEffects({
    required this.amberGlow,
    required this.blueGlow,
    required this.softShadow,
    required this.brandGradient,
    required this.arenaGradient,
    required this.glassDecoration,
  });

  /// Neon glow for amber (primary) elements — buttons, logo.
  final List<BoxShadow> amberGlow;

  /// Neon glow for electric-blue (accent) elements.
  final List<BoxShadow> blueGlow;

  /// Plain dark elevation shadow for cards.
  final List<BoxShadow> softShadow;

  /// Amber → electric blue signature gradient.
  final Gradient brandGradient;

  /// Deep background gradient used behind full screens.
  final Gradient arenaGradient;

  /// Dark glass panel (translucent surface + faint outline).
  final BoxDecoration glassDecoration;

  static const AppEffects standard = AppEffects(
    amberGlow: [
      BoxShadow(
        color: Color(0x59FFB718),
        blurRadius: 24,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Color(0x26FFB718),
        blurRadius: 48,
        spreadRadius: 4,
      ),
    ],
    blueGlow: [
      BoxShadow(
        color: Color(0x5915C1F3),
        blurRadius: 24,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Color(0x2615C1F3),
        blurRadius: 48,
        spreadRadius: 4,
      ),
    ],
    softShadow: [
      BoxShadow(
        color: Color(0x66000000),
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
    ],
    brandGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.amber500, AppColors.amber600, AppColors.blue500],
      stops: [0.0, 0.45, 1.0],
    ),
    arenaGradient: RadialGradient(
      center: Alignment(0, -0.4),
      radius: 1.4,
      colors: [AppColors.ink700, AppColors.ink900, AppColors.ink950],
      stops: [0.0, 0.55, 1.0],
    ),
    glassDecoration: BoxDecoration(
      color: Color(0xCC0E101B),
      borderRadius: BorderRadius.all(Radius.circular(16)),
      border: Border.fromBorderSide(
        BorderSide(color: Color(0x33565D85)),
      ),
    ),
  );

  @override
  AppEffects copyWith({
    List<BoxShadow>? amberGlow,
    List<BoxShadow>? blueGlow,
    List<BoxShadow>? softShadow,
    Gradient? brandGradient,
    Gradient? arenaGradient,
    BoxDecoration? glassDecoration,
  }) {
    return AppEffects(
      amberGlow: amberGlow ?? this.amberGlow,
      blueGlow: blueGlow ?? this.blueGlow,
      softShadow: softShadow ?? this.softShadow,
      brandGradient: brandGradient ?? this.brandGradient,
      arenaGradient: arenaGradient ?? this.arenaGradient,
      glassDecoration: glassDecoration ?? this.glassDecoration,
    );
  }

  @override
  AppEffects lerp(ThemeExtension<AppEffects>? other, double t) {
    if (other is! AppEffects) return this;
    return t < 0.5 ? this : other;
  }
}
