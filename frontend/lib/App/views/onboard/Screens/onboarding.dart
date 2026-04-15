import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../ui_componets/cosmic/cosmic_one.dart';
import '../../Auth/Login_phone/screens/phone_login_screen.dart';
import 'package:astro_tale/util/images.dart';

import '../../Auth/login_phone__pass/screen/login_phone_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardData = [
    {
      "title": "Welcome to AstroNexus",
      "desc":
          "Unlock the mysteries of your stars and understand how the universe shapes your journey. Whether you’re a beginner or a seasoned believer, AstroGuide helps you explore your zodiac, horoscope, and destiny with clarity.",
      "image": Images.onboard1,
    },
    {
      "title": "Personalized Predictions",
      "desc":
          "Receive daily, weekly, and yearly predictions crafted just for you. Our AI-powered astrology combines Vedic knowledge and modern data science to deliver accurate insights about your career, love, and destiny.",
      "image": Images.onboard2,
    },
    {
      "title": "Daily Celestial Guidance",
      "desc":
          "Receive accurate horoscope predictions for love, career, and well-being. Wake up every morning with cosmic advice made just for you.",
      "image": Images.onboard3,
    },
    {
      "title": "Begin Your Cosmic Journey",
      "desc":
          "Join thousands of seekers who find clarity, love, and balance through the wisdom of astrology. Let’s begin your cosmic story today.",
      "image": Images.onboard4,
    },
  ];

  void _nextPage() {
    if (_currentPage < _onboardData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  /// ✅ Mark onboarding as seen and go to login
  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("onboarding_seen", true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPhoneScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.width >= 600;
    final bool isSmallPhone = size.height < 700;

    final double imageHeight = isTablet
        ? 320
        : isSmallPhone
        ? size.height * 0.26
        : size.height * 0.32;
    final double cardHeight = isTablet
        ? 340
        : isSmallPhone
        ? 280
        : 320;
    final double titleSize = isTablet ? 24 : 22;
    final double descSize = isTablet ? 15 : 14;

    return Scaffold(
      body: Stack(
        children: [
          // 🌌 BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff050B1E),
                  Color(0xff393053),
                  Color(0xff050B1E),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned.fill(child: SmoothShootingStars()),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _onboardData.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (context, index) {
                      final data = _onboardData[index];

                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 540),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 24),
                                // 🖼 IMAGE CARD
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.4),
                                        blurRadius: 30,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.asset(
                                      data['image']!,
                                      height: imageHeight,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),
                                // 🪟 GLASS CONTENT CARD
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 18,
                                      sigmaY: 18,
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      height: cardHeight,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 22,
                                        vertical: 24,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xff050B1E,
                                        ).withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.12),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.35,
                                            ),
                                            blurRadius: 30,
                                            offset: const Offset(0, 14),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 12),
                                          Text(
                                            data['title']!,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.dmSans(
                                              fontSize: titleSize,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Text(
                                            data['desc']!,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.dmSans(
                                              fontSize: descSize,
                                              height: 1.6,
                                              color: Colors.white60,
                                            ),
                                          ),
                                          if (index ==
                                              _onboardData.length - 1) ...[
                                            const Spacer(),
                                            SizedBox(
                                              width: double.infinity,
                                              height: 48,
                                              child: ElevatedButton(
                                                onPressed: _finishOnboarding,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFFFFC700,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          14,
                                                        ),
                                                  ),
                                                  elevation: 0,
                                                ),
                                                child: Text(
                                                  "Get Started",
                                                  style: GoogleFonts.dmSans(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 🔘 BOTTOM CONTROLS
                if (_currentPage != _onboardData.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _finishOnboarding,
                          child: Text(
                            "Skip",
                            style: GoogleFonts.dmSans(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        SmoothPageIndicator(
                          controller: _controller,
                          count: _onboardData.length,
                          effect: const ExpandingDotsEffect(
                            dotHeight: 6,
                            dotWidth: 6,
                            activeDotColor: Color(0xFFFFC733),
                            dotColor: Colors.white38,
                            spacing: 6,
                            expansionFactor: 3,
                          ),
                        ),
                        TextButton(
                          onPressed: _nextPage,
                          child: Text(
                            "Next",
                            style: GoogleFonts.dmSans(
                              color: const Color(0xFFFFC700),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
