import 'dart:math';
import 'package:flutter/material.dart';

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  static FallingStarPainter generate(int count, Size size, double progress) {
    final rand = Random();
    final stars = List.generate(
      count,
      (_) => Offset(
        rand.nextDouble() * size.width,
        rand.nextDouble() * size.height,
      ),
    );
    final sizes = List.generate(count, (_) => rand.nextDouble() * 1.2 + 0.4);
    final speeds = List.generate(count, (_) => 50 + rand.nextDouble() * 250);
    return FallingStarPainter(
      progress,
      stars: stars,
      sizes: sizes,
      speeds: speeds,
    );
  }
}
