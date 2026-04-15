import 'dart:convert';
import 'package:astro_tale/App/views/Auth/sharedWidgets/place_suggestion_sheet.dart';
import 'package:astro_tale/App/views/Home/others/output/birthchart/birthchart_result.dart';
import 'package:astro_tale/core/constants/api_constants.dart';
import 'package:astro_tale/core/constants/app_colors.dart';
import 'package:astro_tale/core/localization/app_localizations.dart';
import 'package:astro_tale/core/theme/app_gradients.dart';
import 'package:astro_tale/core/widgets/animated_app_background.dart';
import 'package:astro_tale/helper/chart_cache_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BirthChartScreen extends StatefulWidget {
  const BirthChartScreen({super.key});

  @override
  State<BirthChartScreen> createState() => _BirthChartScreenState();
}

class _BirthChartScreenState extends State<BirthChartScreen> {
  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final placeController = TextEditingController();

  String gender = 'male';
  String astrologyType = 'vedic';
  String ayanamsa = 'lahiri';
  bool isLoading = false;

  /// ================= DATE PICKER =================
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: "SELECT BIRTH DATE",
      cancelText: "CANCEL",
      confirmText: "OK",
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
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.lightContainer,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      dateController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  /// ================= TIME PICKER =================
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: "SELECT BIRTH TIME",
      cancelText: "CANCEL",
      confirmText: "OK",
      builder: (context, child) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        return Theme(
          data: theme.copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.lightContainer,
              hourMinuteTextColor: colors.onSurface,
              hourMinuteColor: colors.surfaceContainerHighest,
              dialHandColor: colors.primary,
              dialBackgroundColor: colors.surfaceContainerHighest,
              entryModeIconColor: colors.primary,
            ),
            colorScheme: colors.copyWith(
              primary: colors.primary,
              onPrimary: colors.onPrimary,
              surface: colors.surface,
              onSurface: colors.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colors.primary,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? "AM" : "PM";

      timeController.text = "$hour:$minute $period";
    }
  }

  Future<void> _pickPlaceOfBirth() async {
    final selected = await showPlaceSuggestionSheet(
      context: context,
      title: "Select Place of Birth",
      initialValue: placeController.text,
    );
    if (selected == null || selected.trim().isEmpty) {
      return;
    }
    placeController.text = selected;
  }

  /// ================= PARSE DATE & TIME =================
  Map<String, dynamic> _parseBirthDate() {
    final parts = dateController.text.split('-');
    return {
      "year": int.parse(parts[0]),
      "month": int.parse(parts[1]),
      "day": int.parse(parts[2]),
    };
  }

  Map<String, dynamic> _parseBirthTime() {
    final parts = timeController.text.split(' ');
    final hm = parts[0].split(':');
    return {
      "hour": int.parse(hm[0]),
      "minute": int.parse(hm[1]),
      "ampm": parts[1],
    };
  }

  /// ================= GENERATE CHART =================
  Future<void> _generateChart() async {
    if (nameController.text.isEmpty ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty ||
        placeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all birth details")),
      );
      return;
    }

    setState(() => isLoading = true);

    final payload = <String, dynamic>{
      "name": nameController.text.trim(),
      "gender": gender,
      "birth_date": _parseBirthDate(),
      "birth_time": _parseBirthTime(),
      "place_of_birth": placeController.text.trim(),
      "astrology_type": astrologyType,
      "ayanamsa": ayanamsa,
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.birthChartGenerateApi),
        headers: const <String, String>{"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Birth chart failed: ${response.body}");
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body["data"] as Map<String, dynamic>? ?? <String, dynamic>{};

      final chartImagePath = data["chartImage"]?.toString() ?? "";
      final chartImageCandidates = ChartCacheHelper.resolveChartImageCandidates(
        chartImagePath,
      );
      final chartImageUrl = chartImageCandidates.isEmpty
          ? ""
          : chartImageCandidates.first;

      final chartData =
          data["chartData"] as Map<String, dynamic>? ?? <String, dynamic>{};
      if (chartImageUrl.isNotEmpty) {
        chartData["chartImageUrl"] = chartImageUrl;
        chartData["chartImageCandidates"] = chartImageCandidates;
      }

      await ChartCacheHelper.cacheChart(
        chartData: chartData,
        chartImage: chartImagePath,
        fallbackRashi: data["rashi"]?.toString(),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("birthDate", dateController.text.trim());
      await prefs.setString("birthTime", timeController.text.trim());
      await prefs.setString("birthPlace", placeController.text.trim());
      await prefs.setString("userName", nameController.text.trim());

      if (!mounted) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BirthChartResult(chartData: chartData),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: _birthchartTopBar(context),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnimatedAppBackground(
        showStarsInDark: true,
        showStarsInLight: true,
        child: Stack(
          children: [
            if (!isDark) Positioned.fill(child: _lightAuraOverlay()),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? AppGradients.glassBorder(theme)
                              : const Color(0xFFD6E3F6),
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.7)
                                : const Color(
                                    0xFF9AAECD,
                                  ).withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppGradients.glassFill(
                                  theme,
                                ).withValues(alpha: 0.86)
                              : Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.dmSans(
                                      fontSize: 18,
                                      color: isDark
                                          ? Colors.white70
                                          : const Color(0xFF64748B),
                                    ),
                                    children: [
                                      const TextSpan(text: "Generate Your "),
                                      TextSpan(
                                        text: context.l10n.tr("birthChart"),
                                        style: TextStyle(
                                          color: isDark
                                              ? colors.primary
                                              : const Color(0xFF2563EB),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(text: " Astrology"),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              _glassInput(
                                "Full Name",
                                Icons.person,
                                nameController,
                              ),
                              _glassInput(
                                "Date of Birth",
                                Icons.calendar_today,
                                dateController,
                                readOnly: true,
                                onTap: _pickDate,
                              ),
                              _glassInput(
                                "Time of Birth",
                                Icons.access_time,
                                timeController,
                                readOnly: true,
                                onTap: _pickTime,
                              ),
                              _glassInput(
                                "Place of Birth",
                                Icons.location_on,
                                placeController,
                                readOnly: true,
                                onTap: _pickPlaceOfBirth,
                                showDropdownIndicator: true,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _glassDropdown(
                                      "Gender",
                                      gender,
                                      ["male", "female"],
                                      (v) => setState(() => gender = v),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _glassDropdown(
                                      "Astrology",
                                      astrologyType,
                                      ["vedic", "western"],
                                      (v) => setState(() => astrologyType = v),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _generateChart,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    foregroundColor: colors.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: isLoading
                                      ? LoadingAnimationWidget.fourRotatingDots(
                                          color: colors.onPrimary,
                                          size: 32,
                                        )
                                      : Text(
                                          context.l10n.tr("generateChart"),
                                          style: GoogleFonts.dmSans(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lightAuraOverlay() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[Color(0x66A5B4FC), Color(0x00A5B4FC)],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[Color(0x66FDE68A), Color(0x00FDE68A)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= GLASS INPUT =================
  Widget _glassInput(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool readOnly = false,
    VoidCallback? onTap,
    bool showDropdownIndicator = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fillColor = isDark
        ? AppGradients.glassFill(theme)
        : Colors.white.withValues(alpha: 0.97);
    final borderColor = isDark
        ? AppGradients.glassBorder(theme)
        : const Color(0xFFD4E2F7);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final hintColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final iconBg = isDark ? Colors.white10 : const Color(0xFFEAF2FF);
    final iconColor = isDark ? Colors.white : const Color(0xFF2563EB);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, minWidth: 300),
          child: Container(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              onTap: onTap,
              style: GoogleFonts.dmSans(color: textColor),
              decoration: InputDecoration(
                prefixIconConstraints: const BoxConstraints(
                  minHeight: 48,
                  minWidth: 52,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                ),
                hintText: label,
                hintStyle: GoogleFonts.dmSans(color: hintColor),
                suffixIcon: showDropdownIndicator
                    ? Icon(Icons.keyboard_arrow_down_rounded, color: hintColor)
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ================= GLASS DROPDOWN =================
  Widget _glassDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fillColor = isDark
        ? AppGradients.glassFill(theme)
        : Colors.white.withValues(alpha: 0.97);
    final borderColor = isDark
        ? AppGradients.glassBorder(theme)
        : const Color(0xFFD4E2F7);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final labelColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: isDark ? theme.colorScheme.surface : Colors.white,
      iconEnabledColor: textColor,
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(
                e.toUpperCase(),
                style: GoogleFonts.dmSans(color: textColor),
              ),
            ),
          )
          .toList(),
      onChanged: (v) => onChanged(v!),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmSans(color: labelColor),
        filled: true,
        fillColor: fillColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.55)
                : const Color(0xFF60A5FA),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: GoogleFonts.dmSans(color: textColor),
    );
  }
}

/// ================= TOP BAR =================
PreferredSizeWidget _birthchartTopBar(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  return AppBar(
    backgroundColor: isDark
        ? AppGradients.glassFill(theme)
        : Colors.white.withValues(alpha: 0.94),
    elevation: 0,
    centerTitle: true,
    leading: Padding(
      padding: const EdgeInsets.only(left: 12),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: SizedBox(
          height: 38,
          width: 38,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
    ),
    title: Text(
      context.l10n.tr("birthChart"),
      style: GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
      ),
    ),
  );
}
