import "package:astro_tale/core/constants/app_colors.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class UnifiedDarkUi {
  const UnifiedDarkUi._();

  static PreferredSizeWidget appBar(
    BuildContext context, {
    required String title,
    List<Widget>? actions,
    bool centerTitle = true,
  }) {
    return AppBar(
      backgroundColor: AppColors.appBarDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      title: Text(
        title,
        style: GoogleFonts.dmSans(
          color: AppColors.onDark,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: 0.3,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.onDark),
      actionsIconTheme: const IconThemeData(color: AppColors.onDark),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.white.withOpacity(0.06)),
      ),
    );
  }

  static BoxDecoration screenBackground(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    if (isDark) {
      return const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            AppColors.appBarDark,
            Color(0xFF393053),
            AppColors.appBarDark,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      );
    }

    return const BoxDecoration(
      gradient: LinearGradient(
        colors: <Color>[
          AppColors.lightBackground,
          AppColors.lightBackgroundSoft,
          AppColors.lightBackground,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  static Color cardSurface(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? AppColors.surface
        : AppColors.lightContainer;
  }

  static Color cardSurfaceAlt(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? AppColors.surfaceAlt
        : AppColors.lightContainerAlt;
  }

  static Color cardBorder(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? Colors.white12
        : AppColors.cardBorderLight;
  }

  static Color mutedOnCard(ThemeData theme) {
    return Colors.white70;
  }
}
