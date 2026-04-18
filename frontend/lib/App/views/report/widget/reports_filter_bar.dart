import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportsFilterBar extends StatelessWidget {
  final String label;
  final List<String> filters;
  final ValueChanged<String>? onSelected;

  const ReportsFilterBar({
    super.key,
    this.label = "All reports",
    required this.filters,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey iconKey = GlobalKey();

    void _openFilterMenu() async {
      // Get the icon position
      final RenderBox renderBox =
          iconKey.currentContext!.findRenderObject() as RenderBox;
      final Offset offset = renderBox.localToGlobal(Offset.zero);
      final Size size = renderBox.size;

      final chosen = await showMenu<String>(
        context: context,
        position: RelativeRect.fromLTRB(
          offset.dx,
          offset.dy + size.height, // show below the icon
          offset.dx + size.width,
          offset.dy,
        ),
        items: filters
            .map(
              (f) => PopupMenuItem<String>(
                value: f,

                child: Text(
                  f,
                  style: GoogleFonts.dmSans(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            )
            .toList(),
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

      if (chosen != null && onSelected != null) {
        onSelected!(chosen);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black54.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.dmSans(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  key: iconKey, // attach key
                  onTap: _openFilterMenu,
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white10,
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
