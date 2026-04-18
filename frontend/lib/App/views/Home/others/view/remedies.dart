import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AstroRemediesPage extends StatelessWidget {
  const AstroRemediesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Astro Remedies",
          style: GoogleFonts.dmSans(
            color: const Color(0xFFDBC33F),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFFDBC33F),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 🌙 Decorative background circles
            Positioned(
              top: -80,
              left: -60,
              child: _bgCircle(200, const Color(0x403B3B98)),
            ),
            Positioned(
              bottom: -70,
              right: -40,
              child: _bgCircle(180, const Color(0x40FFC371)),
            ),
            Positioned(
              top: 320,
              right: -100,
              child: _bgCircle(260, const Color(0x4080FFD2)),
            ),

            // 🌟 Scrollable content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _remedyCard(
                    title: "Shani (Saturn)",
                    description:
                        "Shani signifies discipline, patience, and karma. Strengthening Saturn brings stability and long-term success.",
                    mantra: "🔯 Om Sham Shanicharaya Namah",
                    gemstone: "💎 Blue Sapphire (Neelam)",
                    tip:
                        "🪔 Light sesame oil lamp on Saturdays & feed black dogs.",
                  ),
                  const SizedBox(height: 18),
                  _remedyCard(
                    title: "Surya (Sun)",
                    description:
                        "Surya governs energy, confidence, and leadership. A strong Sun enhances authority and self-esteem.",
                    mantra: "🔯 Om Hram Hreem Hraum Suryaya Namah",
                    gemstone: "💎 Ruby (Manik)",
                    tip:
                        "🌞 Offer water to the rising Sun & wear red on Sundays.",
                  ),
                  const SizedBox(height: 18),
                  _remedyCard(
                    title: "Chandra (Moon)",
                    description:
                        "Chandra rules emotions and peace. Strengthening Moon brings calmness and emotional balance.",
                    mantra: "🔯 Om Chandraya Namah",
                    gemstone: "💎 Pearl (Moti)",
                    tip: "🌙 Drink water from a silver vessel on Mondays.",
                  ),
                  const SizedBox(height: 18),
                  _remedyCard(
                    title: "Mangal (Mars)",
                    description:
                        "Mangal represents courage and strength. Balanced Mars removes anger and increases focus.",
                    mantra: "🔯 Om Angarakaya Namah",
                    gemstone: "💎 Red Coral (Moonga)",
                    tip:
                        "🔥 Chant Hanuman Chalisa & donate red lentils on Tuesday.",
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "✨ Align your stars, live your destiny ✨",
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFDBC33F),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🌟 Remedy Card Widget
  Widget _remedyCard({
    required String title,
    required String description,
    required String mantra,
    required String gemstone,
    required String tip,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDBC33F), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFDBC33F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.dmSans(
              fontSize: 14.5,
              height: 1.6,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          _infoLine(mantra),
          _infoLine(gemstone),
          _infoLine(tip),
        ],
      ),
    );
  }

  // 🌟 Info Line
  Widget _infoLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),
    );
  }

  // 🌟 Background Circle
  Widget _bgCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
