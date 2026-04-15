import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "../../sharedWidgets/common_input.dart";
import "../../sharedWidgets/step_image.dart";

class StepName extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const StepName({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark
        ? Colors.white54
        : theme.colorScheme.onSurface.withOpacity(0.72);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepImage(path: "assets/images/birth_one.png"),
        Text(
          "Your name carries vibrational energy. It forms the identity through which the universe recognizes your cosmic blueprint.",
          style: GoogleFonts.dmSans(color: mutedColor),
        ),
        const SizedBox(height: 20),
        CommonInput(
          controller: controller,
          hint: "Full Name",
          icon: Icons.person_outline,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
