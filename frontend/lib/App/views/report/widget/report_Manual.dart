import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportsManualSection extends StatelessWidget {
  const ReportsManualSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 📌 Section Title
                Text(
                  "About Reports",
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Divider(
                  color: Colors.white.withOpacity(0.9),
                  thickness: 2, // height of the line
                  indent: 0, // space from left
                  endIndent: 16, // space from right
                ),

                const SizedBox(height: 8),

                /// 📝 Description
                Text(
                  "This section provides a detailed overview of all your generated reports. "
                  "Each report reflects insights based on your activity and selected parameters. "
                  "Use filters to refine results, explore individual entries for deeper analysis, "
                  "and track progress over time in a structured and transparent manner.",
                  style: GoogleFonts.dmSans(
                    color: Colors.white70,
                    fontSize: 13.5,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
