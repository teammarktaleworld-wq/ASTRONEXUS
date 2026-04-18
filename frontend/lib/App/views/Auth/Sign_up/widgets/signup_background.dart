import 'package:astro_tale/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../../core/widgets/animated_app_background.dart';

class SignupBackground extends StatelessWidget {
  final Widget child;

  const SignupBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedAppBackground(
      showStarsInDark: true,
      showStarsInLight: true,
      showGlow: true,
      child: Container(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black.withOpacity(0.35)
            : AppColors.lightbox,
        child: child,
      ),
    );
  }
}
