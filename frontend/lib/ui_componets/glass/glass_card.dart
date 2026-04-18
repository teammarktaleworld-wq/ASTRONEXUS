import "package:astro_tale/core/constants/app_colors.dart";
import 'package:flutter/material.dart';

Color glassPanelTextColor(ThemeData theme) => Colors.white;

BoxDecoration glassPanelDecoration(
  ThemeData theme, {
  double radius = 24,
  Color? accent,
}) {
  final isDark = theme.brightness == Brightness.dark;
  final fillColor = isDark ? AppColors.surface : AppColors.lightContainer;
  final borderColor = accent != null
      ? accent.withValues(alpha: 0.32)
      : (isDark ? Colors.white12 : AppColors.cardBorderLight);

  return BoxDecoration(
    color: fillColor,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borderColor),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.24),
        blurRadius: isDark ? 20 : 14,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

Widget glassCard({
  required Widget child,
  EdgeInsetsGeometry? padding,
  double radius = 24,
  Color? accent,
}) {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      final panelTextColor = glassPanelTextColor(theme);
      final panelTheme = theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          surface: isDark ? AppColors.surfaceAlt : AppColors.lightContainerAlt,
          onSurface: panelTextColor,
          outline: isDark ? Colors.white12 : AppColors.cardBorderLight,
        ),
        textTheme: theme.textTheme.apply(
          bodyColor: panelTextColor,
          displayColor: panelTextColor,
        ),
      );

      return Container(
        padding: padding ?? const EdgeInsets.all(24),
        decoration: glassPanelDecoration(theme, radius: radius, accent: accent),
        child: Theme(
          data: panelTheme,
          child: IconTheme(
            data: IconThemeData(color: panelTextColor),
            child: child,
          ),
        ),
      );
    },
  );
}
