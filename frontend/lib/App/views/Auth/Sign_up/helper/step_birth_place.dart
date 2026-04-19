import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "../../sharedWidgets/place_suggestion_sheet.dart";
import "../../sharedWidgets/step_image.dart";

class StepBirthPlace extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const StepBirthPlace({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark
        ? Colors.white54
        : theme.colorScheme.onSurface.withValues(alpha: 0.72);
    final iconColor = isDark ? colors.primary : const Color(0xFF1D4ED8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepImage(path: "assets/images/place.png"),
        Text(
          "Your birthplace anchors planetary angles to Earth coordinates.",
          style: GoogleFonts.dmSans(color: mutedColor),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: controller,
          readOnly: true,
          scrollPadding: const EdgeInsets.only(bottom: 180),
          cursorColor: iconColor,
          onTap: () async {
            final selected = await showPlaceSuggestionSheet(
              context: context,
              title: "Select Place of Birth",
              initialValue: controller.text,
            );
            if (selected == null || selected.trim().isEmpty) {
              return;
            }
            controller.text = selected;
            onChanged(selected);
          },
          style: GoogleFonts.dmSans(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: "Place of Birth",
            hintStyle: GoogleFonts.dmSans(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.64)
                  : const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(Icons.location_on_outlined, color: iconColor),
            suffixIcon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: mutedColor,
            ),
          ),
        ),
      ],
    );
  }
}
