import 'package:flutter/material.dart';

import '../model/report_Model.dart';
import 'report_card.dart';
import 'section_title.dart';

class ReportsHorizontalSection extends StatelessWidget {
  final String title;
  final List<ReportItem> reports;
  final Function(ReportItem) onTap;

  const ReportsHorizontalSection({
    super.key,
    required this.title,
    required this.reports,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title),
        const SizedBox(height: 14),
        SizedBox(
          height: 300,
          width: double.infinity,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            scrollDirection: Axis.horizontal,
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 280,
                child: ReportCard(
                  report: reports[index],
                  onTap: () => onTap(reports[index]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}
