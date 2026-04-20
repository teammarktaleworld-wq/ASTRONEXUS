import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../../../ui_componets/cosmic/cosmic_one.dart';
import '../../../../../../../ui_componets/glass/glass_card.dart';

class MatchingScoreScreen extends StatelessWidget {
  final Map<String, dynamic> output;

  const MatchingScoreScreen({super.key, required this.output});

  static const Color accent = Color(0xFFDBC33F);
  static const Color success = Color(0xFF5EE6A8);
  static const Color warning = Color(0xFFF6C65A);
  static const Color danger = Color(0xFFFF8C82);

  @override
  Widget build(BuildContext context) {
    final double totalScore = _asDouble(output["total_score"]);
    final int outOf = _asInt(output["out_of"], fallback: 36);
    final double ratio = _scoreRatio(totalScore, outOf);
    final String maleName = _personName(output["male"], "Groom");
    final String femaleName = _personName(output["female"], "Bride");
    final List<_KootMetric> metrics = _kootMetrics();

    return Scaffold(
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool compact = constraints.maxWidth < 380;
                final double horizontalPadding = compact ? 12 : 16;
                final double sectionSpacing = compact ? 14 : 18;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    12,
                    horizontalPadding,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _topBar(context, compact: compact),
                      const SizedBox(height: 10),
                      Text(
                        "Cosmic Compatibility Overview",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: compact ? 12 : 13,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: sectionSpacing),
                      _summaryCard(
                        context,
                        compact: compact,
                        totalScore: totalScore,
                        outOf: outOf,
                        ratio: ratio,
                        maleName: maleName,
                        femaleName: femaleName,
                      ),
                      SizedBox(height: sectionSpacing),
                      _breakdownSection(
                        context,
                        compact: compact,
                        metrics: metrics,
                      ),
                      SizedBox(height: sectionSpacing),
                      _downloadSection(context, compact: compact),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _background() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF050B1E), Color(0xFF393053), Color(0xFF050B1E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(ignoring: true, child: SmoothShootingStars()),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.45)),
        ),
      ],
    );
  }

  Widget _topBar(BuildContext context, {required bool compact}) {
    return glassCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 10 : 12,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Material(
                color: Colors.white.withOpacity(0.08),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 52),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Matching Result",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: compact ? 17 : 19,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Detailed compatibility report",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required bool compact,
    required double totalScore,
    required int outOf,
    required double ratio,
    required String maleName,
    required String femaleName,
  }) {
    final Color verdictColor = _verdictColor(ratio);

    return glassCard(
      padding: EdgeInsets.zero,
      accent: verdictColor,
      child: Padding(
        padding: EdgeInsets.all(compact ? 18 : 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel("Compatibility Snapshot"),
            const SizedBox(height: 16),
            Wrap(
              spacing: 18,
              runSpacing: 18,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _scoreOrb(
                  compact: compact,
                  totalScore: totalScore,
                  outOf: outOf,
                  ratio: ratio,
                  tone: verdictColor,
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _verdict(ratio),
                        style: GoogleFonts.poppins(
                          fontSize: compact ? 22 : 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _verdictDescription(ratio),
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          height: 1.45,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _statusChip(
                            icon: Icons.auto_awesome,
                            label: "${(ratio * 100).round()}% aligned",
                            tint: verdictColor,
                          ),
                          _statusChip(
                            icon: Icons.favorite_outline,
                            label: _relationshipCue(ratio),
                            tint: accent,
                          ),
                          _statusChip(
                            icon: Icons.grid_view_rounded,
                            label: "8 kootas reviewed",
                            tint: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _peopleOverview(
              compact: compact,
              maleName: maleName,
              femaleName: femaleName,
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreOrb({
    required bool compact,
    required double totalScore,
    required int outOf,
    required double ratio,
    required Color tone,
  }) {
    final double size = compact ? 116 : 132;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: ratio,
              strokeWidth: compact ? 8 : 10,
              backgroundColor: Colors.white.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(tone),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatScore(totalScore),
                style: GoogleFonts.poppins(
                  fontSize: compact ? 28 : 34,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                "out of $outOf",
                style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _peopleOverview({
    required bool compact,
    required String maleName,
    required String femaleName,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 12;
        final bool stackCards = constraints.maxWidth < 430;
        final double cardWidth = stackCards
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: _personCard(
                role: "Groom",
                name: maleName,
                icon: Icons.male_rounded,
                accentColor: accent,
                compact: compact,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _personCard(
                role: "Bride",
                name: femaleName,
                icon: Icons.favorite_rounded,
                accentColor: success,
                compact: compact,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _personCard({
    required String role,
    required String name,
    required IconData icon,
    required Color accentColor,
    required bool compact,
  }) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 40 : 46,
            height: compact ? 40 : 46,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: compact ? 20 : 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: compact ? 14 : 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakdownSection(
    BuildContext context, {
    required bool compact,
    required List<_KootMetric> metrics,
  }) {
    return glassCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(compact ? 18 : 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel("Koota Breakdown"),
            const SizedBox(height: 8),
            Text(
              "Each score highlights how the pair aligns across the classic eight compatibility lenses.",
              style: GoogleFonts.dmSans(
                fontSize: 14,
                height: 1.45,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                const double spacing = 12;
                final int columns = constraints.maxWidth >= 760
                    ? 4
                    : constraints.maxWidth >= 460
                    ? 2
                    : 1;
                final double cardWidth = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - (spacing * (columns - 1))) /
                          columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final _KootMetric metric in metrics)
                      SizedBox(
                        width: cardWidth,
                        child: _kootMetricCard(metric, compact: compact),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _kootMetricCard(_KootMetric metric, {required bool compact}) {
    final Color tone = _verdictColor(metric.ratio);

    return Container(
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tone.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  metric.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: compact ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _miniBadge(_metricLabel(metric.ratio), tone),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            metric.scoreLabel,
            style: GoogleFonts.dmSans(
              fontSize: compact ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: metric.ratio,
              backgroundColor: Colors.white.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(tone),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _metricSummary(metric.ratio),
            style: GoogleFonts.dmSans(
              fontSize: 12,
              height: 1.4,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _downloadSection(BuildContext context, {required bool compact}) {
    return glassCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(compact ? 18 : 22),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool stacked = constraints.maxWidth < 420;
            final Widget button = SizedBox(
              width: stacked ? double.infinity : null,
              child: ElevatedButton.icon(
                onPressed: () => _downloadPdf(context),
                icon: const Icon(Icons.download_rounded, color: Colors.black),
                label: Text(
                  "Download PDF",
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  padding: EdgeInsets.symmetric(
                    horizontal: stacked ? 18 : 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            );

            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_downloadCopy(), const SizedBox(height: 16), button],
              );
            }

            return Row(
              children: [
                Expanded(child: _downloadCopy()),
                const SizedBox(width: 16),
                button,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _downloadCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Save or share the report",
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Export a compact PDF summary with the total score, verdict, and the complete koota table.",
          style: GoogleFonts.dmSans(
            fontSize: 13,
            height: 1.45,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 11,
        letterSpacing: 1.3,
        fontWeight: FontWeight.w700,
        color: accent,
      ),
    );
  }

  Widget _statusChip({
    required IconData icon,
    required String label,
    required Color tint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: tint.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tint),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniBadge(String label, Color tone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: tone,
        ),
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final pdf = pw.Document();
      final double totalScore = _asDouble(output["total_score"]);
      final int outOf = _asInt(output["out_of"], fallback: 36);
      final double ratio = _scoreRatio(totalScore, outOf);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (_) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "Matching Compatibility Report",
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text("Groom: ${_personName(output["male"], "Groom")}"),
                pw.Text("Bride: ${_personName(output["female"], "Bride")}"),
                pw.SizedBox(height: 12),
                pw.Text(
                  "Total Score: ${_formatScore(totalScore)} / $outOf",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text("Verdict: ${_verdict(ratio)}"),
                pw.SizedBox(height: 6),
                pw.Text("Summary: ${_verdictDescription(ratio)}"),
                pw.SizedBox(height: 16),
                pw.TableHelper.fromTextArray(
                  headers: const ["Koot", "Score"],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  data: _pdfTableData(),
                ),
              ],
            );
          },
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/matching_score.pdf");

      await file.writeAsBytes(await pdf.save());
      await OpenFilex.open(file.path);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text("Unable to generate PDF: $error"),
        ),
      );
    }
  }

  List<List<String>> _pdfTableData() {
    return _kootMetrics()
        .map((metric) => [metric.title, metric.scoreLabel])
        .toList();
  }

  List<_KootMetric> _kootMetrics() {
    return [
      _metricFromOutput("Varna", output["varna_kootam"]),
      _metricFromOutput("Vasya", output["vasya_kootam"]),
      _metricFromOutput("Tara", output["tara_kootam"]),
      _metricFromOutput("Yoni", output["yoni_kootam"]),
      _metricFromOutput("Graha Maitri", output["graha_maitri_kootam"]),
      _metricFromOutput("Gana", output["gana_kootam"]),
      _metricFromOutput("Rasi", output["rasi_kootam"]),
      _metricFromOutput("Nadi", output["nadi_kootam"]),
    ];
  }

  _KootMetric _metricFromOutput(String title, dynamic data) {
    if (data is Map) {
      return _KootMetric(
        title: title,
        score: _asDouble(data["score"]),
        outOf: _asInt(data["out_of"], fallback: 0),
      );
    }

    return _KootMetric(title: title, score: 0, outOf: 0);
  }

  double _scoreRatio(double score, int outOf) {
    if (outOf <= 0) return 0;
    return (score / outOf).clamp(0, 1).toDouble();
  }

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? "") ?? 0;
  }

  int _asInt(dynamic value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? "") ?? fallback;
  }

  String _personName(dynamic person, String fallback) {
    if (person is Map) {
      final String text =
          (person["mName"] ?? person["fName"] ?? person["name"] ?? "")
              .toString()
              .trim();
      if (text.isNotEmpty) return text;
    }
    return fallback;
  }

  String _verdict(double ratio) {
    if (ratio >= 0.78) return "Excellent Compatibility";
    if (ratio >= 0.5) return "Strong Potential";
    if (ratio >= 0.28) return "Balanced With Effort";
    return "Needs Extra Care";
  }

  String _verdictDescription(double ratio) {
    if (ratio >= 0.78) {
      return "The match shows strong harmony across core kootas, making this a naturally supportive pairing.";
    }
    if (ratio >= 0.5) {
      return "The score suggests a healthy foundation with several areas of strength and a few places to nurture.";
    }
    if (ratio >= 0.28) {
      return "There is meaningful potential here, though the relationship may benefit from patience and mutual understanding.";
    }
    return "The pairing may need deeper discussion and guidance before making big long-term decisions.";
  }

  String _relationshipCue(double ratio) {
    if (ratio >= 0.78) return "Very favorable";
    if (ratio >= 0.5) return "Promising match";
    if (ratio >= 0.28) return "Needs patience";
    return "Review carefully";
  }

  Color _verdictColor(double ratio) {
    if (ratio >= 0.78) return success;
    if (ratio >= 0.5) return warning;
    return ratio >= 0.28 ? accent : danger;
  }

  String _metricLabel(double ratio) {
    if (ratio >= 0.75) return "Strong";
    if (ratio >= 0.45) return "Stable";
    if (ratio > 0) return "Low";
    return "Nil";
  }

  String _metricSummary(double ratio) {
    if (ratio >= 0.75) {
      return "This factor contributes strongly to the overall compatibility.";
    }
    if (ratio >= 0.45) {
      return "This area looks balanced, with a generally positive influence.";
    }
    if (ratio > 0) {
      return "This factor is present, but it may need more care and understanding.";
    }
    return "This area adds little support to the overall compatibility score.";
  }

  String _formatScore(double score) {
    final bool hasFraction = score != score.roundToDouble();
    return hasFraction ? score.toStringAsFixed(1) : score.toStringAsFixed(0);
  }
}

class _KootMetric {
  final String title;
  final double score;
  final int outOf;

  const _KootMetric({
    required this.title,
    required this.score,
    required this.outOf,
  });

  double get ratio {
    if (outOf <= 0) return 0;
    return (score / outOf).clamp(0, 1).toDouble();
  }

  String get scoreLabel {
    final bool hasFraction = score != score.roundToDouble();
    final String scoreText = hasFraction
        ? score.toStringAsFixed(1)
        : score.toStringAsFixed(0);
    return "$scoreText / $outOf";
  }
}
