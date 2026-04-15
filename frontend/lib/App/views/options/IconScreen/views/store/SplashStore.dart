import 'package:astro_tale/App/views/shop/store_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'storeScreen.dart';

class SplashStore extends StatefulWidget {
  const SplashStore({super.key});

  @override
  State<SplashStore> createState() => _SplashStoreState();
}

class _SplashStoreState extends State<SplashStore> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 1200), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => StoreScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050B1A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🛍 Store Icon
            Icon(LucideIcons.shoppingBag, size: 80, color: Colors.tealAccent)
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1))
                .then()
                .shimmer(duration: 400.ms),

            const SizedBox(height: 20),

            /// ✨ Title
            Text(
                  "ASTRO STORE",
                  style: GoogleFonts.dmSans(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.25, end: 0),

            const SizedBox(height: 8),

            /// 🪐 Subtitle
            Text(
              "Explore cosmic products",
              style: GoogleFonts.dmSans(fontSize: 16, color: Colors.white54),
            ).animate().fadeIn(delay: 500.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
