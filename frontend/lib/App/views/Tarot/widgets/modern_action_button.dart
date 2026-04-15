import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModernActionButton extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const ModernActionButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  State<ModernActionButton> createState() => _ModernActionButtonState();
}

class _ModernActionButtonState extends State<ModernActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFFD4AF37) : theme.colorScheme.primary;
    final foreground = isDark ? Colors.black : Colors.white;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(colors: [accent, accent]),
                border: Border.all(color: Colors.white24),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: .35),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.picture_as_pdf_rounded,
                    color: foreground,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.title,
                    style: GoogleFonts.dmSans(
                      color: foreground,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
