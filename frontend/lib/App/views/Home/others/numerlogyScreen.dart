import 'package:flutter/material.dart';
import 'package:astro_tale/core/theme/app_gradients.dart';
import 'package:google_fonts/google_fonts.dart';
import 'output/numerlogy_result.dart';
import '../../../../ui_componets/cosmic/cosmic_one.dart';
import '../../../../ui_componets/glass/glass_card.dart';

class NumerologyScreen extends StatefulWidget {
  const NumerologyScreen({super.key});

  @override
  State<NumerologyScreen> createState() => _NumerologyScreenState();
}

class _NumerologyScreenState extends State<NumerologyScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController infoController = TextEditingController();

  bool isLoading = false;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        return Theme(
          data: theme.copyWith(
            colorScheme: colors.copyWith(
              primary: colors.primary,
              onPrimary: colors.onPrimary,
              surface: colors.surface,
              onSurface: colors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      dateController.text =
          "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      setState(() {});
    }
  }

  void _generateNumerology() {
    if (nameController.text.isEmpty || dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill name & date 🌟"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NumerologyResult(
            name: nameController.text,
            dob: dateController.text,
            additionalInfo: infoController.text,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: AppGradients.screenDecoration(theme),
          ),
          if (isDark) Positioned.fill(child: SmoothShootingStars()),
          Positioned.fill(child: Container(color: AppGradients.screenOverlay(theme))),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Numerology Calculator",
                    style: GoogleFonts.dmSans(
                      color: isDark ? Colors.white : colors.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Glass Card with Box Shadow
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppGradients.glassBorder(theme),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.7)
                              : Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.05),
                          blurRadius: 30,
                          spreadRadius: 1,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: glassCard(
                      child: Column(
                        children: [
                          Text(
                            "Discover Your Numerology",
                            style: GoogleFonts.dmSans(
                              color: isDark ? Colors.white : colors.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Enter details to reveal your life path number",
                            style: GoogleFonts.dmSans(
                              color: isDark
                                  ? Colors.white70
                                  : colors.onSurface.withOpacity(0.72),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 25),

                          _glassInputField(
                            label: "Full Name",
                            icon: Icons.person_outline,
                            controller: nameController,
                          ),
                          const SizedBox(height: 16),

                          _glassInputField(
                            label: "Date of Birth",
                            icon: Icons.calendar_today_outlined,
                            controller: dateController,
                            readOnly: true,
                            onTap: _pickDate,
                          ),
                          const SizedBox(height: 16),

                          _glassInputField(
                            label: "Additional Info (optional)",
                            icon: Icons.info_outline,
                            controller: infoController,
                          ),
                          const SizedBox(height: 30),

                          // Button with shadow
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: Container(
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppGradients.glassBorder(theme),
                                  width: 1.6,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withOpacity(0.6)
                                        : Colors.black.withOpacity(0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.05),
                                    blurRadius: 20,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : _generateNumerology,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "Calculate Numerology",
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colors.onPrimary,
                                    ),
                                  ),
                                ),
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

  // 🔒 Glass Style Input Field
  Widget _glassInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppGradients.glassFill(theme),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppGradients.glassBorder(theme)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: GoogleFonts.dmSans(color: colors.onSurface, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: colors.primary),
          hintText: label,
          hintStyle: GoogleFonts.dmSans(
            color: colors.onSurface.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
