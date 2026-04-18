import 'package:astro_tale/App/views/Nuterational/views/NutritonalScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class Splashnutrition extends StatefulWidget {
  const Splashnutrition({super.key});

  @override
  State<Splashnutrition> createState() => _SplashnutritionState();
}

class _SplashnutritionState extends State<Splashnutrition> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NutritionalAstrologyScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🌿 Leaf icon with healthy glow
            Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.45),
                        blurRadius: 28,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.leaf,
                    size: 90,
                    color: Colors.greenAccent,
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.88, 0.88), end: const Offset(1, 1))
                .then()
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.05, 1.05),
                  duration: 300.ms,
                ),

            const SizedBox(height: 28),

            /// 🥗 Title
            Text(
                  "NUTRITIONAL ASTROLOGY",
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.25, end: 0),

            const SizedBox(height: 8),

            /// ✨ Subtitle
            Text(
              "Discover your cosmic diet",
              style: GoogleFonts.dmSans(fontSize: 16, color: Colors.white54),
            ).animate().fadeIn(delay: 500.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
