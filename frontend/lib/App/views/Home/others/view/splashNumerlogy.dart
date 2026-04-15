import 'dart:math';
import 'package:astro_tale/App/views/Home/others/numerlogyScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SplashNumerology extends StatefulWidget {
  const SplashNumerology({super.key});

  @override
  State<SplashNumerology> createState() => _SplashNumerologyState();
}

class _SplashNumerologyState extends State<SplashNumerology>
    with TickerProviderStateMixin {
  late AnimationController starController;
  FallingStarPainter? starPainter;

  @override
  void initState() {
    super.initState();

    // 🌠 Falling Stars Animation
    starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        starPainter = FallingStarPainter.generate(120, size, 0);
      });
    });

    // Navigate after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NumerologyScreen()),
      );
    });
  }

  @override
  void dispose() {
    starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          /// 🌌 FALLING STARS BACKGROUND
          AnimatedBuilder(
            animation: starController,
            builder: (_, __) {
              if (starPainter == null) return const SizedBox.shrink();
              return CustomPaint(
                size: size,
                painter: FallingStarPainter(
                  starController.value,
                  stars: starPainter!.stars,
                  sizes: starPainter!.sizes,
                  speeds: starPainter!.speeds,
                ),
              );
            },
          ),

          /// 🌠 MAIN CONTENT
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with subtle glow
                Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent.withOpacity(0.2),
                      ),
                      child: Icon(
                        LucideIcons.hash,
                        size: 80,
                        color: Colors.blueAccent,
                      ),
                    )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.easeOutBack)
                    .fadeIn(duration: 500.ms),

                const SizedBox(height: 20),

                // Title
                Text(
                      "NUMEROLOGY",
                      style: GoogleFonts.dmSans(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    )
                    .animate(delay: 200.ms)
                    .slideY(begin: 0.4, end: 0, duration: 500.ms)
                    .fadeIn(),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  "Discover your numbers",
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    color: Colors.white54,
                  ),
                ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🌟 FALLING STAR PAINTER
class FallingStarPainter extends CustomPainter {
  final double progress;
  final List<Offset> stars;
  final List<double> sizes;
  final List<double> speeds;

  FallingStarPainter(
    this.progress, {
    required this.stars,
    required this.sizes,
    required this.speeds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white24;

    for (int i = 0; i < stars.length; i++) {
      final y = (stars[i].dy + progress * speeds[i]) % size.height;
      canvas.drawCircle(Offset(stars[i].dx, y), sizes[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant FallingStarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }

  static FallingStarPainter generate(int count, Size size, double progress) {
    final random = Random();

    return FallingStarPainter(
      progress,
      stars: List.generate(
        count,
        (_) => Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
      ),
      sizes: List.generate(count, (_) => random.nextDouble() * 1.2 + 0.4),
      speeds: List.generate(count, (_) => 50 + random.nextDouble() * 250),
    );
  }
}
