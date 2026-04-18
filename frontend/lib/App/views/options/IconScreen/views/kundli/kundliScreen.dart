import 'package:flutter/material.dart';
import 'package:astro_tale/core/localization/app_localizations.dart';
import 'package:astro_tale/core/theme/app_gradients.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astro_tale/App/views/Home/others/view/birthchart.dart'; // Example import

class KundliScreen extends StatefulWidget {
  const KundliScreen({super.key});

  @override
  State<KundliScreen> createState() => _KundliScreenState();
}

class _KundliScreenState extends State<KundliScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController birthTimeController = TextEditingController();
  final TextEditingController birthPlaceController = TextEditingController();
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive container
    final double screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          if (isDark)
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg.png"),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(decoration: AppGradients.screenDecoration(theme)),
          Container(
            color: isDark
                ? Colors.black.withOpacity(0.18)
                : AppGradients.screenOverlay(theme),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back Button + Title Row
                  Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: isDark ? Colors.white : colors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title centered
                      Expanded(
                        child: Text(
                          context.l10n.tr("birthChart"),
                          textAlign: TextAlign
                              .center, // Center the text within the Expanded
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            color: isDark ? Colors.white : colors.onSurface,
                          ),
                        ),
                      ),

                      // Empty space to balance back button
                      SizedBox(
                        width: 40,
                      ), // same width as back button + padding
                    ],
                  ),

                  const SizedBox(height: 30),
                  Text(
                    "Enter your birth details to generate your personalized Kundli chart.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: isDark
                          ? Colors.white70
                          : colors.onSurface.withOpacity(0.72),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Adaptive Form Container
                  Center(
                    child: Container(
                      width: screenWidth > 500
                          ? 500
                          : screenWidth * 0.95, // Responsive width
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppGradients.glassFill(theme),
                        border: Border.all(
                          color: AppGradients.glassBorder(theme),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildInputField(
                            nameController,
                            "Full Name",
                            Icons.person_outline,
                          ),
                          _buildInputField(
                            birthDateController,
                            "Date of Birth",
                            Icons.calendar_today_outlined,
                          ),
                          _buildInputField(
                            birthTimeController,
                            "Time of Birth",
                            Icons.access_time_outlined,
                          ),
                          _buildInputField(
                            birthPlaceController,
                            "Place of Birth",
                            Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _genderChip("Male", Icons.male),
                              const SizedBox(width: 10),
                              _genderChip("Female", Icons.female),
                            ],
                          ),
                          const SizedBox(height: 35),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 60,
                                vertical: 14,
                              ),
                            ),
                            onPressed: () {
                              if (nameController.text.isNotEmpty &&
                                  birthDateController.text.isNotEmpty &&
                                  birthTimeController.text.isNotEmpty &&
                                  birthPlaceController.text.isNotEmpty &&
                                  selectedGender != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const BirthChartScreen(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please fill all details"),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              "Generate Kundli",
                              style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w600,
                                color: colors.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        style: GoogleFonts.dmSans(color: colors.onSurface),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: colors.primary),
          labelText: label,
          labelStyle: GoogleFonts.dmSans(
            color: isDark
                ? Colors.white70
                : colors.onSurface.withOpacity(0.72),
          ),
          filled: true,
          fillColor: isDark
              ? Colors.black.withOpacity(0.25)
              : Colors.white.withOpacity(0.86),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _genderChip(String gender, IconData icon) {
    final bool isSelected = selectedGender == gender;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => setState(() => selectedGender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary
              : (isDark
                    ? Colors.black.withOpacity(0.35)
                    : colors.surfaceContainerHighest),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? colors.onPrimary
                  : (isDark ? Colors.white : colors.onSurface),
            ),
            const SizedBox(width: 6),
            Text(
              gender,
              style: GoogleFonts.dmSans(
                color: isSelected
                    ? colors.onPrimary
                    : (isDark ? Colors.white : colors.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
