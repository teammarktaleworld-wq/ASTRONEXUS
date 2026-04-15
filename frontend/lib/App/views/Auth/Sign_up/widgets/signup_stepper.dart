import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupStepper extends StatelessWidget {
  final int step;
  final ValueChanged<int> onStepChanged;
  final int totalSteps;

  const SignupStepper({
    super.key,
    required this.step,
    required this.onStepChanged,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: EasyStepper(
        activeStep: step,
        enableStepTapping: true,
        activeStepBackgroundColor: colors.primary,
        finishedStepBackgroundColor: colors.primary.withOpacity(0.76),
        finishedStepIconColor: Colors.white,
        activeStepIconColor: Colors.white,
        unreachedStepIconColor: isDark
            ? Colors.grey[400]
            : colors.onSurface.withOpacity(0.5),
        unreachedStepBackgroundColor: isDark
            ? Colors.grey[700]
            : colors.surfaceContainerHighest.withOpacity(0.8),
        lineStyle: LineStyle(
          activeLineColor: colors.primary,
          finishedLineColor: colors.primary.withOpacity(0.76),
          unreachedLineColor: isDark
              ? Colors.grey[500]!
              : colors.outline.withOpacity(0.5),
          lineThickness: 3,
          lineLength: 50,
        ),
        stepBorderRadius: 12, // rounder steps
        stepRadius: 28,
        onStepReached: onStepChanged,
        titleTextStyle: GoogleFonts.dmSans(
          color: isDark ? Colors.white70 : colors.onSurface.withOpacity(0.75),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        steps: const [
          EasyStep(
            icon: Icon(Icons.person, color: Colors.white),
            title: "Name",
          ),
          EasyStep(
            icon: Icon(Icons.email, color: Colors.white),
            title: "Email",
          ),
          EasyStep(
            icon: Icon(Icons.phone, color: Colors.white),
            title: "Phone",
          ),
          EasyStep(
            icon: Icon(Icons.lock, color: Colors.white),
            title: "Password",
          ),
          EasyStep(
            icon: Icon(Icons.calendar_today, color: Colors.white),
            title: "Birth Date",
          ),
          EasyStep(
            icon: Icon(Icons.access_time, color: Colors.white),
            title: "Time",
          ),
          EasyStep(
            icon: Icon(Icons.location_on, color: Colors.white),
            title: "Place",
          ),
        ],
      ),
    );
  }
}
