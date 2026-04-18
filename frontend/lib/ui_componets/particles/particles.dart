import 'dart:math';
import 'package:flutter/material.dart';

class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class Particle {
  Offset position;
  Offset target;
  double size;
  Color color;
  double speed;

  Particle({
    required this.position,
    required this.target,
    required this.size,
    required this.color,
    required this.speed,
  });
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random random = Random();
  final int numberOfParticles = 100;
  late List<Particle> particles;

  final List<Color> particleColors = [
    Colors.cyanAccent,
    Colors.pinkAccent,
    Colors.limeAccent,
    Colors.orangeAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
  ];

  @override
  void initState() {
    super.initState();
    particles = List.generate(numberOfParticles, (_) => _createParticle());

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 100))
          ..addListener(() {
            _updateParticles();
            setState(() {});
          })
          ..repeat();
  }

  Particle _createParticle() {
    final pos = Offset(random.nextDouble(), random.nextDouble());
    final target = Offset(random.nextDouble(), random.nextDouble());
    final size = random.nextDouble() * 2 + 1;
    final color = particleColors[random.nextInt(particleColors.length)];
    final speed = random.nextDouble() * 0.002 + 0.001;
    return Particle(
      position: pos,
      target: target,
      size: size,
      color: color,
      speed: speed,
    );
  }

  void _updateParticles() {
    for (var p in particles) {
      // Move particle toward target
      final dx = p.target.dx - p.position.dx;
      final dy = p.target.dy - p.position.dy;

      p.position = Offset(
        p.position.dx + dx * p.speed,
        p.position.dy + dy * p.speed,
      );

      // If particle is close to target, pick a new random target
      if ((dx * dx + dy * dy) < 0.0005) {
        p.target = Offset(random.nextDouble(), random.nextDouble());
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: CustomPaint(
        painter: ParticlePainter(particles),
        child: Container(),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      paint.color = p.color.withOpacity(0.8);
      canvas.drawCircle(
        Offset(p.position.dx * size.width, p.position.dy * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
