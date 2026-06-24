import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Deadbounce type scale.
///
/// Orbitron for display/headline (geometric, retro-neon arcade marquee) and
/// Rajdhani for titles/body/labels (condensed, techy, highly legible at
/// small sizes). Both families are **bundled with the app** as static TTFs
/// (`assets/fonts/`, declared in pubspec.yaml) — there is no runtime font
/// download. Defined once here and wired through [ThemeData.textTheme] —
/// screens use `Theme.of(context).textTheme.*`, never raw font families.
abstract final class AppTypography {
  static const String _orbitron = 'Orbitron'; // weights 400–900 bundled
  static const String _rajdhani = 'Rajdhani'; // weights 300–700 bundled

  static const TextTheme textTheme = TextTheme(
    // Display — splash wordmark, big numbers
    displayLarge: TextStyle(
      fontFamily: _orbitron,
      fontSize: 52,
      fontWeight: FontWeight.w800,
      letterSpacing: 2.0,
      color: AppColors.textPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: _orbitron,
      fontSize: 40,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
      color: AppColors.textPrimary,
    ),
    displaySmall: TextStyle(
      fontFamily: _orbitron,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: AppColors.textPrimary,
    ),

    // Headline — screen titles
    headlineLarge: TextStyle(
      fontFamily: _orbitron,
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.0,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: _orbitron,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: AppColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: _orbitron,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
      color: AppColors.textPrimary,
    ),

    // Title — cards, dialogs, app bars
    titleLarge: TextStyle(
      fontFamily: _rajdhani,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: _rajdhani,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: AppColors.textPrimary,
    ),
    titleSmall: TextStyle(
      fontFamily: _rajdhani,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: AppColors.textPrimary,
    ),

    // Body
    bodyLarge: TextStyle(
      fontFamily: _rajdhani,
      fontSize: 17,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: _rajdhani,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: AppColors.textSecondary,
    ),
    bodySmall: TextStyle(
      fontFamily: _rajdhani,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: AppColors.textSecondary,
    ),

    // Label — buttons, chips, form labels
    labelLarge: TextStyle(
      fontFamily: _rajdhani,
      fontSize: 17,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: AppColors.textPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: _rajdhani,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
      color: AppColors.textSecondary,
    ),
    labelSmall: TextStyle(
      fontFamily: _rajdhani,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: AppColors.textSecondary,
    ),
  );
}
