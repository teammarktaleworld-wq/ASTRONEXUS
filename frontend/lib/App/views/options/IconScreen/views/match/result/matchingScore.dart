import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../../../../../../../ui_componets/cosmic/cosmic_one.dart';
import '../../../../../../../ui_componets/glass/glass_card.dart';

class MatchingScoreScreen extends StatelessWidget {
  final Map<String, dynamic> output;

  const MatchingScoreScreen({super.key, required this.output});

  static const Color accent = Color(0xffDBC33F);

  @override
  Widget build(BuildContext context) {
    final double totalScore = (output["total_score"] as num).toDouble();
    final int outOf = (output["out_of"] as num).toInt();

    final String maleName = output["male"]?["mName"] ?? "Groom";
    final String femaleName = output["female"]?["fName"] ?? "Bride";

    return Scaffold(
      body: Stack(
        children: [
          _background(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _topBar(context),

                  const SizedBox(height: 8),

                  Text(
                    "Cosmic Compatibility Overview",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Names Card
                  glassCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _nameColumn("Groom", maleName),
                          _nameColumn("Bride", femaleName),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Total Score
                  glassCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Ashtakoota Score",
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${totalScore.toStringAsFixed(1)} / $outOf",
                            style: GoogleFonts.dmSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _verdict(totalScore),
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// GRID — No RenderFlex issues
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.3,
                    children: _kootGridCards(),
                  ),

                  const SizedBox(height: 20),

                  /// PDF Button
                  glassCard(
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadPdf(context),
                      icon: const Icon(Icons.download, color: Colors.black),
                      label: Text(
                        "Download PDF",
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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

  // ───────── BACKGROUND ─────────

  Widget _background() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff050B1E),
                // Color(0xff1C4D8D),
                // Color(0xff0F2854),
                Color(0xff393053),
                Color(0xff050B1E),
              ],
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

  // ───────── TOP BAR WITH BACK ─────────

  Widget _topBar(BuildContext context) {
    return glassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Matching Result",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 40), // balances back button
          ],
        ),
      ),
    );
  }

  // ───────── NAME COLUMN ─────────

  Widget _nameColumn(String label, String name) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: accent,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ───────── GRID CARDS ─────────

  List<Widget> _kootGridCards() {
    final Map<String, dynamic> koots = {
      "Varna": output["varna_kootam"],
      "Vasya": output["vasya_kootam"],
      "Tara": output["tara_kootam"],
      "Yoni": output["yoni_kootam"],
      "Graha": output["graha_maitri_kootam"],
      "Gana": output["gana_kootam"],
      "Rasi": output["rasi_kootam"],
      "Nadi": output["nadi_kootam"],
    };

    return koots.entries.map((e) {
      final score = (e.value["score"] as num).toDouble();
      final outOf = (e.value["out_of"] as num).toInt();

      return glassCard(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                e.key,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$score / $outOf",
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // ───────── VERDICT ─────────

  String _verdict(double score) {
    if (score >= 28) return "Excellent Compatibility";
    if (score >= 18) return "Good Compatibility";
    if (score >= 10) return "Average Compatibility";
    return "Low Compatibility";
  }

  // ───────── PDF (NO PRINTING) ─────────

  Future<void> _downloadPdf(BuildContext context) async {
    final pdf = pw.Document();

    final double totalScore = (output["total_score"] as num).toDouble();
    final int outOf = (output["out_of"] as num).toInt();

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

              pw.Text("Groom: ${output["male"]?["mName"] ?? ""}"),
              pw.Text("Bride: ${output["female"]?["fName"] ?? ""}"),

              pw.SizedBox(height: 12),

              pw.Text(
                "Total Score: ${totalScore.toStringAsFixed(1)} / $outOf",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 6),
              pw.Text("Verdict: ${_verdict(totalScore)}"),

              pw.SizedBox(height: 16),

              pw.Table.fromTextArray(
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
  }

  List<List<String>> _pdfTableData() {
    final Map<String, dynamic> koots = {
      "Varna": output["varna_kootam"],
      "Vasya": output["vasya_kootam"],
      "Tara": output["tara_kootam"],
      "Yoni": output["yoni_kootam"],
      "Graha Maitri": output["graha_maitri_kootam"],
      "Gana": output["gana_kootam"],
      "Rasi": output["rasi_kootam"],
      "Nadi": output["nadi_kootam"],
    };

    return koots.entries
        .map((e) => ["${e.key}", "${e.value["score"]} / ${e.value["out_of"]}"])
        .toList();
  }
}
