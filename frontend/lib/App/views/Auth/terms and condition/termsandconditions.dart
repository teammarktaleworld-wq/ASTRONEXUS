import 'package:astro_tale/core/widgets/unified_dark_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../ui_componets/cosmic/cosmic_one.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: UnifiedDarkUi.appBar(context, title: 'Terms & Conditions'),
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
                    height: 150,
                    width: 300,
                  ),
                  const SizedBox(height: 10),
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
                        Center(
                          child: Text(
                            'Welcome to AstroNexus',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            'By using our application, you agree to the following terms and conditions. Please read them carefully.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _sectionTitle('1. Acceptance of Terms'),
                        _sectionText(
                          'By creating an account or using our services, you agree to comply with and be bound by these terms and conditions.',
                        ),
                        _sectionTitle('2. User Responsibilities'),
                        _sectionText(
                          'You agree to use the app only for lawful purposes and not to misuse or harm the platform or other users.',
                        ),
                        _sectionTitle('3. Account Security'),
                        _sectionText(
                          'You are responsible for maintaining the confidentiality of your login credentials and account activity.',
                        ),
                        _sectionTitle('4. Privacy Policy'),
                        _sectionText(
                          'We respect your privacy. Personal data is handled securely and not shared without consent.',
                        ),
                        _sectionTitle('5. Limitation of Liability'),
                        _sectionText(
                          'AstroNexus is not liable for damages arising from use or inability to use the application.',
                        ),
                        _sectionTitle('6. Updates to Terms'),
                        _sectionText(
                          'These terms may be updated from time to time. Continued usage implies acceptance of updates.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 16),
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
    return Text(
      text,
      style: GoogleFonts.dmSans(
        color: Colors.white70,
        fontSize: 14,
        height: 1.5,
      ),
    );
  }
}
