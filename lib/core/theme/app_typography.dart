import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Deadbounce type scale.
///
/// Orbitron for display/headline (geometric, retro-neon arcade marquee) and
/// Rajdhani for titles/body/labels (condensed, techy, highly legible at
/// small sizes). Defined once here and wired through [ThemeData.textTheme] —
/// screens use `Theme.of(context).textTheme.*`, never GoogleFonts directly.
abstract final class AppTypography {
  static TextTheme textTheme = TextTheme(
    // Display — splash wordmark, big numbers
    displayLarge: GoogleFonts.orbitron(
      fontSize: 52,
      fontWeight: FontWeight.w800,
      letterSpacing: 2.0,
      color: AppColors.textPrimary,
    ),
    displayMedium: GoogleFonts.orbitron(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
      color: AppColors.textPrimary,
    ),
    displaySmall: GoogleFonts.orbitron(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: AppColors.textPrimary,
    ),

    // Headline — screen titles
    headlineLarge: GoogleFonts.orbitron(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.0,
      color: AppColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.orbitron(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: AppColors.textPrimary,
    ),
    headlineSmall: GoogleFonts.orbitron(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
      color: AppColors.textPrimary,
    ),

    // Title — cards, dialogs, app bars
    titleLarge: GoogleFonts.rajdhani(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: AppColors.textPrimary,
    ),
    titleMedium: GoogleFonts.rajdhani(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: AppColors.textPrimary,
    ),
    titleSmall: GoogleFonts.rajdhani(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: AppColors.textPrimary,
    ),

    // Body
    bodyLarge: GoogleFonts.rajdhani(
      fontSize: 17,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.rajdhani(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: AppColors.textSecondary,
    ),
    bodySmall: GoogleFonts.rajdhani(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: AppColors.textSecondary,
    ),

    // Label — buttons, chips, form labels
    labelLarge: GoogleFonts.rajdhani(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: AppColors.textPrimary,
    ),
    labelMedium: GoogleFonts.rajdhani(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
      color: AppColors.textSecondary,
    ),
    labelSmall: GoogleFonts.rajdhani(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: AppColors.textSecondary,
    ),
  );
}
