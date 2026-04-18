import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Tarot/SplashTarot.dart';
import '../../options/IconScreen/views/horoscope/splashHoroscope.dart';
import '../others/splash/splashbirth.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  int currentBanner = 0;
  late Timer _timer;

  final List<Map<String, dynamic>> banners = [
    {
      "image": "assets/images/banner_mati.jpeg",
      "title": "Explore Tarot",
      "destination": Splashtarot(),
    },
    {
      "image": "assets/images/banner_chart.jpeg",
      "title": "Check Your Horoscope",
      "destination": SplashHoroscope(),
    },
    {
      "image": "assets/images/banner_tarot.jpeg",
      "title": "Unlock Birth Chart",
      "destination": SplashBirth(),
    },
  ];

  @override
  void initState() {
    super.initState();

    // Auto-scroll every 4 seconds
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = currentBanner + 1;
        if (nextPage >= banners.length) nextPage = 0;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff18122B),
      child: Column(
        children: [
          SizedBox(height: 15),
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => currentBanner = i),
                  itemCount: banners.length,
                  itemBuilder: (_, i) {
                    final banner = banners[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => banner['destination'],
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Banner image
                                Image.asset(banner['image'], fit: BoxFit.cover),
                                // Gradient overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.1),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                // Banner title button
                                // Positioned(
                                //   bottom: 16,
                                //   left: 16,
                                //   child: Container(
                                //
                                //     padding: const EdgeInsets.symmetric(
                                //         horizontal: 20, vertical: 10),
                                //     decoration: BoxDecoration(
                                //       color: Colors.white,
                                //       borderRadius: BorderRadius.circular(16),
                                //       boxShadow: [
                                //         BoxShadow(
                                //           color: Colors.black.withOpacity(0.3),
                                //           blurRadius: 8,
                                //           offset: const Offset(0, 4),
                                //         ),
                                //       ],
                                //     ),
                                //     child: Text(
                                //       banner['title'],
                                //       style: GoogleFonts.dmSans(
                                //         color: Colors.black,
                                //         fontWeight: FontWeight.w600,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Page indicators
              ],
            ),
          ),
        ],
      ),
    );
  }
}
