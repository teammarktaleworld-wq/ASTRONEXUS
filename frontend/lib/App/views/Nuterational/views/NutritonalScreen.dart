import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../parts/features/features.dart';

// Models
class CosmicProfileItem {
  final String title;
  final IconData icon;

  CosmicProfileItem({required this.title, required this.icon});
}

class FeatureItem {
  final String title;
  final IconData icon;

  FeatureItem({required this.title, required this.icon});
}

class NutritionalAstrologyScreen extends StatelessWidget {
  const NutritionalAstrologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cosmicProfile = [
      CosmicProfileItem(title: "Sun Sign", icon: LucideIcons.sun),
      CosmicProfileItem(title: "Moon Sign", icon: LucideIcons.moon),
      CosmicProfileItem(title: "Element", icon: LucideIcons.circle),
    ];

    final features = [
      FeatureItem(title: "Foods for Your Zodiac", icon: LucideIcons.apple),
      FeatureItem(title: "Moon Sign Diet", icon: LucideIcons.moon),
      FeatureItem(title: "Body & Nutrition", icon: LucideIcons.heartPulse),
      FeatureItem(title: "Element Diet", icon: LucideIcons.flame),
      FeatureItem(title: "Planet Influence", icon: LucideIcons.orbit),
      FeatureItem(title: "Healing Herbs", icon: LucideIcons.leaf),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1C1C2E), Color(0xFF121217)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "NUTRITIONAL\nASTROLOGY",
                    style: GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white12,
                    child: Icon(LucideIcons.user, color: Colors.white),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

              const SizedBox(height: 28),

              /// COSMIC PROFILE
              Text(
                "YOUR COSMIC PROFILE",
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: cosmicProfile.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1F),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              item.icon,
                              color: Colors.greenAccent,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.title,
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(delay: (300 + index * 100).ms)
                      .scale(begin: const Offset(0.9, 0.9));
                }).toList(),
              ),

              const SizedBox(height: 28),

              /// FEATURES GRID
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: features.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.15,
                  ),
                  itemBuilder: (context, index) {
                    final feature = features[index];

                    return Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child:
                          InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AriesDietProfileScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A1F),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.35),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.08),
                                        ),
                                        child: Icon(
                                          feature.icon,
                                          color: Colors.greenAccent,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        feature.title,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(delay: (400 + index * 80).ms)
                              .scale(begin: const Offset(0.95, 0.95)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
