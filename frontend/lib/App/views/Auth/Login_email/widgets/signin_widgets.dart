import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const LoginButton({super.key, required this.loading, required this.onTap});

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
            ? LoadingAnimationWidget.fourRotatingDots(
                color: colors.onPrimary,
                size: 26,
              )
            : Text(
                "Login",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: colors.onPrimary,
                ),
              ),
      ),
    );
  }
}
