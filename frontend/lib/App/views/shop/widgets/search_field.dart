import "dart:ui";

import "package:astro_tale/core/localization/app_localizations.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearching;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const SearchField({
    super.key,
    required this.controller,
    required this.isSearching,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark
      ? Colors.white.withOpacity(0.97) // white background in dark mode
      : Colors.white.withOpacity(0.96);
    final border = isDark
      ? Colors.black.withOpacity(0.08) // subtle border in dark mode
      : colors.primary.withOpacity(0.22);
    final hint = isDark
      ? const Color(0xFF6B7280) // dark hint in white field
      : colors.onSurface.withOpacity(0.52);
    final textColor = isDark
      ? const Color(0xFF23264A) // dark text for white field
      : colors.onSurface;
    final iconColor = isDark
      ? const Color(0xFF8B7CF6) // accent icon in dark mode
      : colors.primary;
    final shadow = isDark
      ? Colors.black.withOpacity(0.13)
      : Colors.black.withOpacity(0.08);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border, width: 1.1),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: shadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: GoogleFonts.dmSans(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: context.l10n.tr("searchProducts"),
              hintStyle: GoogleFonts.dmSans(
                color: hint,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              prefixIcon: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.10)
                      : colors.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: iconColor,
                  size: 20,
                ),
              ),
              suffixIcon: isSearching
                  ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark
                            ? const Color(0xFF23264A)
                            : colors.onSurface.withOpacity(0.72),
                      ),
                      onPressed: onClear,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
