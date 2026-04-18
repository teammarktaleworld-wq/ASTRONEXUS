import 'package:astro_tale/core/theme/app_gradients.dart';
import 'package:flutter/material.dart';

import '../../../../ui_componets/cosmic/cosmic_one.dart';

class CosmicBackground extends StatelessWidget {
  final AnimationController controller;
  final Object? painter;

  const CosmicBackground({
    super.key,
    required this.controller,
    required this.painter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          decoration: AppGradients.screenDecoration(theme),
        ),
        if (isDark) Positioned.fill(child: SmoothShootingStars()),
        Positioned.fill(child: Container(color: AppGradients.screenOverlay(theme))),
        // AnimatedBuilder(
        //   animation: controller,
        //   builder: (_, __) {
        //     if (painter == null) return const SizedBox.shrink();
        //     return CustomPaint(
        //       size: size,
        //       painter: FallingStarPainter(
        //         controller.value,
        //         stars: painter!.stars,
        //         sizes: painter!.sizes,
        //         speeds: painter!.speeds,
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }
}
