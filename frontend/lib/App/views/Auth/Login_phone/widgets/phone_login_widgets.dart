import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SendOtpButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const SendOtpButton({super.key, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.24),
        ),
        child: loading
            ? CircularProgressIndicator(color: colors.onPrimary)
            : Text(
                "Send OTP",
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.onPrimary,
                ),
              ),
      ),
    );
  }
}
