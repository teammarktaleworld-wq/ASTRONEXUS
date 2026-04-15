import 'package:flutter/material.dart';
import '../../../../../ui_componets/cosmic/cosmic_one.dart';

class ReportsBackground extends StatelessWidget {
  const ReportsBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff050B1E),
                // Color(0xff1C4D8D),
                // Color(0xff0F2854),
                Color(0xff393053),

                Color(0xff050B1E),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned.fill(child: SmoothShootingStars()),
      ],
    );
  }
}
