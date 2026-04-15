import 'package:astro_tale/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int step;
  final VoidCallback onBack;

  const SignupAppBar({super.key, required this.step, required this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(110);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.appBarDark : AppColors.lightContainer,
          ),
        ),
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,

          // Show back button only after step 0
          leading: step > 0
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.onDark),
                  onPressed: onBack,
                )
              : const SizedBox(),

          title: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                _title(step),
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onDark,
                ),
              ),
              Text(
                "Cosmic Step ${step + 1} / 7",
                style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _title(int step) {
    const titles = [
      "Enter Your Name",
      "Enter Your Email",
      "Enter Your Phone",
      "Set Password",
      "Enter Birth Date",
      "Select Time of Birth",
      "Enter Place of Birth",
    ];

    if (step < 0 || step >= titles.length) return "";
    return titles[step];
  }
}
