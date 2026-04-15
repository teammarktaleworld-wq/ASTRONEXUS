import 'dart:math';
import 'package:astro_tale/App/views/Home/others/splash/splashbirth.dart';
import 'package:astro_tale/core/constants/app_colors.dart';
import 'package:astro_tale/core/localization/app_localizations.dart';
import 'package:astro_tale/core/theme/app_gradients.dart';
import 'package:astro_tale/core/widgets/animated_app_background.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:astro_tale/App/views/Home/others/view/splashNumerlogy.dart';
import 'package:astro_tale/App/views/Nuterational/views/splashnutrition.dart';
import 'package:astro_tale/App/views/Tarot/SplashTarot.dart';
import 'package:astro_tale/App/views/options/IconScreen/views/horoscope/splashHoroscope.dart';
import 'package:astro_tale/App/views/options/IconScreen/views/match/splashMatch.dart';

import '../subscription/views/subscription_screen.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen>
    with TickerProviderStateMixin {
  late AnimationController planetController;

  @override
  void initState() {
    super.initState();

    planetController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    )..repeat();
  }

  @override
  void dispose() {
    planetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.appBarDark
            : AppColors.lightContainer,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0.6,
        centerTitle: true,
        title: Text(
          context.l10n.tr("services"),
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: AppColors.onDark,
          ),
        ),
      ),
      body: AnimatedAppBackground(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: planetController,
              builder: (_, __) => _PlanetLayer(planetController.value),
            ),
            SafeArea(child: _content()),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: 18),
          // _servicesTopBar(),
          const SizedBox(height: 28),
          Expanded(child: _servicesGrid()),
        ],
      ),
    );
  }

  // ignore: unused_element
  PreferredSizeWidget _servicesTopBar() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return PreferredSize(
      preferredSize: Size.fromHeight(500),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppGradients.glassFill(theme),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppGradients.glassBorder(theme)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.l10n.tr("services"),
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : colors.onSurface,
                ),
              ),
              // Notification or Avatar
            ],
          ),
        ),
      ),
    );
  }

  Widget _servicesGrid() {
    final services = [
      _ServiceData(
        "Birth Chart",
        "assets/astrology/kundli.png",
        const Color(0xFFD4AF37),
        "Detailed birth chart analysis revealing life path, strengths, and planetary influences.",
        () => _go(SplashBirth()),
      ),
      _ServiceData(
        "Tarot",
        "assets/astrology/tarot.png",
        const Color(0xFF9B8CFF),
        "Intuitive tarot guidance offering clarity on love, career, and spiritual growth.",
        () => _go(const Splashtarot()),
      ),
      _ServiceData(
        "Numerology",
        "assets/astrology/numerology.png",
        const Color(0xFF7ED6C1),
        "Decode numbers connected to your destiny, personality traits, and life cycles.",
        () => _go(const SplashNumerology()),
      ),
      _ServiceData(
        "Horoscope",
        "assets/astrology/horoscope.png",
        const Color(0xFFE3E3E3),
        "Daily planetary insights to guide decisions, emotions, and opportunities.",
        () => _go(const SplashHoroscope()),
      ),
      _ServiceData(
        "Match",
        "assets/astrology/love.png",
        const Color(0xFFFF7A7A),
        "Compatibility analysis based on planetary harmony, emotions, and future potential.",
        () => _go(const SplashMatch()),
      ),
      _ServiceData(
        "Nutrition",
        "assets/astrology/nutrition.png",
        const Color(0xFF8BE78B),
        "Personalized food guidance aligned with zodiac energy and planetary balance.",
        () => _go(const Splashnutrition()),
      ),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Column(
            children: services
                .map(
                  (service) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: _ServiceCard(
                      data: service,
                      // Mark Tarot and Nutrition as premium
                      isPremium:
                          service.title == "Numerology" ||
                          service.title == "Nutrition" ||
                          service.title == "Match",
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  void _go(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

/*────────────────── ORBIT AVATAR ──────────────────*/
// ignore: unused_element
class _OrbitAvatar extends StatelessWidget {
  const _OrbitAvatar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withValues(alpha: .4),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 24,
          backgroundImage: AssetImage("assets/planets/planet1.png"),
        ),
      ],
    );
  }
}

/*────────────────── SERVICE CARD ──────────────────*/
class _ServiceCard extends StatelessWidget {
  final _ServiceData data;
  final bool isPremium;

  const _ServiceCard({required this.data, this.isPremium = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = Colors.white;
    final subtitleColor = Colors.white70;
    final cardColor = isDark ? AppColors.surface : AppColors.lightContainer;

    return InkWell(
      onTap: () {
        if (isPremium) {
          // Navigate to subscription page for premium services
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SubscriptionPage()),
          );
        } else {
          data.onTap();
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: data.color.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.22),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          data.color.withValues(alpha: .2),
                          data.color.withValues(alpha: .1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Image.asset(data.asset, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data.title,
                          style: GoogleFonts.dmSans(
                            color: titleColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          data.description,
                          style: GoogleFonts.dmSans(
                            color: subtitleColor,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),

              // LOCK ICON at top right for premium services
              if (isPremium)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/*────────────────── PLANETS ──────────────────*/
class _PlanetLayer extends StatelessWidget {
  final double progress;
  const _PlanetLayer(this.progress);

  @override
  Widget build(BuildContext context) {
    final t = progress * 2 * pi;
    return Stack(
      children: [
        Positioned(
          top: 140 + sin(t) * 30,
          right: -50,
          child: Image.asset(
            "assets/planets/planet1.png",
            height: 140,
            opacity: const AlwaysStoppedAnimation(.25),
          ),
        ),
        Positioned(
          bottom: 160 + cos(t) * 25,
          left: -50,
          child: Image.asset(
            "assets/planets/planet2.png",
            height: 110,
            opacity: const AlwaysStoppedAnimation(.22),
          ),
        ),
      ],
    );
  }
}

/*────────────────── DATA MODEL ──────────────────*/
class _ServiceData {
  final String title;
  final String asset;
  final Color color;
  final String description;
  final VoidCallback onTap;

  _ServiceData(
    this.title,
    this.asset,
    this.color,
    this.description,
    this.onTap,
  );
}

/*────────────────── OPTIMIZED FALLING STAR PAINTER ──────────────────*/
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
