import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderStatusTile extends StatelessWidget {
  final String step;
  final bool completed;

  const OrderStatusTile({
    super.key,
    required this.step,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Status circle
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: completed ? Colors.amberAccent : Colors.white12,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            step,
            style: GoogleFonts.poppins(
              color: completed ? Colors.amberAccent : Colors.white70,
              fontWeight: completed ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
