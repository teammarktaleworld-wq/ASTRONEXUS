import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../sharedWidgets/step_image.dart';

class StepBirthDate extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const StepBirthDate({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<StepBirthDate> createState() => _StepBirthDateState();
}

class _StepBirthDateState extends State<StepBirthDate> {
  final List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  late List<int> days;
  late List<int> years;

  int selectedMonth = 0;
  int selectedDay = 1;
  int selectedYear = 1970;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    days = List.generate(31, (i) => i + 1);
    years = List.generate(50, (i) => 1970 + i);

    // If a value exists, parse it
    if (widget.controller.text.isNotEmpty) {
      try {
        final dt = DateTime.parse(widget.controller.text);
        selectedMonth = dt.month - 1;
        selectedDay = dt.day;
        selectedYear = dt.year;
      } catch (_) {}
    }
  }

  void _updateDate() {
    final monthNum = selectedMonth + 1;
    final dateStr = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime(selectedYear, monthNum, selectedDay));
    widget.controller.text = dateStr;
    widget.onChanged(dateStr);
  }

  Widget picker(
    BuildContext context,
    List items,
    int selectedIndex,
    ValueChanged<int> onSelected,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return CupertinoPicker(
      itemExtent: 40,
      scrollController: FixedExtentScrollController(initialItem: selectedIndex),
      backgroundColor: isDark
          ? const Color(0xFF0A1633)
          : const Color(0xFFF2F5FF),
      onSelectedItemChanged: (i) {
        onSelected(i);
        _updateDate();
      },
      children: items
          .map(
            (e) => Center(
              child: Text(
                "$e",
                style: GoogleFonts.dmSans(
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        const StepImage(path: "assets/images/time.png"),
        Text(
          "The date of birth reveals planetary positions at the moment your journey began.",
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            color: isDark
                ? Colors.white54
                : theme.colorScheme.onSurface.withOpacity(0.72),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 150,
          child: Row(
            children: [
              Expanded(
                child: picker(
                  context,
                  months,
                  selectedMonth,
                  (i) => setState(() => selectedMonth = i),
                ),
              ),
              Expanded(
                child: picker(
                  context,
                  days,
                  selectedDay - 1,
                  (i) => setState(() => selectedDay = i + 1),
                ),
              ),
              Expanded(
                child: picker(
                  context,
                  years,
                  selectedYear - 1970,
                  (i) => setState(() => selectedYear = 1970 + i),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
