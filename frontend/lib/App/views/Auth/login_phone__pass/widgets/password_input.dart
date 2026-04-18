import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Login_email/helper/signin_helpers.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  const PasswordInput({super.key, required this.controller});

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: widget.controller,
      obscureText: obscure,
      style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black87),
      decoration: authInput(context, "Password", Icons.lock).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility : Icons.visibility_off,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          onPressed: () => setState(() => obscure = !obscure),
        ),
      ),
    );
  }
}
