import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StaticUniversePainter extends CustomPainter {
  final Random r = Random();

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 150; i++) {
      canvas.drawCircle(
        Offset(r.nextDouble() * size.width, r.nextDouble() * size.height),
        r.nextDouble() * 1.2 + 0.5,
        Paint()..color = Colors.white.withOpacity(0.3),
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
