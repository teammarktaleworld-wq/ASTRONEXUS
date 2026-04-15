import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'horoscope.dart';

class SplashHoroscope extends StatefulWidget {
  const SplashHoroscope({super.key});

  @override
  State<SplashHoroscope> createState() => _SplashHoroscopeState();
}

class _SplashHoroscopeState extends State<SplashHoroscope> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1300), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HoroscopeScreen()),
      );
    });
  }

  Widget _optionChip(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.yellow),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.dmSans(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050B1A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🌞 Sun icon
            Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.1),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.sun,
                    size: 80,
                    color: Colors.yellow,
                  ),
                )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

            const SizedBox(height: 20),

            /// Title
            Text(
                  "HOROSCOPE",
                  style: GoogleFonts.dmSans(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 8),

            /// Subtitle
            Text(
              "Check your daily zodiac insights",
              style: GoogleFonts.dmSans(fontSize: 16, color: Colors.white54),
            ).animate().fadeIn(delay: 450.ms, duration: 300.ms),

            const SizedBox(height: 24),

            /// 🔹 Options Row
            Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _optionChip(LucideIcons.sunrise, "Daily"),
                    const SizedBox(width: 12),
                    _optionChip(LucideIcons.calendar, "Weekly"),
                    const SizedBox(width: 12),
                    _optionChip(LucideIcons.star, "Monthly"),
                  ],
                )
                .animate()
                .fadeIn(delay: 600.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }
}
