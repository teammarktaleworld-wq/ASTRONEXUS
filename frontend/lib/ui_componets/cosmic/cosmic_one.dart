import "dart:math";

import "package:flutter/material.dart";

class SmoothShootingStars extends StatefulWidget {
  final Color color;
  final int maxStars;
  final double spawnChance;

  const SmoothShootingStars({
    super.key,
    this.color = Colors.white,
    this.maxStars = 4,
    this.spawnChance = 0.985,
  });

  @override
  State<SmoothShootingStars> createState() => _SmoothShootingStarsState();
}

class _SmoothShootingStarsState extends State<SmoothShootingStars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<ShootingStar> _stars = <ShootingStar>[];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 24))
          ..addListener(() {
            _spawnStars();
            if (mounted) {
              setState(() {});
            }
          })
          ..repeat();
  }

  void _spawnStars() {
    if (_random.nextDouble() > widget.spawnChance &&
        _stars.length < widget.maxStars) {
      _stars.add(ShootingStar.create(_random));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: SmoothShootingStarPainter(_stars, widget.color),
      ),
    );
  }
}

class ShootingStar {
  late Offset start;
  late Offset end;
  late double progress;
  late double speed;
  late double opacity;
  late double length;

  ShootingStar._();

  factory ShootingStar.create(Random random) {
    final star = ShootingStar._();
    final startX = random.nextDouble() * 1.1 - 0.1;
    final startY = random.nextDouble() * 0.35;

    star.start = Offset(startX, startY);
    star.end = Offset(
      startX + 0.35 + random.nextDouble() * 0.3,
      startY + 0.65 + random.nextDouble() * 0.3,
    );
    star.progress = 0;
    star.speed = random.nextDouble() * 0.0016 + 0.0012;
    star.length = random.nextDouble() * 26 + 24;
    star.opacity = 0;
    return star;
  }
}

class SmoothShootingStarPainter extends CustomPainter {
  final List<ShootingStar> stars;
  final Color color;

  SmoothShootingStarPainter(this.stars, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    stars.removeWhere((star) => star.progress >= 1);

    for (final star in stars) {
      star.progress += star.speed;
      final t = star.progress.clamp(0.0, 1.0);

      if (t < 0.2) {
        star.opacity = t * 5;
      } else if (t > 0.8) {
        star.opacity = (1 - t) * 5;
      } else {
        star.opacity = 1;
      }

      final position = Offset.lerp(
        Offset(star.start.dx * size.width, star.start.dy * size.height),
        Offset(star.end.dx * size.width, star.end.dy * size.height),
        Curves.easeOutCubic.transform(t),
      )!;
      final tail = Offset(
        position.dx - star.length,
        position.dy - star.length * 0.7,
      );

      final paint = Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: <Color>[
            color.withOpacity(star.opacity),
            color.withOpacity(0),
          ],
        ).createShader(Rect.fromPoints(position, tail));

      canvas.drawLine(position, tail, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
