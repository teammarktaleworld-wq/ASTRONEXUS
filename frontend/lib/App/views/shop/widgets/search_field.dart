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
        ? const Color(0xFF1F2743).withValues(alpha: 0.88)
        : Colors.white.withValues(alpha: 0.96);
    final border = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : colors.primary.withValues(alpha: 0.22);
    final hint = isDark
        ? Colors.white60
        : colors.onSurface.withValues(alpha: 0.52);
    final shadow = isDark
        ? Colors.black.withValues(alpha: 0.28)
        : Colors.black.withValues(alpha: 0.08);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: shadow,
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: GoogleFonts.dmSans(
              color: colors.onSurface,
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
                      ? Colors.white.withValues(alpha: 0.08)
                      : colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: colors.primary,
                  size: 20,
                ),
              ),
              suffixIcon: isSearching
                  ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: colors.onSurface.withValues(alpha: 0.72),
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
