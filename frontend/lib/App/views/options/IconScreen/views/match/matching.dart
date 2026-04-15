import 'dart:convert';
import 'dart:ui';

import 'package:astro_tale/core/theme/app_gradients.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:astro_tale/App/views/options/IconScreen/views/match/result/matchingScore.dart';
import '../../../../../../services/API/APIservice.dart';
import '../../../../../../ui_componets/cosmic/cosmic_one.dart';
import '../../../../../../ui_componets/glass/glass_card.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen>
    with TickerProviderStateMixin {
  // ───────── Controllers ─────────
  final mName = TextEditingController();
  final mDob = TextEditingController();
  final mTime = TextEditingController();
  final mPlace = TextEditingController();

  final fName = TextEditingController();
  final fDob = TextEditingController();
  final fTime = TextEditingController();
  final fPlace = TextEditingController();

  final mYear = TextEditingController();
  final mMonth = TextEditingController();
  final mDate = TextEditingController();
  final mHour = TextEditingController();
  final mMinute = TextEditingController();
  final mSecond = TextEditingController();
  final mLat = TextEditingController();
  final mLng = TextEditingController();
  final mTz = TextEditingController();

  final fYear = TextEditingController();
  final fMonth = TextEditingController();
  final fDate = TextEditingController();
  final fHour = TextEditingController();
  final fMinute = TextEditingController();
  final fSecond = TextEditingController();
  final fLat = TextEditingController();
  final fLng = TextEditingController();
  final fTz = TextEditingController();

  bool isLoading = false;
  bool showMale = true; // true = Male form, false = Female form

  final _formKey = GlobalKey<FormState>();
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ───────── Date & Time Pickers ─────────
  Future<void> _pickDate(
    TextEditingController display,
    TextEditingController year,
    TextEditingController month,
    TextEditingController date,
  ) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Theme.of(context).colorScheme.primary,
            onPrimary: Theme.of(context).colorScheme.onPrimary,
            surface: Theme.of(context).colorScheme.surface,
            onSurface: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      display.text =
          "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      year.text = picked.year.toString();
      month.text = picked.month.toString();
      date.text = picked.day.toString();
      setState(() {});
    }
  }

  Future<void> _pickTime(
    TextEditingController display,
    TextEditingController hour,
    TextEditingController minute,
    TextEditingController second,
  ) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Theme.of(context).colorScheme.primary,
            onPrimary: Theme.of(context).colorScheme.onPrimary,
            surface: Theme.of(context).colorScheme.surface,
            onSurface: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      display.text =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      hour.text = picked.hour.toString();
      minute.text = picked.minute.toString();
      second.text = "0";
      setState(() {});
    }
  }

  // ───────── API Logic ─────────
  Future<void> _checkCompatibility() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await _resolvePlace(mPlace.text, mLat, mLng, mTz, 19.0760, 72.8777);
      await _resolvePlace(fPlace.text, fLat, fLng, fTz, 28.6139, 77.2090);

      final body = {
        "male": _buildPerson(
          mName,
          mYear,
          mMonth,
          mDate,
          mHour,
          mMinute,
          mSecond,
          mLat,
          mLng,
          mTz,
        ),
        "female": _buildPerson(
          fName,
          fYear,
          fMonth,
          fDate,
          fHour,
          fMinute,
          fSecond,
          fLat,
          fLng,
          fTz,
        ),
        "config": {
          "observation_point": "topocentric",
          "language": "en",
          "ayanamsha": "lahiri",
        },
      };

      final res = await http.post(
        Uri.parse("$baseurl/api/v1/compatibility/match-making/ashtakoot-score"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (!mounted) return;

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data["success"] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MatchingScoreScreen(output: data["data"]["output"]),
          ),
        );
      } else {
        _showError(data["message"] ?? "Compatibility failed");
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Map<String, dynamic> _buildPerson(
    TextEditingController name,
    TextEditingController year,
    TextEditingController month,
    TextEditingController date,
    TextEditingController hour,
    TextEditingController minute,
    TextEditingController second,
    TextEditingController lat,
    TextEditingController lng,
    TextEditingController tz,
  ) => {
    "name": name.text,
    "year": int.parse(year.text),
    "month": int.parse(month.text),
    "date": int.parse(date.text),
    "hours": int.parse(hour.text),
    "minutes": int.parse(minute.text),
    "seconds": int.parse(second.text),
    "latitude": double.parse(lat.text),
    "longitude": double.parse(lng.text),
    "timezone": double.parse(tz.text),
  };

  Future<void> _resolvePlace(
    String place,
    TextEditingController lat,
    TextEditingController lng,
    TextEditingController tz,
    double fallbackLat,
    double fallbackLng,
  ) async {
    try {
      final locations = await locationFromAddress(place);
      if (locations.isNotEmpty) {
        lat.text = locations.first.latitude.toString();
        lng.text = locations.first.longitude.toString();
        tz.text = "5.5";
      } else {
        lat.text = fallbackLat.toString();
        lng.text = fallbackLng.toString();
        tz.text = "5.5";
      }
    } catch (_) {
      lat.text = fallbackLat.toString();
      lng.text = fallbackLng.toString();
      tz.text = "5.5";
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.blueGrey.shade900, content: Text(msg)),
    );
  }

  // ───────── Glass Input Field ─────────
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
            color: Colors.black.withOpacity(0.003),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        validator: (v) => v!.isEmpty ? "Required" : null,
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

          if (isDark)
            Positioned.fill(
              child: IgnorePointer(ignoring: true, child: SmoothShootingStars()),
            ),

          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(color: AppGradients.screenOverlay(theme)),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _matchTopBar(context),
                    const SizedBox(height: 20),
                    Text(
                      "Evaluate cosmic harmony & compatibility",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        color: isDark
                            ? Colors.white70
                            : colors.onSurface.withOpacity(0.72),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 22),

                    _genderToggle(),
                    const SizedBox(height: 18),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: showMale ? _maleForm() : _femaleForm(),
                    ),
                    const SizedBox(height: 24),
                    // ✅ Check Compatibility Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _checkCompatibility,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: AppGradients.glassBorder(theme),
                            width: 1.6,
                          ),
                        ),
                        child: isLoading
                            ? LoadingAnimationWidget.fourRotatingDots(
                                color: colors.onPrimary,
                                size: 28,
                              )
                            : Text(
                                "Check Compatibility",
                                style: GoogleFonts.dmSans(
                                  color: colors.onPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _maleForm() {
    return glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Male Details",
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _glassInputField(
            label: "Full Name",
            icon: Icons.person_outline,
            controller: mName,
          ),
          const SizedBox(height: 12),
          _glassInputField(
            label: "Date of Birth",
            icon: Icons.calendar_today_outlined,
            controller: mDob,
            readOnly: true,
            onTap: () => _pickDate(mDob, mYear, mMonth, mDate),
          ),
          const SizedBox(height: 12),
          _glassInputField(
            label: "Time of Birth",
            icon: Icons.access_time_outlined,
            controller: mTime,
            readOnly: true,
            onTap: () => _pickTime(mTime, mHour, mMinute, mSecond),
          ),
          const SizedBox(height: 12),
          _glassInputField(
            label: "Place of Birth",
            icon: Icons.location_on,
            controller: mPlace,
          ),
        ],
      ),
    );
  }

  Widget _femaleForm() {
    return glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Female Details",
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _glassInputField(
            label: "Full Name",
            icon: Icons.person_outline,
            controller: fName,
          ),
          const SizedBox(height: 12),
          _glassInputField(
            label: "Date of Birth",
            icon: Icons.calendar_today_outlined,
            controller: fDob,
            readOnly: true,
            onTap: () => _pickDate(fDob, fYear, fMonth, fDate),
          ),
          const SizedBox(height: 12),
          _glassInputField(
            label: "Time of Birth",
            icon: Icons.access_time_outlined,
            controller: fTime,
            readOnly: true,
            onTap: () => _pickTime(fTime, fHour, fMinute, fSecond),
          ),
          const SizedBox(height: 12),
          _glassInputField(
            label: "Place of Birth",
            icon: Icons.location_on,
            controller: fPlace,
          ),
        ],
      ),
    );
  }

  Widget _genderToggle() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppGradients.glassFill(theme),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppGradients.glassBorder(theme)),
      ),
      child: Row(
        children: [_toggleButton("Male", true), _toggleButton("Female", false)],
      ),
    );
  }

  Widget _toggleButton(String label, bool value) {
    final isSelected = showMale == value;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => showMale = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? colors.onPrimary
                  : colors.onSurface.withOpacity(0.72),
            ),
          ),
        ),
      ),
    );
  }
}

PreferredSizeWidget _matchTopBar(BuildContext context) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  return PreferredSize(
    preferredSize: const Size.fromHeight(100),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppGradients.glassFill(theme),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppGradients.glassBorder(theme)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  "Matching",
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
