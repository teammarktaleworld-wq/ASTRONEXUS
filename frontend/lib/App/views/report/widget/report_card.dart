import 'dart:ui';
import 'package:astro_tale/App/views/report/output/Annual/Annual_reports.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/report_Model.dart';

class ReportCard extends StatelessWidget {
  final ReportItem report;
  final VoidCallback onTap;
  final VoidCallback? onButtonTap; // new button callback

  const ReportCard({
    super.key,
    required this.report,
    required this.onTap,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.7,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff18122B), Color(0xff18122B)],
          ),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 🌌 Glassy Overlay
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(color: Colors.white.withOpacity(0.05)),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔖 Top Row (Badge + Lock)
                    Row(
                      children: [
                        if (report.isFree)
                          _badge("FREE", color: Colors.greenAccent.shade400),
                        const Spacer(),
                        if (report.isLocked)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 📊 Illustration
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          report.asset,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🧾 Title
                    Text(
                      report.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // 📝 Subtitle
                    Text(
                      report.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 🔘 Try/Open Button
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) {
                                return AnnualReportDetailScreen(report: report);
                              },
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: report.isFree
                                  ? [
                                      Colors.greenAccent.shade400,
                                      Colors.greenAccent.shade700,
                                    ]
                                  : [
                                      Colors.blueAccent.shade400,
                                      Colors.blueAccent.shade700,
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              report.isFree ? "Try" : "Open",
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🏷 Badge
  Widget _badge(String text, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
