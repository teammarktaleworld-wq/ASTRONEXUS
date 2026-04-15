import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../ui_componets/cosmic/cosmic_one.dart';

class AstrologerListScreen extends StatefulWidget {
  const AstrologerListScreen({super.key});

  @override
  State<AstrologerListScreen> createState() => _AstrologerListScreenState();
}

class _AstrologerListScreenState extends State<AstrologerListScreen>
    with SingleTickerProviderStateMixin {
  final PageController _bannerController = PageController();
  int _currentBanner = 0;

  late AnimationController starController;
  FallingStarPainter? starPainter;

  final List<String> bannerImages = [
    "https://images.pexels.com/photos/2150/sky-stars-night-galaxy.jpg?auto=compress&cs=tinysrgb&w=1600",
    "https://images.pexels.com/photos/3225517/pexels-photo-3225517.jpeg?auto=compress&cs=tinysrgb&w=1600",
    "https://images.pexels.com/photos/371548/pexels-photo-371548.jpeg?auto=compress&cs=tinysrgb&w=1600",
  ];

  final List<Map<String, dynamic>> services = [
    {"title": "Love Astrology", "icon": LucideIcons.heart},
    {"title": "Career Guidance", "icon": LucideIcons.briefcase},
    {"title": "Numerology", "icon": LucideIcons.hash},
    {"title": "Life Astrology", "icon": LucideIcons.star},
    {"title": "Planetary Aspects", "icon": LucideIcons.sun},
    {"title": "Horoscope", "icon": LucideIcons.moon},
  ];

  final List<Map<String, dynamic>> astrologers = [
    {
      "name": "Vaibhav Joshi",
      "rating": 5,
      "experience": "13 Years",
      "price": "₹75/min",
      "languages": "English, French +1 more",
      "skills": "Life Astrology, Planetary Aspects +2 more",
      "status": "Online",
      "image":
          "https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=200",
    },
    {
      "name": "Aiden Billowe",
      "rating": 4,
      "experience": "4 Years",
      "price": "₹45/min",
      "languages": "English, German +1 more",
      "skills": "Life Astrology, Planetary Aspects +2 more",
      "status": "Offline",
      "image":
          "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=200",
    },
    {
      "name": "Priya Joshi",
      "rating": 5,
      "experience": "9 Years",
      "price": "₹90/min",
      "languages": "English, French",
      "skills": "Love Astrology, Career Guidance",
      "status": "Online",
      "image":
          "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=200",
    },
    {
      "name": "Rahul Mehta",
      "rating": 4,
      "experience": "6 Years",
      "price": "₹60/min",
      "languages": "English, German",
      "skills": "Life Astrology, Numerology",
      "status": "Offline",
      "image":
          "https://images.pexels.com/photos/712513/pexels-photo-712513.jpeg?auto=compress&cs=tinysrgb&w=200",
    },
  ];

  @override
  void initState() {
    super.initState();

    // Animate banners every 4 seconds
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentBanner < bannerImages.length - 1) {
        _currentBanner++;
      } else {
        _currentBanner = 0;
      }
      _bannerController.animateToPage(
        _currentBanner,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });

    // Initialize star animation
    starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xff121212),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff050B1E),
                  // Color(0xff1C4D8D),
                  // Color(0xff0F2854),
                  Color(0xff393053),
                  Color(0xff050B1E),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Positioned.fill(child: SmoothShootingStars()),
          // 🌌 Falling stars background
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

          // 🌟 Foreground UI
          SafeArea(
            child: Column(
              children: [
                _modernTopBar(),
                const SizedBox(height: 20),

                // Banner
                SizedBox(
                  height: 160,
                  child: PageView.builder(
                    controller: _bannerController,
                    itemCount: bannerImages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentBanner = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            bannerImages[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Banner indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    bannerImages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: _currentBanner == index ? 18 : 8,
                      decoration: BoxDecoration(
                        color: _currentBanner == index
                            ? const Color(0xffDBC33F)
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Services Scroll
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              service["icon"],
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              service["title"],
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Astrologers list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: astrologers.length,
                    itemBuilder: (context, index) {
                      final astro = astrologers[index];
                      final isOnline = astro["status"] == "Online";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.black12,
                          border: Border.all(color: Colors.white12, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  astro["image"],
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 70,
                                        width: 70,
                                        color: Colors.grey.shade800,
                                        child: const Icon(
                                          Icons.person,
                                          size: 30,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            astro["name"],
                                            style: GoogleFonts.dmSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          LucideIcons.badgeCheck,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      astro["skills"],
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          LucideIcons.languages,
                                          size: 15,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            astro["languages"],
                                            style: GoogleFonts.dmSans(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _infoItem(
                                          LucideIcons.award,
                                          astro["experience"],
                                        ),
                                        _infoItem(
                                          LucideIcons.indianRupee,
                                          astro["price"],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isOnline
                                                ? Colors.green
                                                : Colors.redAccent,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            astro["status"],
                                            style: GoogleFonts.dmSans(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _modernTopBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white70),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  Text(
                    "Astrologers",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(
                        "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}

// Falling star painter
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
