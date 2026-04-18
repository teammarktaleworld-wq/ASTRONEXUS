import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'kundliScreen.dart'; // import your Kundli main screen here

class SplashKundli extends StatefulWidget {
  const SplashKundli({super.key});

  @override
  State<SplashKundli> createState() => _SplashKundliState();
}

class _SplashKundliState extends State<SplashKundli>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller for fade-in effect
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Navigate to KundliScreen after 2.5 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const KundliScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.orbit, size: 80, color: Colors.deepPurpleAccent),
              const SizedBox(height: 20),
              Text(
                "KUNDLI ASTROLOGY",
                style: GoogleFonts.dmSans(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Discover your cosmic chart",
                style: GoogleFonts.dmSans(fontSize: 16, color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
