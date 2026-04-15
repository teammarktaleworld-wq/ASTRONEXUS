enum ReportCategory { self, wealth }

class ReportItem {
  final String id;
  final String title;
  final String subtitle;
  final String asset;
  final bool isFree;
  final bool isLocked;
  final bool highlight;
  final ReportCategory category;

  ReportItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.category,
    this.isFree = false,
    this.isLocked = false,
    this.highlight = false,
  });
}
