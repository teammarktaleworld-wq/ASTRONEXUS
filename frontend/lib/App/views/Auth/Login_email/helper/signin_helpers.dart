import 'package:flutter/material.dart';
import 'package:astro_tale/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

InputDecoration authInput(BuildContext context, String hint, IconData icon) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;
  final borderColor = isDark ? Colors.white24 : colors.outline;

  return InputDecoration(
    filled: true,
    fillColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
    hintText: hint,
    hintStyle: GoogleFonts.dmSans(
      color: isDark ? Colors.white54 : colors.onSurface.withValues(alpha: 0.62),
      fontWeight: FontWeight.w500,
    ),
    prefixIcon: Icon(icon, color: isDark ? Colors.white70 : colors.primary),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: borderColor, width: 1.2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: borderColor, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: isDark ? AppColors.accent : AppColors.accentStrong,
        width: 1.8,
      ),
    ),
  );
}

Widget orDivider(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return Row(
    children: [
      Expanded(
        child: Divider(
          color: isDark
              ? Colors.white24
              : theme.colorScheme.onSurface.withValues(alpha: 0.16),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          "OR",
          style: GoogleFonts.dmSans(
            color: isDark
                ? Colors.white70
                : theme.colorScheme.onSurface.withValues(alpha: 0.62),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Expanded(
        child: Divider(
          color: isDark
              ? Colors.white24
              : theme.colorScheme.onSurface.withValues(alpha: 0.16),
        ),
      ),
    ],
  );
}
