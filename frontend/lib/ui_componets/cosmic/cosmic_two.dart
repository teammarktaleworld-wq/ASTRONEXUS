import 'dart:math';
import 'package:flutter/material.dart';

class StaticUniverseParticles extends StatelessWidget {
  const StaticUniverseParticles({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🌌 Cosmic Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff050B1E),
                  Color(0xff1C2A5A),
                  Color(0xff0F2854),
                  Color(0xff050B1E),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// ⭐ Static Stars / Particles
          Positioned.fill(child: CustomPaint(painter: ParticlesPainter())),
        ],
      ),
    );
  }
}

/// ================== PARTICLES PAINTER ==================
class ParticlesPainter extends CustomPainter {
  ParticlesPainter() {
    _generateParticles();
  }

  final List<Offset> _particles = [];
  final int _particleCount = 250; // number of particles
  final Random _random = Random();

  void _generateParticles() {
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(Offset(_random.nextDouble(), _random.nextDouble()));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);

    for (final particle in _particles) {
      final dx = particle.dx * size.width;
      final dy = particle.dy * size.height;
      final radius = _random.nextDouble() * 1.5 + 0.3; // particle size
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
