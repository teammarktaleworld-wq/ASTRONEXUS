import "package:astro_tale/core/localization/app_localizations.dart";
import "package:astro_tale/core/theme/app_gradients.dart";
import "package:astro_tale/helper/chart_cache_helper.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/svg.dart";
import "package:google_fonts/google_fonts.dart";

import "../../../../../../helper/Widgets/Pdf_downloader.dart";
import "../../../../../../ui_componets/cosmic/cosmic_one.dart";

class BirthChartResult extends StatefulWidget {
  const BirthChartResult({super.key, required this.chartData});

  final Map<String, dynamic> chartData;

  @override
  State<BirthChartResult> createState() => _BirthChartResultState();
}

class _BirthChartResultState extends State<BirthChartResult> {
  int _activeChartIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final chartImageCandidates = _chartImageCandidates();
    final chartImageUrl = chartImageCandidates.isEmpty
        ? ""
        : chartImageCandidates[_activeChartIndex.clamp(
            0,
            chartImageCandidates.length - 1,
          )];

    final houses = _asMap(widget.chartData["houses"]);
    final planetsInfo = _asMap(widget.chartData["planets"]);
    final rashi = widget.chartData["rashi"]?.toString() ?? "";
    final nakshatra = widget.chartData["nakshatra"]?.toString() ?? "";
    final ascendant = _asMap(widget.chartData["ascendant"]);
    final ascSign = ascendant["sign"]?.toString() ?? "";
    final ascLongitude = (ascendant["longitude"] is num)
        ? (ascendant["longitude"] as num).toDouble()
        : 0.0;

