import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class CommonInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final bool obscureText;

  const CommonInput({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final hintColor = isDark
        ? Colors.white.withValues(alpha: 0.64)
        : const Color(0xFF64748B);
    final iconColor = isDark ? colors.primary : const Color(0xFF1D4ED8);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      scrollPadding: const EdgeInsets.only(bottom: 180),
      cursorColor: iconColor,
      style: GoogleFonts.dmSans(color: textColor, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(
          color: hintColor,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: iconColor),
      ),
    );
  }
}
