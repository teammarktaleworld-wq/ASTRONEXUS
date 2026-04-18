import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astro_tale/App/views/Ai(chatbot)/View/Chatbot.dart';

class ChartPageDark extends StatelessWidget {
  final String name;
  final String dob;
  final String tob;
  final String pob;

  const ChartPageDark({
    super.key,
    required this.name,
    required this.dob,
    required this.tob,
    required this.pob,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121212),
      body: Stack(
        children: [
          // Soft circular background decorations
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.indigo.withOpacity(0.2),
              ),
            ),
          ),

          // Main scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                _buildUserInfoCard(),
                const SizedBox(height: 25),
                _buildAstroSummary(),
                const SizedBox(height: 30),
                Text(
                  "Vedic Birth Chart",
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildKundliChart(),
                const SizedBox(height: 30),
                _buildPlanetTable(),
                const SizedBox(height: 25),
                _buildDoshaSection(),
                const SizedBox(height: 25),
                _buildInsightsSection(),
                const SizedBox(height: 80), // spacing for floating button
              ],
            ),
          ),

          // Floating Chat Button
          Positioned(
            bottom: 25,
            right: 25,
            child: _chatFloatingButton(context),
          ),
        ],
      ),
    );
  }

  Widget _chatFloatingButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MatiChatBotScreen()),
        );
      },
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: const Color(0xffDBC33F),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.chat_bubble_outline_rounded,
          color: Colors.black,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      decoration: _darkCardDecoration(),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          Text(
            name,
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Date of Birth: $dob",
            style: GoogleFonts.dmSans(fontSize: 15, color: Colors.grey[300]),
          ),
          Text(
            "Time of Birth: $tob",
            style: GoogleFonts.dmSans(fontSize: 15, color: Colors.grey[300]),
          ),
          Text(
            "Place of Birth: $pob",
            style: GoogleFonts.dmSans(fontSize: 15, color: Colors.grey[300]),
          ),
        ],
      ),
    );
  }

  Widget _buildAstroSummary() {
    final details = [
      {"label": "Rashi", "value": "Simha (Leo) ♌"},
      {"label": "Nakshatra", "value": "Magha"},
      {"label": "Ascendant", "value": "Karka (Cancer) ♋"},
      {"label": "Element", "value": "Fire 🔥"},
      {"label": "Lucky Number", "value": "1"},
      {"label": "Lucky Color", "value": "Gold ✨"},
    ];

    return Container(
      decoration: _darkCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Astro Summary",
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: details
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${item['label']}: ${item['value']}",
                      style: GoogleFonts.dmSans(color: Colors.white70),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildKundliChart() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _darkCardDecoration(),
      child: AspectRatio(
        aspectRatio: 1,
        child: CustomPaint(
          painter: _KundliPainterDark(),
          child: Center(
            child: Text(
              "Kundli",
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanetTable() {
    final planets = [
      {'Planet': '☉ Sun', 'Sign': 'Leo ♌', 'House': '1st'},
      {'Planet': '☽ Moon', 'Sign': 'Cancer ♋', 'House': '2nd'},
      {'Planet': '♂ Mars', 'Sign': 'Aries ♈', 'House': '3rd'},
      {'Planet': '☿ Mercury', 'Sign': 'Gemini ♊', 'House': '4th'},
      {'Planet': '♃ Jupiter', 'Sign': 'Sagittarius ♐', 'House': '7th'},
      {'Planet': '♀ Venus', 'Sign': 'Taurus ♉', 'House': '5th'},
      {'Planet': '♄ Saturn', 'Sign': 'Capricorn ♑', 'House': '10th'},
      {'Planet': '☊ Rahu', 'Sign': 'Pisces ♓', 'House': '11th'},
      {'Planet': '☋ Ketu', 'Sign': 'Virgo ♍', 'House': '5th'},
    ];

    return Container(
      decoration: _darkCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Planetary Positions",
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...planets.map(
            (p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    p['Planet']!,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    p['Sign']!,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    p['House']!,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey[400],
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

  Widget _buildDoshaSection() {
    final doshas = [
      {
        "name": "Manglik Dosha",
        "effect":
            "High energy & passion. May cause delays in marriage if unbalanced.",
      },
      {
        "name": "Kaal Sarp Dosha",
        "effect":
            "Influences career stability. Regular spiritual practices recommended.",
      },
      {
        "name": "Pitra Dosha",
        "effect":
            "Signifies ancestral imbalance. Offerings advised on Amavasya.",
      },
    ];

    return Container(
      decoration: _darkCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Detected Doshas / Yogas",
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          ...doshas.map(
            (d) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d["name"]!,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    d["effect"]!,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white70,
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

  Widget _buildInsightsSection() {
    final insights = [
      "You possess natural leadership qualities with a strong sense of responsibility.",
      "Your moon in Cancer shows deep emotional intelligence and nurturing nature.",
      "You’re likely to succeed in creative or leadership roles.",
      "Spiritual growth brings balance to your passionate energy.",
    ];

    return Container(
      decoration: _darkCardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Astro Insights",
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          ...insights.map(
            (point) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white70,
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

  BoxDecoration _darkCardDecoration() {
    return BoxDecoration(
      color: const Color(0xff1E1E2E),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

class _KundliPainterDark extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    // Outer square
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);

    // Inner diagonals
    canvas.drawLine(Offset(0, 0), Offset(w, h), paint);
    canvas.drawLine(Offset(w, 0), Offset(0, h), paint);

    // Middle cross
    canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), paint);
    canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), paint);

    // Diamond in center
    final path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h / 2)
      ..lineTo(w / 2, h)
      ..lineTo(0, h / 2)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
