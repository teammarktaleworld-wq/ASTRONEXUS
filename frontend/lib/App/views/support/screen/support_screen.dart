import 'package:astro_tale/core/widgets/unified_dark_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../ui_componets/cosmic/cosmic_one.dart';

class AstroSupportScreen extends StatelessWidget {
  const AstroSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: UnifiedDarkUi.appBar(context, title: 'Astro Support'),
      body: Stack(
        children: [
          Container(decoration: UnifiedDarkUi.screenBackground(theme)),
          Positioned.fill(child: SmoothShootingStars()),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 140,
                    width: 280,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          UnifiedDarkUi.cardSurface(theme),
                          UnifiedDarkUi.cardSurfaceAlt(theme),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: UnifiedDarkUi.cardBorder(theme),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _centerTitle('Welcome to AstroNexus Support'),
                        _centerSubtitle(
                          'Your cosmic guide to astrology insights, technical help, and spiritual clarity.',
                        ),
                        const SizedBox(height: 28),
                        _sectionTitle('Astrology and Cosmic Guidance'),
                        _sectionText(
                          'AstroNexus combines astrological wisdom with modern insights. Astrology helps you understand planetary movements, zodiac influences, and how celestial energies shape your life journey.',
                        ),
                        _sectionText(
                          'Each birth chart is unique. Your zodiac sign, moon placement, rising sign, and planetary aspects work together to shape your personality, strengths, and challenges.',
                        ),
                        _sectionText(
                          'The app provides daily horoscopes, compatibility insights, planetary transits, and spiritual guidance to help you align with the universe.',
                        ),
                        _sectionTitle('Zodiac Signs Overview'),
                        _sectionText(
                          'The zodiac has 12 signs with different elements and ruling planets. Fire signs are energetic, Earth signs are practical, Air signs are intellectual, and Water signs are intuitive.',
                        ),
                        _sectionText(
                          'Understanding your zodiac sign helps identify behavior patterns, emotional needs, and life motivations.',
                        ),
                        _sectionTitle('Planetary Influence'),
                        _sectionText(
                          'Mercury, Venus, Mars, Jupiter, and Saturn influence communication, love, ambition, growth, and discipline. Their transits can trigger life changes.',
                        ),
                        _sectionText(
                          'Retrogrades, eclipses, and transits are important cosmic events. AstroNexus tracks these events and translates them into clear guidance.',
                        ),
                        _sectionTitle('App Support and Assistance'),
                        _sectionText(
                          'If you face issues like login problems, missing horoscope data, crashes, or performance issues, support is available to help.',
                        ),
                        _sectionText(
                          'Keep your app updated to the latest version for best stability and feature improvements.',
                        ),
                        _sectionTitle('Frequently Asked Questions'),
                        _sectionText(
                          '- Why is my horoscope not updating?\nHoroscope updates depend on network and server synchronization.\n\n'
                          '- Is my data secure?\nYes, AstroNexus uses industry-standard protection.\n\n'
                          '- Can I change my birth details?\nYes, you can update them from profile settings.',
                        ),
                        _sectionTitle('Contact Support'),
                        _sectionText(
                          'For further help, contact support directly through the app. Typical response time is 24 to 48 hours.',
                        ),
                        _sectionText(
                          'AstroNexus values your spiritual journey and technical experience equally. Your feedback helps us improve.',
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Text(
                            'Stay aligned with the cosmos',
                            style: GoogleFonts.dmSans(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
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
    );
  }

  Widget _centerTitle(String text) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.dmSans(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _centerSubtitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 22),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          color: const Color(0xFFDBC33F),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          color: Colors.white70,
          fontSize: 14,
          height: 1.6,
        ),
      ),
    );
  }
}
