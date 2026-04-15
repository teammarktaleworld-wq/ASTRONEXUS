import "package:astro_tale/core/constants/app_colors.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.light(
      primary: AppColors.lightPrimary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      background: AppColors.lightBackground,
      onBackground: AppColors.lightTextPrimary,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.lightTextMuted.withOpacity(0.28),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: scheme.background,
      colorScheme: scheme,
    );

    return base.copyWith(
      textTheme: GoogleFonts.dmSansTextTheme(
        base.textTheme,
      ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface),

      appBarTheme: AppBarTheme(
        elevation: 0.5,
        backgroundColor: AppColors.appBarDark,
        foregroundColor: AppColors.onDark,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.onDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.onDark),
        actionsIconTheme: const IconThemeData(color: AppColors.onDark),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outline.withOpacity(0.42),
        thickness: 1,
      ),

      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.lightSurface,
        selectedColor: scheme.primary.withOpacity(0.16),
        side: BorderSide(color: scheme.outline),
        labelStyle: GoogleFonts.dmSans(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary),
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outline),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.primary,
        contentTextStyle: GoogleFonts.dmSans(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: Colors.black,
      secondary: AppColors.accentStrong,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      background: AppColors.background,
      onBackground: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
      outline: AppColors.surfaceAlt,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scheme.background,
      colorScheme: scheme,
    );

    return base.copyWith(
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),

      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.appBarDark,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.surfaceAlt),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.surfaceAlt),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.accent),
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.surfaceAlt),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.accentStrong,
        contentTextStyle: GoogleFonts.dmSans(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
