import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';

class AriesDietProfileScreen extends StatefulWidget {
  const AriesDietProfileScreen({super.key});

  @override
  State<AriesDietProfileScreen> createState() => _AriesDietProfileScreenState();
}

class _AriesDietProfileScreenState extends State<AriesDietProfileScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/animation/back.mp4')
      ..initialize().then((_) {
        _videoController
          ..setLooping(true)
          ..setVolume(0)
          ..play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// BACKGROUND VIDEO
          if (_videoController.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),

          /// STRONG DARK OVERLAY
          Container(color: Colors.black.withOpacity(0.75)),

          /// CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [SizedBox(height: 60), const _DietProfileCard()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔹 MAIN DARK CARD
class _DietProfileCard extends StatelessWidget {
  const _DietProfileCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E11).withOpacity(0.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      LucideIcons.flame,
                      color: Colors.orangeAccent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ARIES DIET PROFILE",
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Element: Fire • Ruling Planet: Mars",
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.mars, color: Colors.redAccent),
                ],
              ),

              const SizedBox(height: 26),

              /// NUTRITIONAL PERSONALITY
              const _SectionTitle("Nutritional Personality"),
              const _InfoBox(
                "Energetic and action-driven. Requires high-protein meals for endurance and recovery. Sensitive to inflammation.",
              ),

              const SizedBox(height: 22),

              /// FOODS TO AVOID
              const _SectionTitle("Foods to Avoid"),
              const Row(
                children: [
                  _FoodAvoid(icon: LucideIcons.flame, label: "Excess Spice"),
                  SizedBox(width: 12),
                  _FoodAvoid(icon: LucideIcons.trash2, label: "Processed Food"),
                ],
              ),

              const SizedBox(height: 22),

              /// DAILY MEAL PLAN
              const _SectionTitle("Daily Meal Plan"),
              const SizedBox(height: 10),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [_MealImage(), _MealImage(), _MealImage()],
                ),
              ),

              const SizedBox(height: 22),

              /// SUPERFOODS
              const _SectionTitle("Superfoods"),
              const _InfoBox(
                "Cooling herbs, leafy greens, turmeric, ginger, grounding roots.",
              ),
              SizedBox(height: 10),
              const _InfoBox(
                "Cooling herbs, leafy greens, turmeric, ginger, grounding roots.",
              ),
              SizedBox(height: 10),
              const _InfoBox(
                "Cooling herbs, leafy greens, turmeric, ginger, grounding roots.",
              ),
              SizedBox(height: 10),
              const _InfoBox(
                "Cooling herbs, leafy greens, turmeric, ginger, grounding roots.",
              ),
              SizedBox(height: 10),
              const _InfoBox(
                "Cooling herbs, leafy greens, turmeric, ginger, grounding roots.",
              ),
              SizedBox(height: 10),
              const _InfoBox(
                "Cooling herbs, leafy greens, turmeric, ginger, grounding roots.",
              ),
              SizedBox(height: 10),
              const _InfoBox(
                "Cooling herbs, leafy greens, turmeric, ginger, grounding roots.",
              ),
              SizedBox(height: 10),
              const _InfoBox(
                "Cooling herbs, leafy greens, turmeric, ginger, grounding roots.",
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔹 REUSABLE COMPONENTS

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;
  const _InfoBox(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          color: Colors.white70,
          height: 1.5,
        ),
      ),
    );
  }
}

class _FoodAvoid extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FoodAvoid({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.orangeAccent, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealImage extends StatelessWidget {
  const _MealImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,

      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: const Icon(LucideIcons.utensils, color: Colors.white54),
    );
  }
}
