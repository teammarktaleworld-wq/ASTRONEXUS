import 'package:flutter/material.dart';
import 'package:astro_tale/ui_componets/glass/glass_card.dart';

class SignupCard extends StatelessWidget {
  final Widget child;

  const SignupCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: glassCard(
        padding: const EdgeInsets.all(22),
        radius: 26,
        child: child,
      ),
    );
  }
}
