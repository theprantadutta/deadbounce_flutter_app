import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_effects.dart';
import 'app_typography.dart';

/// Single source of truth for [ThemeData]. Everything visual flows from
/// here — screens never hardcode colors, fonts, radii or shadows.
abstract final class AppTheme {
  static ThemeData get dark {
    final textTheme = AppTypography.textTheme;

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.amber500,
      onPrimary: AppColors.onAmber,
      primaryContainer: AppColors.amber800,
      onPrimaryContainer: AppColors.amber100,
      secondary: AppColors.blue500,
      onSecondary: AppColors.onBlue,
      secondaryContainer: AppColors.blue800,
      onSecondaryContainer: AppColors.blue100,
      tertiary: AppColors.amber300,
      onTertiary: AppColors.onAmber,
      error: AppColors.error,
      onError: AppColors.onError,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineFaint,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: AppColors.ink50,
      onInverseSurface: AppColors.ink900,
      inversePrimary: AppColors.amber700,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      extensions: const [AppEffects.standard],

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Never paint a surface tint/shadow when content scrolls under the
        // bar (Material 3 does this by default). The app's own screens use a
        // custom transparent header; this only covers the debug Talker screen.
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: textTheme.headlineSmall,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.amber500,
          foregroundColor: AppColors.onAmber,
          disabledBackgroundColor: AppColors.ink600,
          disabledForegroundColor: AppColors.textDisabled,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
          textStyle: textTheme.labelLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blue300,
          // Soft translucent accent border, matching the home-screen cards
          // (accent @ 0.45) rather than a hard, bright outline.
          side: BorderSide(color: AppColors.blue400.withValues(alpha: 0.45)),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
          textStyle: textTheme.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.amber400,
          textStyle: textTheme.labelMedium,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.ink700,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textDisabled),
        labelStyle: textTheme.bodyMedium,
        prefixIconColor: AppColors.ink300,
        suffixIconColor: AppColors.ink300,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: const BorderSide(color: AppColors.outlineFaint),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: const BorderSide(color: AppColors.outlineFaint),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: const BorderSide(color: AppColors.amber500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.mdAll,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink700,
        contentTextStyle: textTheme.bodyLarge,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.mdAll),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.outlineFaint,
        thickness: 1,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.amber500,
      ),

      cardTheme: CardThemeData(
        color: AppColors.surfaceVariant,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
