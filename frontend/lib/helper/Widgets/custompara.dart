import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:astro_tale/core/responsive/responsive.dart';

class Custompara extends StatelessWidget {
  const Custompara({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: context.sp(14),
        color: const Color(0xffFFFFFF),
      ),
    );
  }
}
