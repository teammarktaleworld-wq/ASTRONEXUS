import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'TarotScreen.dart';

class Splashtarot extends StatefulWidget {
  const Splashtarot({super.key});

  @override
  State<Splashtarot> createState() => _SplashtarotState();
}

class _SplashtarotState extends State<Splashtarot> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TarotScreen()),
        );
      }
    });
  }

  Widget _optionChip(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFD4AF37)),
          const SizedBox(width: 6),
          Text(
            title,
            style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white70),
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
            /// 🔮 Animated Tarot Image
            Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: Image.asset(
                    "assets/images/tarot_card.png",
                    fit: BoxFit.cover,
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: -6, end: 6, duration: 3.seconds)
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.85, 0.85)),

            const SizedBox(height: 26),

            /// Title
            Text(
                  "TAROT",
                  style: GoogleFonts.dmSans(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: Colors.white,
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 8),

            /// Subtitle
            Text(
              "Reveal Your Destiny",
              style: GoogleFonts.dmSans(fontSize: 15, color: Colors.white60),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 26),

            /// Chips
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _optionChip(Icons.favorite, "Love"),
                const SizedBox(width: 8),
                _optionChip(Icons.work, "Career"),
                const SizedBox(width: 8),
                _optionChip(Icons.nightlight_round, "Future"),
              ],
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.4, end: 0),
          ],
        ),
      ),
    );
  }
}
