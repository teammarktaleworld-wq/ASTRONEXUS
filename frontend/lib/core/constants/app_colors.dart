import "package:flutter/material.dart";

class AppColors {
  const AppColors._();

  // Light theme palette
// Light theme palette
  static const Color lightBackground = Color(0xFFBDE8F5);      // lavender sky
  static const Color lightBackgroundSoft = Color(0xFFEAEFEF);  // mist pastel layer
  static const Color lightSurface = Color(0xFFFFFFFF);         // clean glass white

// Card / elevated surfaces (inspired by soft purple rocks in image)
  static const Color lightContainer = Color(0xFF3E3F5B);       // deep muted violet
  static  Color lightContainerAlt = Color(0xFF18122F).withOpacity(0.3);    // softer royal lavender

// Text colors
  static const Color lightTextPrimary = Color(0xFF2C2744);     // rich twilight ink
  static const Color lightTextMuted = Color(0xFF6E6891);       // faded constellation tone

// Soft translucent glass overlay
  static const Color lightbox = Color(0x33FFFFFF);             // soft glow glass
  // Dark theme palette
  static const Color background = Color(0xFF1F2340);
  static const Color backgroundSoft = Color(0xFF18122B);
  static const Color surface = Color(0x26333C63);
  static const Color surfaceAlt = Color(0x26333C63);
  static const Color textPrimary = Color(0xFFEAEAFB);
  static const Color textSecondary = Color(0xFF9DA3D6);

  // Shared semantic colors
  static const Color appBarDark = Color(0xFF18122B);
  static const Color onDark = Colors.white;
  static const Color cardBorderLight = Color(0x26333C63);
  static const Color starOnDark = Color(0xB3FFFFFF);
  static const Color starOnLight = Color(0x7A1F2340);
  static const Color shimmerBase = Color(0xFFFFFFFF);
  static const Color shimmerHighlight = Color(0x33FFFFFF);

  // Accent colors
  static const Color accent = Color(0xFFFFD166);
  static const Color accentStrong = Color(0xFF8B5CF6);
  static const Color success = Color(0xFF4ADE80);
  static const Color error = Color(0xFFFF6B6B);

  static const Color lightPrimary = Color(0xFF9CC6DB);
  static const Color darkPrimary = Color(0xFF393053);
  static const Color secondary = Color(0xFF5EEAD4);
}
