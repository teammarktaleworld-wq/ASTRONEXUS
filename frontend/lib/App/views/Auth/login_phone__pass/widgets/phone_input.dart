import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Login_email/helper/signin_helpers.dart';

class PhoneInput extends StatelessWidget {
  final TextEditingController controller;

  const PhoneInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black87),
      decoration: authInput(context, "Phone Number", Icons.phone),
    );
  }
}
