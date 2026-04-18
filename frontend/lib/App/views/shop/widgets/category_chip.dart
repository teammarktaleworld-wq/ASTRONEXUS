import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isSelected
        ? colors.primary
        : (isDark ? Colors.white24 : colors.outline.withOpacity(0.3));
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: baseColor.withOpacity(.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: baseColor.withOpacity(.3)),
            ),
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.white : colors.onPrimary)
                    : (isDark
                          ? Colors.white.withOpacity(0.88)
                          : colors.onSurface.withOpacity(0.8)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
