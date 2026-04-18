import "package:astro_tale/core/theme/app_gradients.dart";
import "package:astro_tale/core/widgets/animated_app_background.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "horoscope_detail_screen.dart";

class HoroscopeScreen extends StatefulWidget {
  const HoroscopeScreen({super.key});

  @override
  State<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends State<HoroscopeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppGradients.glassFill(theme).withValues(alpha: 0.86)
        : Colors.white.withValues(alpha: 0.92);
    final borderColor = isDark ? Colors.white24 : const Color(0xFFD7E4F8);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final bodyColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppGradients.glassFill(theme)
            : Colors.white.withValues(alpha: 0.94),
        foregroundColor: titleColor,
        iconTheme: IconThemeData(color: titleColor),
        actionsIconTheme: IconThemeData(color: titleColor),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Daily Horoscope",
          style: GoogleFonts.dmSans(
            color: titleColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: AnimatedAppBackground(
        showStarsInDark: true,
        showStarsInLight: true,
        child: Stack(
          children: <Widget>[
            if (!isDark) Positioned.fill(child: _lightHoroscopeAura()),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Text(
                      "Select your zodiac sign to reveal today's guidance",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        color: isDark
                            ? Colors.white70
                            : colors.onSurface.withValues(alpha: 0.76),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.32)
                                : const Color(
                                    0xFF9AAECE,
                                  ).withValues(alpha: 0.2),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Choose Your Zodiac",
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Tap a sign to explore daily, weekly and monthly insights",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: bodyColor,
                            ),
                          ),
                          const SizedBox(height: 18),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: zodiacData.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 0.92,
                                ),
                            itemBuilder: (context, index) {
                              final item = zodiacData[index];
                              return InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HoroscopeDetailScreen(
                                        sign: item["name"]!,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.white.withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white24
                                          : const Color(0xFFD8E4F7),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset(
                                        "assets/horoscope/${item["name"]!.toLowerCase()}.png",
                                        height: 38,
                                        width: 38,
                                        color: isDark
                                            ? const Color(0xFFDBC33F)
                                            : const Color(0xFF2563EB),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item["name"]!,
                                        style: GoogleFonts.dmSans(
                                          color: titleColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lightHoroscopeAura() {
    return IgnorePointer(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -36,
            right: -20,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[Color(0x66C4B5FD), Color(0x00C4B5FD)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[Color(0x66FDE68A), Color(0x00FDE68A)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final List<Map<String, String>> zodiacData = <Map<String, String>>[
  {"name": "Aries"},
  {"name": "Taurus"},
  {"name": "Gemini"},
  {"name": "Cancer"},
  {"name": "Leo"},
  {"name": "Virgo"},
  {"name": "Libra"},
  {"name": "Scorpio"},
  {"name": "Sagittarius"},
  {"name": "Capricorn"},
  {"name": "Aquarius"},
  {"name": "Pisces"},
];
