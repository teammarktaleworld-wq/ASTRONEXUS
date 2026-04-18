import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../../model/report_Model.dart';

class AnnualReportDetailScreen extends StatefulWidget {
  final ReportItem report;

  const AnnualReportDetailScreen({super.key, required this.report});

  @override
  State<AnnualReportDetailScreen> createState() =>
      _AnnualReportDetailScreenState();
}

class _AnnualReportDetailScreenState extends State<AnnualReportDetailScreen> {
  bool _generating = false;

  Future<void> _generateAndOpenPdf() async {
    setState(() => _generating = true);

    try {
      final pdf = pw.Document();

      // Load image once from assets
      final ByteData bytes = await rootBundle.load(widget.report.asset);
      final Uint8List imageData = bytes.buffer.asUint8List();
      final pw.ImageProvider pwImage = pw.MemoryImage(imageData);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // Title
            pw.Text(
              widget.report.title,
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),

            // Subtitle
            pw.Text(
              widget.report.subtitle,
              style: pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 24),

            // Report Image
            pw.Center(
              child: pw.Image(
                pwImage,
                width: 400,
                height: 200,
                fit: pw.BoxFit.cover,
              ),
            ),
            pw.SizedBox(height: 24),

            // Life Theory Section
            pw.Text(
              "Life Theory & Insights",
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              "The ${widget.report.title} provides a detailed analysis of your year. "
              "It highlights your opportunities, challenges, and important moments. "
              "This report will guide you to align your actions with your life goals.",
              style: pw.TextStyle(fontSize: 14, lineSpacing: 4),
            ),
            pw.SizedBox(height: 16),

            // Key Opportunities
            pw.Text(
              "Key Opportunities",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Bullet(text: "Focus on personal growth and career development."),
            pw.Bullet(text: "Strengthen relationships and family bonds."),
            pw.Bullet(text: "Invest in health and mindfulness."),
            pw.Bullet(text: "Plan wealth strategies for long-term stability."),
            pw.SizedBox(height: 16),

            // Recommendations
            pw.Text(
              "Recommendations",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),

            pw.Bullet(
              text: "Maintain a balanced diet, including greens and proteins.",
            ),
            pw.Bullet(text: "Exercise regularly to boost energy and focus."),
            pw.Bullet(text: "Schedule weekly reflections to track progress."),
            pw.Bullet(text: "Keep a journal of achievements and challenges."),
            pw.Bullet(text: "Practice meditation or mindfulness daily."),
            pw.SizedBox(height: 16),

            // Lifestyle & Health
            pw.Text(
              "Lifestyle & Health Tips",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),

            pw.Bullet(text: "Eat more seasonal fruits and vegetables."),
            pw.Bullet(text: "Stay hydrated and limit processed foods."),
            pw.Bullet(text: "Prioritize sleep for better mental clarity."),
            pw.Bullet(text: "Include light physical activity daily."),
            pw.Bullet(text: "Connect with nature for stress relief."),
            pw.SizedBox(height: 16),

            // Personal Notes
            pw.Text(
              "Personal Notes",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),

            pw.Text(
              "This year, focus on building meaningful connections, "
              "following your intuition, and pursuing personal goals with confidence. "
              "Use the insights from this report to plan your months strategically, "
              "and remember to celebrate small victories along the way.",
              style: pw.TextStyle(fontSize: 14, lineSpacing: 4),
            ),
          ],
        ),
      );

      // Save PDF to local storage
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/${widget.report.id}.pdf");
      await file.writeAsBytes(await pdf.save());

      // Open PDF
      await OpenFilex.open(file.path);
    } catch (e) {
      print("PDF generation error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to generate PDF")));
    } finally {
      setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;

    return Scaffold(
      backgroundColor: const Color(0xff050B1E),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff393053), Color(0xff050B1E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      report.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      report.subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Report Illustration
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        report.asset,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Life Theory / Content
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        "Life Theory & Annual Insights:\n\n"
                        "The ${report.title} analyzes your personal journey, highlighting opportunities, challenges, "
                        "and key moments. It provides guidance on career, relationships, health, wealth, and spiritual growth. "
                        "By understanding the patterns, you can align your actions with your goals, make informed decisions, "
                        "and create a meaningful life strategy for the year ahead. This report includes personalized insights "
                        "and actionable recommendations designed to maximize your growth and fulfillment.",
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Generate & Open PDF Button
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: _generating ? null : _generateAndOpenPdf,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.green],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: _generating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Generate PDF",
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
