import 'package:astro_tale/App/views/Home/others/view/birthchart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashBirth extends StatefulWidget {
  const SplashBirth({super.key});

  @override
  State<SplashBirth> createState() => _SplashBirthState();
}

class _SplashBirthState extends State<SplashBirth>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BirthChartScreen()),
        );
      }
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
      backgroundColor: const Color(0xff050B1A),
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipOval(
                child: Image.asset(
                  "assets/images/birthchart.png",
                  height: 110,
                  width: 110,
                  fit: BoxFit.cover,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "BIRTH CHART",
                style: GoogleFonts.dmSans(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Explore your cosmic birth",
                style: GoogleFonts.dmSans(fontSize: 16, color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
