import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class _TarotDetailSheet extends StatelessWidget {
  final String title;
  final String description;

  const _TarotDetailSheet({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, controller) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF141225).withOpacity(0.97),
                    const Color(0xFF1E1B2E).withOpacity(0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.25),
                ),
              ),
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      style: GoogleFonts.dmSans(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 15,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