    return Scaffold(
      appBar: _birthChartTopBar(context),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(decoration: AppGradients.screenDecoration(theme)),
          if (isDark) const Positioned.fill(child: SmoothShootingStars()),
          Positioned.fill(
            child: Container(color: AppGradients.screenOverlay(theme)),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: AppGradients.glassFill(theme),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: AppGradients.glassBorder(theme)),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoText(
                          context,
                          context.l10n.tr("rashi"),
                          rashi,
                          colors.primary,
                        ),
                        const SizedBox(height: 6),
                        _infoText(
                          context,
                          context.l10n.tr("nakshatra"),
                          nakshatra,
                          colors.secondary,
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              color: isDark
                                  ? Colors.white70
                                  : colors.onSurface.withValues(alpha: 0.75),
                            ),
                            children: [
                              TextSpan(
                                text: "${context.l10n.tr("ascendant")}: ",
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: ascSign),
                              TextSpan(
                                text:
                                    " (${ascLongitude.toStringAsFixed(2)} deg)",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white54
                                      : colors.onSurface.withValues(alpha: 0.6),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: SizedBox(
                            width: 400,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.picture_as_pdf,
                                color: Colors.white,
                              ),
                              label: Text(
                                context.l10n.tr("downloadPdf"),
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: chartImageUrl.isEmpty
                                  ? null
                                  : () {
                                      BirthChartPdfService.generateAndDownloadPdf(
                                        chartImageUrl: chartImageUrl,
                                        rashi: rashi,
                                        nakshatra: nakshatra,
                                        ascSign: ascSign,
                                        ascLongitude: ascLongitude,
                                      );
                                    },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  color: AppGradients.glassFill(theme),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: AppGradients.glassBorder(theme)),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(
                        height: 450,
                        width: 450,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                context.l10n.tr("generatedBirthChart"),
                                style: GoogleFonts.dmSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (chartImageUrl.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: InteractiveViewer(
                                    minScale: 0.5,
                                    maxScale: 4,
                                    child: chartImageUrl.endsWith(".svg")
                                        ? SvgPicture.network(
                                            chartImageUrl,
                                            placeholderBuilder: (_) => SizedBox(
                                              height: 320,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: colors.primary,
                                                    ),
                                              ),
                                            ),
                                          )
                                        : Image.network(
                                            chartImageUrl,
                                            errorBuilder: (_, __, ___) {
                                              if (_activeChartIndex <
                                                  chartImageCandidates.length -
                                                      1) {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                      if (mounted) {
                                                        setState(
                                                          () =>
                                                              _activeChartIndex +=
                                                                  1,
                                                        );
                                                      }
                                                    });
                                                return _retryingText();
                                              }
                                              return Image.asset(
                                                "assets/images/birthchart.png",
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                                  ),
                                )
                              else
                                Text(
                                  context.l10n.tr("chartImageUnavailable"),
                                  style: GoogleFonts.dmSans(
                                    color: isDark
                                        ? Colors.white54
                                        : colors.onSurface.withValues(
                                            alpha: 0.6,
                                          ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                ...List.generate(houses.length, (index) {
                  final houseNumber = (index + 1).toString();
                  final data = _asMap(houses[houseNumber]);
                  final planets =
                      data["planets"] as List<dynamic>? ?? <dynamic>[];

                  return Card(
                    color: AppGradients.glassFill(theme),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppGradients.glassBorder(theme)),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                color: isDark
                                    ? Colors.white70
                                    : colors.onSurface.withValues(alpha: 0.75),
                              ),
                              children: [
                                TextSpan(
                                  text: "House $houseNumber ",
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: "• ${data["sign"] ?? ""}",
                                  style: TextStyle(
                                    color: colors.secondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          planets.isNotEmpty
                              ? Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: planets.map((planetName) {
                                    final planetKey = planetName.toString();
                                    final planetSign =
                                        _asMap(
                                          planetsInfo[planetKey],
                                        )["sign"]?.toString() ??
                                        "";
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppGradients.glassBorder(theme),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          style: GoogleFonts.dmSans(
                                            fontSize: 14,
                                            color: isDark
                                                ? Colors.white70
                                                : colors.onSurface.withValues(
                                                    alpha: 0.75,
                                                  ),
                                          ),
                                          children: [
                                            TextSpan(
                                              text: planetKey,
                                              style: TextStyle(
                                                color: colors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: planetSign.isNotEmpty
                                                  ? " ($planetSign)"
                                                  : "",
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white54
                                                    : colors.onSurface
                                                          .withValues(
                                                            alpha: 0.6,
                                                          ),
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              : Text(
                                  context.l10n.tr("noPlanets"),
                                  style: GoogleFonts.dmSans(
                                    color: isDark
                                        ? Colors.white38
                                        : colors.onSurface.withValues(
                                            alpha: 0.55,
                                          ),
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoText(
    BuildContext context,
    String label,
    String value,
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return RichText(
      text: TextSpan(
        style: GoogleFonts.dmSans(
          fontSize: 15,
          color: isDark
              ? Colors.white70
              : colors.onSurface.withValues(alpha: 0.75),
        ),
        children: [
          TextSpan(
            text: "$label: ",
            style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _retryingText() {
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

  List<String> _chartImageCandidates() {
    final candidates = <String>[];

    final dynamic explicitCandidates = widget.chartData["chartImageCandidates"];
    if (explicitCandidates is List) {
      for (final item in explicitCandidates) {
        final url = item?.toString().trim() ?? "";
        if (url.isNotEmpty && !candidates.contains(url)) {
          candidates.add(url);
        }
      }
    }

    final explicitUrl =
        widget.chartData["chartImageUrl"]?.toString().trim() ?? "";
    if (explicitUrl.isNotEmpty && !candidates.contains(explicitUrl)) {
      candidates.add(explicitUrl);
    }

    final rawPath =
        widget.chartData["chartImage"]?.toString() ??
        widget.chartData["chart_image"]?.toString() ??
        "";
    final resolved = ChartCacheHelper.resolveChartImageCandidates(rawPath);
    for (final url in resolved) {
      if (url.isNotEmpty && !candidates.contains(url)) {
        candidates.add(url);
      }
    }

    return candidates;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
    }
    return <String, dynamic>{};
  }
}

PreferredSizeWidget _birthChartTopBar(BuildContext context) {
  final theme = Theme.of(context);
  final colors = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    leading: Padding(
      padding: const EdgeInsets.only(left: 12),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: isDark ? Colors.white : colors.onSurface,
        ),
      ),
    ),
    title: Text(
      context.l10n.tr("birthChart"),
      style: GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : colors.onSurface,
      ),
    ),
  );
}
