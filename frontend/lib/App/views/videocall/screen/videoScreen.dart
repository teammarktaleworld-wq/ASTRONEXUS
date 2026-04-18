import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../ui_componets/cosmic/cosmic_one.dart';

class AstrologerListVideoScreen extends StatefulWidget {
  const AstrologerListVideoScreen({super.key});

  @override
  State<AstrologerListVideoScreen> createState() =>
      _AstrologerListVideoScreenState();
}

class _AstrologerListVideoScreenState extends State<AstrologerListVideoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _starController;
  late StarField _starField;

  @override
  void initState() {
    super.initState();

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _starField = StarField.generate(count: 90);
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050B1E),
      body: Stack(
        children: [
          /// 🌌 Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff050B1E),

                  Color(0xff1C4D8D),
                  Color(0xff0F2854),
                  Color(0xff050B1E),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          Positioned.fill(child: SmoothShootingStars()),

          /// ⭐ Falling Stars Layer
          AnimatedBuilder(
            animation: _starController,
            builder: (_, __) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: StarPainter(
                  progress: _starController.value,
                  field: _starField,
                ),
              );
            },
          ),

          /// 🌟 Foreground UI
          SafeArea(
            child: Column(
              children: [
                _glassAppBar(),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _categoryStrip(),
                        const SizedBox(height: 22),
                        _featuredAstrologer(),
                        const SizedBox(height: 28),
                        _sectionTitle("Available Now"),
                        const SizedBox(height: 14),
                        _astrologerGrid(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔮 GLASS APP BAR
  Widget _glassAppBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
        color: Colors.white.withOpacity(0.08),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.menu, color: Colors.white70),
                Text(
                  "Video Astrologers",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📊 CATEGORY STRIP
  Widget _categoryStrip() {
    final categories = [
      {"title": "Video", "count": "42"},
      {"title": "Tarot", "count": "18"},
      {"title": "Numerology", "count": "25"},
      {"title": "Marriage", "count": "31"},
    ];

    return SizedBox(
      height: 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 140,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff0E1A2B), Color(0xff020617)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categories[index]["title"]!,
                  style: GoogleFonts.dmSans(fontSize: 14, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  "${categories[index]["count"]} experts",
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ⭐ FEATURED ASTROLOGER
  Widget _featuredAstrologer() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Color(0xff0F2854),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7), // your desired color
            blurRadius: 12, // how soft the shadow is
            offset: const Offset(0, 6), // position of the shadow
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              "https://images.pexels.com/photos/712513/pexels-photo-712513.jpeg",
              height: 90,
              width: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rahul Mehta",
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Life Astrology & Numerology",
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _badge("⭐ 4.9"),
                    const SizedBox(width: 8),
                    _badge("₹80/min"),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(LucideIcons.video, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // 🧩 GRID
  Widget _astrologerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (_, __) => _gridCard(),
    );
  }

  Widget _gridCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color(0xff002455).withOpacity(.5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black54.withOpacity(0.5), // your desired color
            blurRadius: 12, // how soft the shadow is
            offset: const Offset(0, 6), // position of the shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Align(alignment: Alignment.topRight, child: _liveTag()),
          const SizedBox(height: 6),
          const CircleAvatar(
            radius: 38,
            backgroundImage: NetworkImage(
              "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg",
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Ananya Sharma",
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            "Tarot Specialist",
            style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white60),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹65/min",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  color: Colors.greenAccent,
                ),
              ),
              const Icon(LucideIcons.video, color: Colors.white70, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _liveTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "LIVE",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white70),
      ),
    );
  }
}

/* ======================= */
/* ⭐ STAR SYSTEM */
/* ======================= */

class StarField {
  final List<Offset> positions;
  final List<double> sizes;
  final List<double> speeds;

  StarField(this.positions, this.sizes, this.speeds);

  static StarField generate({int count = 80}) {
    final r = Random();
    return StarField(
      List.generate(count, (_) => Offset(r.nextDouble(), r.nextDouble())),
      List.generate(count, (_) => r.nextDouble() * 1.5 + 0.5),
      List.generate(count, (_) => r.nextDouble() * 400 + 60),
    );
  }
}

class StarPainter extends CustomPainter {
  final double progress;
  final StarField field;

  StarPainter({required this.progress, required this.field});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white24;

    for (int i = 0; i < field.positions.length; i++) {
      final x = field.positions[i].dx * size.width;
      final y =
          (field.positions[i].dy * size.height + progress * field.speeds[i]) %
          size.height;

      canvas.drawCircle(Offset(x, y), field.sizes[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) => true;
}
