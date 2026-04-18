import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "../../sharedWidgets/common_input.dart";

class StepEmail extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const StepEmail({
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
          "Please enter your active email address. We will use this email to send important updates, reports, and notifications.",
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
          hint: "example@domain.com",
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }
}
