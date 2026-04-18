import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../sharedWidgets/step_image.dart';
import '../model/SignUp_Data_Model.dart';

class StepBirthTime extends StatelessWidget {
  final AstrologySignupModel model;
  final VoidCallback onChanged;

  const StepBirthTime({
    super.key,
    required this.model,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        const StepImage(path: "assets/images/time.png"),

        Text(
          "Exact birth time determines the Ascendant and house divisions.",
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            color: isDark ? Colors.white : colors.onSurface,
          ),
        ),

        const SizedBox(height: 30),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0A1633) : const Color(0xFFF2F5FF),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              // Selected time display
              Text(
                "${model.hour.toString().padLeft(2, '0')} : "
                "${model.minute.toString().padLeft(2, '0')} "
                "${model.isAM ? 'AM' : 'PM'}",
                style: GoogleFonts.dmSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : colors.onSurface,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 160,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      pickerTextStyle: TextStyle(
                        color: isDark ? Colors.white : colors.onSurface,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Hour picker
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 40,
                          onSelectedItemChanged: (i) {
                            model.hour = i + 1;
                            onChanged();
                          },
                          children: List.generate(
                            12,
                            (i) => Center(
                              child: Text((i + 1).toString().padLeft(2, '0')),
                            ),
                          ),
                        ),
                      ),

                      // Minute picker
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 40,
                          onSelectedItemChanged: (i) {
                            model.minute = i;
                            onChanged();
                          },
                          children: List.generate(
                            60,
                            (i) => Center(
                              child: Text(i.toString().padLeft(2, '0')),
                            ),
                          ),
                        ),
                      ),

                      // AM / PM picker
                      Expanded(
                        child: CupertinoPicker(
                          itemExtent: 40,
                          onSelectedItemChanged: (i) {
                            model.isAM = i == 0;
                            onChanged();
                          },
                          children: const [
                            Center(child: Text("AM")),
                            Center(child: Text("PM")),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
