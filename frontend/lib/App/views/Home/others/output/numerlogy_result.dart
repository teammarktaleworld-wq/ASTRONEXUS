import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../ui_componets/cosmic/cosmic_one.dart';
import '../../../../../../ui_componets/glass/glass_card.dart';

class NumerologyResult extends StatelessWidget {
  final String name;
  final String dob;
  final String additionalInfo;

  const NumerologyResult({
    super.key,
    required this.name,
    required this.dob,
    required this.additionalInfo,
  });

  int _calculateLifePathNumber(String dob) {
    final digits = dob.replaceAll('-', '').split('').map(int.parse);
    int sum = digits.reduce((a, b) => a + b);
    while (sum > 9) {
      sum = sum.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final lifePathNumber = _calculateLifePathNumber(dob);

    return Scaffold(
      body: Stack(
        children: [
          // Cosmic background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff050B1E),
                  Color(0xff3C467B),
                  Color(0xff1C4D8D),
                  Color(0xff0F2854),
                  Color(0xff050B1E),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(ignoring: true, child: SmoothShootingStars()),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(color: Colors.black.withOpacity(0.45)),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header
                  _BirthchartTopBar(),
                  const SizedBox(height: 30),
                  Text(
                    "Discover your Life Path Number & insights",
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Card
                  Container(
                    width: double.infinity,
                    child: glassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Hello, $name ✨",
                              style: GoogleFonts.dmSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Date of Birth: $dob",
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            if (additionalInfo.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                additionalInfo,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Life Path Number Card
                  glassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            "Your Life Path Number",
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFDBC33F),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Number Circle
                          Container(
                            height: 90,
                            width: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF916DBA), Color(0xFF413154)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "$lifePathNumber",
                              style: GoogleFonts.dmSans(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),
                          Text(
                            _getLifePathDescription(lifePathNumber),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Back Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDBC33F),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 40,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        "Back",
                        style: GoogleFonts.dmSans(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLifePathDescription(int number) {
    switch (number) {
      case 1:
        return "You are a natural leader with strong ambition and independence.";
      case 2:
        return "You are intuitive, cooperative, and emotionally intelligent.";
      case 3:
        return "Creative and expressive, you bring joy to others.";
      case 4:
        return "Disciplined and practical, you build strong foundations.";
      case 5:
        return "Adventurous and dynamic, you thrive on freedom.";
      case 6:
        return "Caring and responsible, family is your strength.";
      case 7:
        return "Spiritual and analytical, you seek deep truths.";
      case 8:
        return "Powerful and goal-driven, success follows you.";
      case 9:
        return "Compassionate and humanitarian, you uplift others.";
      default:
        return "Your destiny is unique and powerful.";
    }
  }
}

PreferredSizeWidget _BirthchartTopBar() {
  return PreferredSize(
    preferredSize: const Size.fromHeight(100),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08), // glassy effect
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  "Numerology Result",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
