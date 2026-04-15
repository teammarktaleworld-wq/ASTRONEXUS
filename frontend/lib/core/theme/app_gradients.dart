import "package:flutter/material.dart";
import "package:astro_tale/core/constants/app_colors.dart";

class AppGradients {
  const AppGradients._();

  static List<Color> screen(ThemeData theme) {
    if (theme.brightness == Brightness.dark) {
      return const <Color>[
        AppColors.appBarDark,
        Color(0xFF393053),
        AppColors.appBarDark,
      ];
    }
    return const <Color>[
      AppColors.lightBackground,
      AppColors.lightBackgroundSoft,
      AppColors.lightBackground,
    ];
  }

  static BoxDecoration screenDecoration(ThemeData theme) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: screen(theme),
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  static Color screenOverlay(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? Colors.black.withOpacity(0.36)
        : Colors.white.withOpacity(0.14);
  }

  static Color glassFill(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? AppColors.surfaceAlt
        : AppColors.lightContainer;
  }

  static Color glassBorder(ThemeData theme) {
    return theme.brightness == Brightness.dark
        ? Colors.black
        : AppColors.cardBorderLight;
  }

  static Color panelOn(ThemeData theme) => Colors.white;
}
