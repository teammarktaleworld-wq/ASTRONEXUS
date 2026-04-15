import 'package:astro_tale/App/views/Auth/login_phone__pass/screen/login_phone_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show ElevatedButton, Colors, Icons, MaterialPageRoute;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Auth/Login_phone/screens/phone_login_screen.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      icon: const Icon(Icons.power_settings_new, color: Colors.white),
      label: Text(
        "Logout",
        style: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      onPressed: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPhoneScreen()),
        );
      },
    );
  }
}
