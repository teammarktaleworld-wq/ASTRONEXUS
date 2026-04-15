import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "../../sharedWidgets/common_input.dart";

class StepPassword extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmChanged;

  const StepPassword({
    super.key,
    required this.passwordController,
    required this.confirmController,
    required this.onPasswordChanged,
    required this.onConfirmChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Create a strong password to secure your account. Use at least 8 characters with a mix of letters, numbers, and symbols.",
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
          controller: passwordController,
          onChanged: onPasswordChanged,
          hint: "Enter password",
          icon: Icons.lock_outline_rounded,
          obscureText: true,
        ),
        const SizedBox(height: 14),
        CommonInput(
          controller: confirmController,
          onChanged: onConfirmChanged,
          hint: "Re-enter password",
          icon: Icons.lock_clock_outlined,
          obscureText: true,
        ),
      ],
    );
  }
}
