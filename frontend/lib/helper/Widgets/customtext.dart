import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:astro_tale/core/responsive/responsive.dart';

class Customtext extends StatelessWidget {
  const Customtext({super.key, required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: context.sp(20),
        color: color,
      ),
    );
  }
}
