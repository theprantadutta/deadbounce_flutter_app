import 'package:flutter/material.dart';

/// Deadbounce palette — neo-western neon.
///
/// Derived from the logo: near-black ink base, amber primary (muzzle-flash
/// gold), electric blue accent (neon ricochet trail). Full 50→900 shade
/// scales so screens never need to invent a color, plus semantic colors.
/// Never reference raw hex from screens — go through [AppTheme] /
/// `Theme.of(context)`.
abstract final class AppColors {
  // --- Ink (background base, near-black with a cold blue undertone) ---
  static const Color ink950 = Color(0xFF05060A);
  static const Color ink900 = Color(0xFF090A12);
  static const Color ink800 = Color(0xFF0E101B);
  static const Color ink700 = Color(0xFF141726);
  static const Color ink600 = Color(0xFF1B1F33);
  static const Color ink500 = Color(0xFF252A42);
  static const Color ink400 = Color(0xFF3A4060);
  static const Color ink300 = Color(0xFF565D85);
  static const Color ink200 = Color(0xFF8B91B5);
  static const Color ink100 = Color(0xFFC2C6DE);
  static const Color ink50 = Color(0xFFE8EAF4);

  // --- Amber (primary — gunslinger gold, neon signage) ---
  static const Color amber50 = Color(0xFFFFF8E5);
  static const Color amber100 = Color(0xFFFFEDC2);
  static const Color amber200 = Color(0xFFFFE099);
  static const Color amber300 = Color(0xFFFFD166);
  static const Color amber400 = Color(0xFFFFC53D);
  static const Color amber500 = Color(0xFFFFB718);
  static const Color amber600 = Color(0xFFF5A300);
  static const Color amber700 = Color(0xFFD18700);
  static const Color amber800 = Color(0xFFA86A00);
  static const Color amber900 = Color(0xFF7A4B00);

  // --- Electric blue (accent — ricochet trail) ---
  static const Color blue50 = Color(0xFFE3FBFF);
  static const Color blue100 = Color(0xFFBDF4FF);
  static const Color blue200 = Color(0xFF8FEBFF);
  static const Color blue300 = Color(0xFF5CDFFF);
  static const Color blue400 = Color(0xFF33D3FF);
  static const Color blue500 = Color(0xFF15C1F3);
  static const Color blue600 = Color(0xFF00A8DE);
  static const Color blue700 = Color(0xFF008AB8);
  static const Color blue800 = Color(0xFF006B90);
  static const Color blue900 = Color(0xFF004B66);

  // --- Semantic ---
  static const Color success = Color(0xFF3DDC84);
  static const Color onSuccess = Color(0xFF00210F);
  static const Color warning = Color(0xFFFFD740);
  static const Color onWarning = Color(0xFF2B2000);
  static const Color error = Color(0xFFFF4D5E);
  static const Color onError = Color(0xFF2B0006);

  // --- Surfaces ---
  static const Color background = ink900;
  static const Color surface = ink800;
  static const Color surfaceVariant = ink700;
  static const Color surfaceBright = ink600;
  static const Color outline = ink500;
  static const Color outlineFaint = ink600;

  // --- Text ---
  static const Color textPrimary = Color(0xFFF4F5FB);
  static const Color textSecondary = ink200;
  static const Color textDisabled = ink400;
  static const Color onAmber = Color(0xFF231500);
  static const Color onBlue = Color(0xFF001E29);
}
