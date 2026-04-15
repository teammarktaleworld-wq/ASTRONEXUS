import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../model/report_Model.dart';
import '../../widget/report_Manual.dart';
import '../../widget/report_bg.dart';
import '../../widget/report_floating_bar.dart';
import '../../widget/report_header.dart';
import '../../widget/report_row.dart';
import '../../widget/report_vertical.dart';
import '../../widget/reports_filter_bar.dart';
import '../../widget/section_title.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final reports = <ReportItem>[
    /// =======================
    /// SELF / PERSONAL
    /// =======================
    ReportItem(
      id: "annual_2024",
      title: "Annual Report",
      subtitle: "New Year, New Opportunities!",
      asset: "assets/reports/annual.png",
      category: ReportCategory.self,
      isFree: true,
      highlight: true,
    ),
    ReportItem(
      id: "life_guidance",
      title: "Life Guidance",
      subtitle: "Your kundali & birth charts",
      asset: "assets/reports/life.png",
      category: ReportCategory.self,
    ),
    ReportItem(
      id: "personality",
      title: "Personality Report",
      subtitle: "Strengths, traits & tendencies",
      asset: "assets/reports/personality.png",
      category: ReportCategory.self,
    ),
    ReportItem(
      id: "mental_wellness",
      title: "Mental Wellness",
      subtitle: "Emotional balance & clarity",
      asset: "assets/reports/wellness.png",
      category: ReportCategory.self,
      isLocked: true,
    ),
    ReportItem(
      id: "career_path",
      title: "Career Path",
      subtitle: "Professional growth insights",
      asset: "assets/reports/career.png",
      category: ReportCategory.self,
    ),
    ReportItem(
      id: "relationships",
      title: "Relationships",
      subtitle: "Compatibility & bonds",
      asset: "assets/reports/relationship.png",
      category: ReportCategory.self,
      isLocked: true,
    ),
    ReportItem(
      id: "health_energy",
      title: "Health & Energy",
      subtitle: "Vitality & lifestyle guidance",
      asset: "assets/reports/health.png",
      category: ReportCategory.self,
    ),
    ReportItem(
      id: "spiritual_growth",
      title: "Spiritual Growth",
      subtitle: "Inner journey & purpose",
      asset: "assets/reports/spiritual.png",
      category: ReportCategory.self,
      isLocked: true,
    ),

    /// =======================
    /// WEALTH / PROSPERITY
    /// =======================
    ReportItem(
      id: "wealth_overview",
      title: "Wealth Overview",
      subtitle: "Financial potential analysis",
      asset: "assets/reports/wealth.png",
      category: ReportCategory.wealth,
      isLocked: true,
    ),
    ReportItem(
      id: "billionaire",
      title: "Billionaire Mindset",
      subtitle: "Wealth timing & mindset",
      asset: "assets/reports/billionaire.png",
      category: ReportCategory.wealth,
      isLocked: true,
      highlight: true,
    ),
    ReportItem(
      id: "income_sources",
      title: "Income Sources",
      subtitle: "Multiple earning paths",
      asset: "assets/reports/income.png",
      category: ReportCategory.wealth,
    ),
    ReportItem(
      id: "investment_timing",
      title: "Investment Timing",
      subtitle: "When to invest & grow",
      asset: "assets/reports/investment.png",
      category: ReportCategory.wealth,
      isLocked: true,
    ),
    ReportItem(
      id: "business_success",
      title: "Business Success",
      subtitle: "Entrepreneurial guidance",
      asset: "assets/reports/business.png",
      category: ReportCategory.wealth,
    ),
    ReportItem(
      id: "risk_analysis",
      title: "Risk Analysis",
      subtitle: "Financial risk patterns",
      asset: "assets/reports/risk.png",
      category: ReportCategory.wealth,
      isLocked: true,
    ),
    ReportItem(
      id: "luxury_life",
      title: "Luxury Lifestyle",
      subtitle: "Comfort & abundance outlook",
      asset: "assets/reports/luxury.png",
      category: ReportCategory.wealth,
    ),
    ReportItem(
      id: "property_growth",
      title: "Property Growth",
      subtitle: "Real estate opportunities",
      asset: "assets/reports/property.png",
      category: ReportCategory.wealth,
      isLocked: true,
    ),
    ReportItem(
      id: "passive_income",
      title: "Passive Income",
      subtitle: "Earnings while you rest",
      asset: "assets/reports/passive.png",
      category: ReportCategory.wealth,
    ),
    ReportItem(
      id: "financial_blocks",
      title: "Financial Blocks",
      subtitle: "Hidden money obstacles",
      asset: "assets/reports/blocks.png",
      category: ReportCategory.wealth,
      isLocked: true,
    ),
    ReportItem(
      id: "long_term_wealth",
      title: "Long-Term Wealth",
      subtitle: "Sustained prosperity plan",
      asset: "assets/reports/longterm.png",
      category: ReportCategory.wealth,
    ),
    ReportItem(
      id: "legacy_building",
      title: "Legacy Building",
      subtitle: "Generational wealth vision",
      asset: "assets/reports/legacy.png",
      category: ReportCategory.wealth,
      isLocked: true,
    ),
  ];

  String selectedFilter = "All reports";

  void _onFilterTap(BuildContext context, GlobalKey key) async {
    final filters = ["All reports", "Self", "Wealth"];

    // Get the position of the icon
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // Show popup menu attached to the icon
    final chosen = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height, // below the icon
        offset.dx + size.width,
        offset.dy,
      ),
      items: filters
          .map(
            (f) => PopupMenuItem<String>(
              value: f,
              child: Text(
                f,
                style: GoogleFonts.dmSans(color: Colors.black87, fontSize: 16),
              ),
            ),
          )
          .toList(),
      elevation: 8,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    if (chosen != null) {
      print("Selected filter: $chosen");
      // Update your filter state here
    }
  }

  @override
  Widget build(BuildContext context) {
    final selfReports = reports
        .where((e) => e.category == ReportCategory.self)
        .toList();

    final wealthReports = reports
        .where((e) => e.category == ReportCategory.wealth)
        .toList();

    final selfFeatured = selfReports.where((e) => e.highlight).toList();

    final selfNormal = selfReports.where((e) => !e.highlight).toList();

    final wealthFeatured = wealthReports.where((e) => e.highlight).toList();

    final wealthNormal = wealthReports.where((e) => !e.highlight).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Report",
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 26,
          ),
        ),
      ),
      backgroundColor: const Color(0xff050B1E),
      body: Stack(
        children: [
          const ReportsBackground(),

          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 140),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 14),
                  ReportsFilterBar(
                    label: selectedFilter, // shows current filter
                    filters: ["All reports", "Self", "Wealth"],
                    onSelected: (filter) {
                      setState(() {
                        selectedFilter = filter; // update selected filter
                      });
                    },
                  ),
                  const SizedBox(height: 14),

                  const ReportsManualSection(),

                  const SizedBox(height: 28),
                  SectionTitle("Understand Yourself"),
                  Divider(
                    color: Colors.white.withOpacity(0.6),
                    thickness: 2, // height of the line
                    indent: 16, // space from left
                    endIndent: 16, // space from right
                  ),

                  const SizedBox(height: 16),

                  /// ⭐ Featured (Horizontal)
                  for (int i = 0; i < 5; i++)
                    ReportsHorizontalSection(
                      title: "Reports Astrology Doc ${i + 1}",
                      reports: reports.skip(i).take(5).toList(),
                      onTap: _onReportTap,
                    ),

                  /// 🔹 10 VERTICAL SECTIONS
                  for (int i = 0; i < 15; i++)
                    ReportsVerticalSection(
                      title: "Detailed Astrology ${i + 1}",
                      reports: reports.skip(i).take(3).toList(),
                      onTap: _onReportTap,
                    ),
                ],
              ),
            ),
          ),

          /// 📊 Floating Progress Bar
          const ReportsProgressPositionedBar(completed: 3, total: 8),
        ],
      ),
    );
  }

  void _onReportTap(ReportItem report) {
    // entitlement / navigation logic
  }
}
