import 'package:flutter/material.dart';

class StepImage extends StatelessWidget {
  final String path;

  const StepImage({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Center(child: Image.asset(path, height: 140)),
    );
  }
}
