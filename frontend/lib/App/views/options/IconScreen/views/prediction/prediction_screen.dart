import "package:astro_tale/App/Model/Horoscope/horoscope_model.dart";
import "package:astro_tale/core/theme/app_gradients.dart";
import "package:astro_tale/core/widgets/themed_shimmer.dart";
import "package:astro_tale/helper/Astrology_flow_helper.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:intl/intl.dart";

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController placeController = TextEditingController();

  String gender = "male";
  TimeOfDay? selectedTime;
  bool isLoading = false;
  String zodiacSign = "";
  String? errorText;
  Map<String, HoroscopeData>? predictions;

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    timeController.dispose();
    placeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      dobController.text = DateFormat("dd-MM-yyyy").format(pickedDate);
    }
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      selectedTime = pickedTime;
      timeController.text = pickedTime.format(context);
    }
  }

  Future<void> _getPrediction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
      errorText = null;
      predictions = null;
    });

    try {
      final dob = DateFormat("dd-MM-yyyy").parseStrict(dobController.text);
      final time = selectedTime ?? _parseTimeOfDay(timeController.text);

      final hour24 = time.hour;
      final minute = time.minute;
      final isAM = hour24 < 12;
      final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;

      final data = await AstrologyFlowHelper.prepareDashboardData(
        dob: dob,
        name: nameController.text.trim(),
        gender: gender,
        placeOfBirth: placeController.text.trim(),
        hour: hour12,
        minute: minute,
        isAM: isAM,
      );

      setState(() {
        zodiacSign = (data["zodiac"] ?? "").toString();
        predictions = <String, HoroscopeData>{
          "Today": HoroscopeData.fromJson(
            data["daily"] as Map<String, dynamic>? ?? <String, dynamic>{},
          ),
          "This Week": HoroscopeData.fromJson(
            data["weekly"] as Map<String, dynamic>? ?? <String, dynamic>{},
          ),
          "This Month": HoroscopeData.fromJson(
            data["monthly"] as Map<String, dynamic>? ?? <String, dynamic>{},
          ),
        };
      });
    } catch (e) {
      setState(() {
        errorText = "Could not load prediction. ${e.toString()}";
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  TimeOfDay _parseTimeOfDay(String raw) {
    try {
      final parsed = DateFormat.jm().parseStrict(raw);
      return TimeOfDay(hour: parsed.hour, minute: parsed.minute);
    } catch (_) {
      final now = TimeOfDay.now();
      return now;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppGradients.glassFill(theme),
        centerTitle: true,
        title: const Text("Astro Prediction"),
      ),
      body: Stack(
        children: <Widget>[
          Container(decoration: AppGradients.screenDecoration(theme)),
          Positioned.fill(
            child: Container(color: AppGradients.screenOverlay(theme)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: <Widget>[
                  _formCard(colors),
                  const SizedBox(height: 18),
                  if (isLoading) ...<Widget>[
                    const ThemedShimmerCard(height: 170),
                    const SizedBox(height: 12),
                    const ThemedShimmerCard(height: 170),
                    const SizedBox(height: 12),
                    const ThemedShimmerCard(height: 170),
                  ] else if (errorText != null) ...<Widget>[
                    _errorCard(errorText!),
                  ] else if (predictions != null) ...<Widget>[
                    _predictionCard("Today", predictions!["Today"]!, colors),
                    const SizedBox(height: 12),
                    _predictionCard(
                      "This Week",
                      predictions!["This Week"]!,
                      colors,
                    ),
                    const SizedBox(height: 12),
                    _predictionCard(
                      "This Month",
                      predictions!["This Month"]!,
                      colors,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formCard(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppGradients.glassFill(Theme.of(context)),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppGradients.glassBorder(Theme.of(context))),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            if (zodiacSign.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  "Zodiac: ${zodiacSign.toUpperCase()}",
                  style: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (zodiacSign.isNotEmpty) const SizedBox(height: 14),
            _buildInputField(
              label: "Full Name",
              controller: nameController,
              icon: Icons.person_outline,
            ),
            _buildInputField(
              label: "Date of Birth",
              controller: dobController,
              icon: Icons.calendar_today_outlined,
              onTap: _selectDate,
            ),
            _buildInputField(
              label: "Time of Birth",
              controller: timeController,
              icon: Icons.access_time_outlined,
              onTap: _selectTime,
            ),
            _buildInputField(
              label: "Place of Birth",
              controller: placeController,
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(child: _genderChip("male", "Male", Icons.male)),
                const SizedBox(width: 10),
                Expanded(child: _genderChip("female", "Female", Icons.female)),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _getPrediction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isLoading ? "Loading..." : "Show Prediction",
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: onTap != null,
        onTap: onTap,
        validator: (value) => value == null || value.trim().isEmpty
            ? "Please enter $label"
            : null,
        style: GoogleFonts.dmSans(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          labelText: label,
          labelStyle: GoogleFonts.dmSans(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.22)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.22)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.44)),
          ),
        ),
      ),
    );
  }

  Widget _genderChip(String value, String label, IconData icon) {
    final selected = gender == value;
    return InkWell(
      onTap: () => setState(() => gender = value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 18, color: selected ? Colors.black : Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _predictionCard(String type, HoroscopeData data, ColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppGradients.glassFill(Theme.of(context)),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppGradients.glassBorder(Theme.of(context))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            type,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.title.isEmpty ? "-" : data.title,
            style: GoogleFonts.dmSans(
              color: colors.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.text.isEmpty ? "Not available" : data.text,
            style: GoogleFonts.dmSans(
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withOpacity(0.38)),
      ),
      child: Text(text, style: GoogleFonts.dmSans(color: Colors.white)),
    );
  }
}
