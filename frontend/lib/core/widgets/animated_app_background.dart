import "dart:math";
import "dart:ui";
import "package:flutter/material.dart";
import "package:astro_tale/core/constants/app_colors.dart";
import "package:astro_tale/ui_componets/cosmic/cosmic_one.dart";

class AnimatedAppBackground extends StatefulWidget {
  final Widget child;
  final bool showStarsInDark;
  final bool showStarsInLight;
  final bool showGlow;

  const AnimatedAppBackground({
    super.key,
    required this.child,
    this.showStarsInDark = true,
    this.showStarsInLight = true,
    this.showGlow = true,
  });

  @override
  State<AnimatedAppBackground> createState() =>
      _AnimatedAppBackgroundState();
}

class _AnimatedAppBackgroundState extends State<AnimatedAppBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
  AnimationController(
    vsync: this,
    duration: const Duration(seconds: 100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Ultra smooth gradient base
  List<Color> _backgroundGradient(bool isDark) {
    if (isDark) {
      return const [
        Color(0xFF2C2744),
        Color(0xFF393053),

        Color(0xFF3D365C),
        Color(0xFF18122B),

      ];
    } else {
      return const [
        Color(0xFFBBE0EF),
        Color(0xFFF7F9FF),

        Color(0xFFF7F9FF),
        Color(0xFFECEFFF),
        Color(0xFF9CD5FF),
      ];
    }
  }

  Widget _softAura(double t, bool isDark, Size size) {
    final auraColor =
    isDark ? const Color(0xFF8F7BFF) : const Color(0xFFBFC8FF);

    final pulse = 0.05 + (0.02 * sin(t * pi * 2));

    return Positioned(
      left: size.width * 0.2,
      top: size.height * 0.1,
      child: Opacity(
        opacity: pulse,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 150, sigmaY: 150),
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: auraColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _zodiacOverlay(bool isDark) {
    return Positioned.fill(
      child: Opacity(
        opacity: isDark ? 0.05 : 0.08,
        child: CustomPaint(
          painter: _ZodiacPainter(
            color: isDark
                ? Colors.white
                : const Color(0xFF555879),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final starsEnabled =
    isDark ? widget.showStarsInDark : widget.showStarsInLight;

    return Stack(
      children: [

        /// 🌈 Rich multi-layer gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _backgroundGradient(isDark),
            ),
          ),
        ),

        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              final t = _controller.value;

              return Stack(
                children: [
                  _softAura(t, isDark, size),
                  _zodiacOverlay(isDark),
                ],
              );
            },
          ),
        ),

        if (starsEnabled)
          Positioned.fill(
            child: SmoothShootingStars(
              color: isDark
                  ? AppColors.starOnDark
                  : AppColors.starOnLight,
              maxStars: isDark ? 3 : 6,
              spawnChance: isDark ? 0.985 : 0.97,
            ),
          ),

        if (widget.showGlow)
          Positioned.fill(
            child: Container(
              color: isDark
                  ? Colors.white.withOpacity(0.02)
                  : Colors.white.withOpacity(0.05),
            ),
          ),

        widget.child,
      ],
    );
  }
}

/// Minimal zodiac constellation lines
class _ZodiacPainter extends CustomPainter {
  final Color color;

  _ZodiacPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = 1;

    final points = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.4, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.35),
      Offset(size.width * 0.75, size.height * 0.5),
    ];

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    for (final p in points) {
      canvas.drawCircle(p, 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}