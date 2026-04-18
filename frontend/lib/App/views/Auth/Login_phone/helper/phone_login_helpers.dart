import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_mobile_field/intl_mobile_field.dart';

Widget intlPhoneInput({
  required String initialCountryCode,
  required Function(String) onChanged,
  String hint = "Enter phone number",
}) {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      final colors = theme.colorScheme;
      final isDark = theme.brightness == Brightness.dark;

      return Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white24 : colors.outline,
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: IntlMobileField(
          initialCountryCode: initialCountryCode,
          style: GoogleFonts.dmSans(
            color: isDark ? Colors.white : colors.onSurface,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
              color: isDark
                  ? Colors.white54
                  : colors.onSurface.withValues(alpha: 0.6),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
          onChanged: (value) => onChanged(value.completeNumber),
        ),
      );
    },
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
          thickness: 1.2,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          "OR",
          style: GoogleFonts.dmSans(
            color: isDark
                ? Colors.white54
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
          thickness: 1.2,
        ),
      ),
    ],
  );
}
