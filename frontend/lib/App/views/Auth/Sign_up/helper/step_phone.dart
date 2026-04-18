import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "../../sharedWidgets/common_input.dart";

class StepPhone extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const StepPhone({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Please enter your active mobile number. This number will be used for verification and important updates.",
          style: GoogleFonts.dmSans(
            color: isDark
                ? Colors.white70
                : theme.colorScheme.onSurface.withOpacity(0.72),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        CommonInput(
          controller: controller,
          onChanged: onChanged,
          hint: "Enter your phone number",
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}
