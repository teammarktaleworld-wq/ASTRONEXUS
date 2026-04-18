import 'package:flutter/material.dart';

import '../model/report_Model.dart';
import 'report_card.dart';
import 'section_title.dart';

class ReportsVerticalSection extends StatelessWidget {
  final String title;
  final List<ReportItem> reports;
  final Function(ReportItem) onTap;

  const ReportsVerticalSection({
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
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: reports.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return SizedBox(
              height: 300,
              child: ReportCard(
                report: reports[index],
                onTap: () => onTap(reports[index]),
              ),
            );
          },
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}
