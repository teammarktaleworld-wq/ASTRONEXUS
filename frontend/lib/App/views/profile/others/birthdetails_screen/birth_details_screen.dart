import "dart:convert";

import "package:astro_tale/core/constants/app_colors.dart";
import "package:astro_tale/core/localization/app_localizations.dart";
import "package:astro_tale/core/theme/app_gradients.dart";
import "package:astro_tale/core/widgets/themed_shimmer.dart";
import "package:astro_tale/helper/chart_cache_helper.dart";
import "package:astro_tale/services/api_services/chatbot/profile_services.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:shared_preferences/shared_preferences.dart";

import "../../../../../ui_componets/cosmic/cosmic_one.dart";

class BirthDetailsScreen extends StatefulWidget {
  const BirthDetailsScreen({super.key});

  @override
  State<BirthDetailsScreen> createState() => _BirthDetailsScreenState();
}

class _BirthDetailsScreenState extends State<BirthDetailsScreen>
    with TickerProviderStateMixin {
  bool loading = true;
  late final AnimationController planetController;

  String name = "";
  String birthDate = "";
  String birthTime = "";
  String birthPlace = "";
  String rashi = "";
  String nakshatra = "";
  String lagna = "";
  String dashaPlanet = "";
  String dashaPeriod = "";

  List<String> chartImageCandidates = <String>[];
  int activeChartIndex = 0;

  @override
  void initState() {
    super.initState();
    planetController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 38),
    )..repeat();
    _loadBirthDetails();
  }

  @override
  void dispose() {
    planetController.dispose();
    super.dispose();
  }

  Future<void> _loadBirthDetails() async {
    final prefs = await SharedPreferences.getInstance();
    _applyPrefsData(prefs);

    try {
      await ProfileService.fetchMyProfile();
      final freshPrefs = await SharedPreferences.getInstance();
      _applyPrefsData(freshPrefs);
    } catch (_) {
      // Keep immediate cached view if refresh fails.
    }
  }

  void _applyPrefsData(SharedPreferences prefs) {
    final rawChartImage = prefs.getString("chartImage");
    final resolvedChartImage = prefs.getString("chartImageResolved");
    final allChartsRaw = prefs.getString("allCharts");

    final dashasRaw = prefs.getString("dashas");
    String planet = "";
    String period = "";

    if (dashasRaw != null && dashasRaw.isNotEmpty) {
      try {
        final dashas = jsonDecode(dashasRaw) as Map<String, dynamic>;
        final current = dashas["current_dasha"];
        if (current is Map<String, dynamic>) {
          planet = current["planet"]?.toString() ?? "";
          period =
              "${current["start_date"]?.toString() ?? ""} -> ${current["end_date"]?.toString() ?? ""}";
        }
      } catch (_) {
        // Keep dasha empty if parsing fails.
      }
    }

    final candidates = <String>[
      ...ChartCacheHelper.resolveChartImageCandidates(rawChartImage),
      ...ChartCacheHelper.resolveChartImageCandidates(resolvedChartImage),
    ];

    if (allChartsRaw != null && allChartsRaw.isNotEmpty) {
      try {
        final parsed = jsonDecode(allChartsRaw);
        if (parsed is List) {
          for (final entry in parsed) {
            if (entry is Map) {
              final path =
                  entry["chartImage"]?.toString() ??
                  entry["chartImageUrl"]?.toString();
              candidates.addAll(
                ChartCacheHelper.resolveChartImageCandidates(path),
              );
            }
          }
        }
      } catch (_) {
        // Ignore malformed local chart cache and continue.
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      name = prefs.getString("userName") ?? "";
      birthDate = prefs.getString("birthDate") ?? "";
      birthTime = prefs.getString("birthTime") ?? "";
      birthPlace = prefs.getString("birthPlace") ?? "";
      rashi = prefs.getString("zodiacSign") ?? "";
      nakshatra = prefs.getString("nakshatra") ?? "";
      lagna = prefs.getString("lagnam") ?? "";
      dashaPlanet = planet;
      dashaPeriod = period;
      chartImageCandidates = candidates
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();
      activeChartIndex = 0;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppGradients.glassFill(theme),
        centerTitle: true,
        title: Text(
          context.l10n.tr("birthChart"),
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 18),
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
            child: loading
                ? _loadingState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _panel(child: _chartPreview()),
                        const SizedBox(height: 22),
                        _section(context.l10n.tr("birthInformation"), context),
                        _panel(
                          child: Column(
                            children: <Widget>[
                              _row(context.l10n.tr("name"), name),
                              _row(context.l10n.tr("date"), birthDate),
                              _row(context.l10n.tr("time"), birthTime),
                              _row(context.l10n.tr("place"), birthPlace),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        _section(context.l10n.tr("astrologyDetails"), context),
                        _panel(
                          child: Column(
                            children: <Widget>[
                              _row(context.l10n.tr("rashi"), rashi),
                              _row(context.l10n.tr("nakshatra"), nakshatra),
                              _row(context.l10n.tr("lagna"), lagna),
                            ],
                          ),
                        ),
                        if (dashaPlanet.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 18),
                          _section(context.l10n.tr("currentMahadasha"), context),
                          _panel(
                            child: Column(
                              children: <Widget>[
                                _row(context.l10n.tr("planet"), dashaPlanet),
                                _row(context.l10n.tr("period"), dashaPeriod),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _loadingState() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const <Widget>[
        ThemedShimmerCard(height: 320),
        SizedBox(height: 14),
        ThemedShimmerCard(height: 190),
        SizedBox(height: 14),
        ThemedShimmerCard(height: 160),
      ],
    );
  }

  Widget _chartPreview() {
    if (chartImageCandidates.isEmpty) {
      return _chartFallback();
    }

    final activeUrl = chartImageCandidates[activeChartIndex];
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        activeUrl,
        height: 300,
        width: double.infinity,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return SizedBox(
            height: 300,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) {
          if (activeChartIndex < chartImageCandidates.length - 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => activeChartIndex += 1);
              }
            });
            return _chartRetrying();
          }
          return _chartFallback();
        },
      ),
    );
  }

  Widget _chartRetrying() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Text(
          "Trying backup chart source...",
          style: GoogleFonts.dmSans(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _chartFallback() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        "assets/images/birthchart.png",
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _panel({required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppGradients.glassFill(theme),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppGradients.glassBorder(theme)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _section(String title, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDark
        ? Colors.white.withOpacity(0.95)
        : AppColors.lightTextPrimary;

    final dividerColor = isDark
        ? Colors.white.withOpacity(0.15)
        : AppColors.lightTextPrimary.withOpacity(0.25);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 1,
            width: double.infinity,
            color: dividerColor,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          Flexible(
            child: Text(
              value.isEmpty ? "-" : value,
              textAlign: TextAlign.right,
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
