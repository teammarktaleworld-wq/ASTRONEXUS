import "package:astro_tale/core/theme/app_gradients.dart";
import "package:astro_tale/core/widgets/themed_shimmer.dart";
import "package:astro_tale/services/api_services/horoscope_api.dart";
import "package:astro_tale/ui_componets/cosmic/cosmic_one.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class HoroscopeDetailScreen extends StatefulWidget {
  final String sign;

  const HoroscopeDetailScreen({super.key, required this.sign});

  @override
  State<HoroscopeDetailScreen> createState() => _HoroscopeDetailScreenState();
}

class _HoroscopeDetailScreenState extends State<HoroscopeDetailScreen>
    with SingleTickerProviderStateMixin {
  String selectedType = "daily";
  bool isLoading = true;

  String? title;
  String? horoscopeText;
  Map<String, dynamic>? extraData;

  late final AnimationController controller;
  late final Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    fadeAnimation = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    _fetchHoroscope();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _fetchHoroscope() async {
    if (!mounted) {
      return;
    }
    setState(() => isLoading = true);
    try {
      final result = await HoroscopeApi.fetchHoroscope(
        sign: widget.sign,
        type: selectedType,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        title = result["title"]?.toString() ?? "";
        horoscopeText = result["horoscope"]?.toString() ?? "";
        extraData = result["extra"] as Map<String, dynamic>?;
        isLoading = false;
      });
      controller.forward(from: 0);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        title = "";
        horoscopeText = "";
        extraData = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final signName = _displaySign(widget.sign);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final bodyColor = isDark
        ? Colors.white.withValues(alpha: 0.9)
        : const Color(0xFF334155);
    final mutedColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final accentColor = isDark
        ? const Color(0xFFDBC33F)
        : const Color(0xFF1D4ED8);
    final borderColor = isDark ? Colors.white24 : const Color(0xFFD8E4F8);
    final cardFill = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.92);
    final previewAsset = "assets/horoscope/${widget.sign.toLowerCase()}.png";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppGradients.glassFill(theme)
            : Colors.white.withValues(alpha: 0.94),
        foregroundColor: titleColor,
        iconTheme: IconThemeData(color: titleColor),
        actionsIconTheme: IconThemeData(color: titleColor),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "$signName Horoscope",
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(decoration: AppGradients.screenDecoration(theme)),
          if (isDark) const Positioned.fill(child: SmoothShootingStars()),
          Positioned.fill(
            child: Container(color: AppGradients.screenOverlay(theme)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  _buildToggleRow(),
                  const SizedBox(height: 14),
                  Container(
                    height: 132,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: borderColor),
                      color: cardFill,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.white,
                              border: Border.all(color: borderColor),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Image.asset(
                                previewAsset,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.auto_awesome_rounded,
                                  color: accentColor,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  signName.toUpperCase(),
                                  style: GoogleFonts.dmSans(
                                    color: accentColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _titleForType(selectedType),
                                  style: GoogleFonts.dmSans(
                                    color: titleColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Tap another tab for weekly or monthly guidance",
                                  style: GoogleFonts.dmSans(
                                    color: mutedColor,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardFill,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.32)
                                : const Color(
                                    0xFF9AAECE,
                                  ).withValues(alpha: 0.22),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: isLoading
                          ? const ThemedShimmerCard(height: 260)
                          : FadeTransition(
                              opacity: fadeAnimation,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Cosmic Insight for $signName",
                                      style: GoogleFonts.dmSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        color: titleColor,
                                      ),
                                    ),
                                    if ((title ?? "").isNotEmpty) ...<Widget>[
                                      const SizedBox(height: 6),
                                      Text(
                                        title!,
                                        style: GoogleFonts.dmSans(
                                          color: accentColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Divider(color: borderColor),
                                    const SizedBox(height: 10),
                                    Text(
                                      horoscopeText?.trim().isEmpty == true
                                          ? "Horoscope not available"
                                          : horoscopeText!,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                        height: 1.7,
                                        color: bodyColor,
                                      ),
                                    ),
                                    if (selectedType == "monthly" &&
                                        extraData != null) ...<Widget>[
                                      const SizedBox(height: 16),
                                      _monthlyMeta(
                                        "Standout Days",
                                        _asList(extraData!["standout_days"]),
                                      ),
                                      const SizedBox(height: 10),
                                      _monthlyMeta(
                                        "Challenging Days",
                                        _asList(extraData!["challenging_days"]),
                                      ),
                                    ],
                                  ],
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
    );
  }

  Widget _buildToggleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _toggleButton("Daily", "daily"),
        const SizedBox(width: 8),
        _toggleButton("Weekly", "weekly"),
        const SizedBox(width: 8),
        _toggleButton("Monthly", "monthly"),
      ],
    );
  }

  Widget _toggleButton(String label, String type) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedFill = isDark
        ? const Color(0xFFDBC33F)
        : const Color(0xFF1D4ED8);
    final idleFill = isDark
        ? Colors.white10
        : const Color(0xFFE2E8F0).withValues(alpha: 0.7);
    final borderColor = isDark ? Colors.white24 : const Color(0xFFD8E4F8);
    final activeText = isDark ? Colors.black : Colors.white;
    final inactiveText = isDark ? Colors.white70 : const Color(0xFF334155);
    final isSelected = selectedType == type;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() => selectedType = type);
        _fetchHoroscope();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedFill : idleFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            color: isSelected ? activeText : inactiveText,
          ),
        ),
      ),
    );
  }

  Widget _monthlyMeta(String label, List<String> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final valueColor = isDark ? Colors.white70 : const Color(0xFF475569);
    final fillColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.88);
    final borderColor = isDark ? Colors.white24 : const Color(0xFFD8E4F8);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: titleColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            items.isEmpty ? "-" : items.join(", "),
            style: GoogleFonts.dmSans(color: valueColor),
          ),
        ],
      ),
    );
  }

  String _titleForType(String type) {
    switch (type) {
      case "daily":
        return "Daily Guidance";
      case "weekly":
        return "Weekly Guidance";
      case "monthly":
        return "Monthly Guidance";
      default:
        return "Horoscope";
    }
  }

  String _displaySign(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) {
      return "Zodiac";
    }
    return cleaned[0].toUpperCase() + cleaned.substring(1).toLowerCase();
  }

  List<String> _asList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList(growable: false);
    }
    if (value == null) {
      return const <String>[];
    }
    final text = value.toString().trim();
    if (text.isEmpty) {
      return const <String>[];
    }
    return <String>[text];
  }
}
