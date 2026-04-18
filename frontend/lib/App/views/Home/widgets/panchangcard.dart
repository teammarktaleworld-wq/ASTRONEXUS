import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vedic_panchanga_dart/vedic_panchanga_dart.dart';
import 'package:intl/intl.dart';

/// -------------------- PANCHANGA CARD --------------------
class PanchangaCard extends StatelessWidget {
  final PanchangaData panchanga;

  const PanchangaCard({required this.panchanga, super.key});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a'); // Format for sunrise/sunset

    String formatHours(double hours) {
      final h = hours.floor();
      final m = ((hours - h) * 60).floor();
      return '${h}h ${m}m';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF14162E),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Panchanga Details",
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _PanchangaRow("Date", DateFormat.yMMMMd().format(panchanga.date)),
          _PanchangaRow("Weekday", panchanga.weekday),
          _PanchangaRow("Tithi", panchanga.tithi.name),
          _PanchangaRow(
            "Nakshatra",
            "${panchanga.nakshatra.name} Pada ${panchanga.nakshatra.pada}",
          ),
          _PanchangaRow("Yoga", panchanga.yoga.name),
          _PanchangaRow("Karana", panchanga.karana.name),
          _PanchangaRow("Moon Rasi", panchanga.moonRasi.name),
          _PanchangaRow(
            "Sunrise",
            timeFormat.format(
              panchanga.sunriseString.isNotEmpty
                  ? panchanga.date.add(
                      Duration(
                        hours: int.parse(panchanga.sunriseString.split(':')[0]),
                      ),
                    )
                  : panchanga.date,
            ),
          ),
          _PanchangaRow(
            "Sunset",
            timeFormat.format(
              panchanga.date.add(Duration(hours: panchanga.sunsetTime.floor())),
            ),
          ),
          _PanchangaRow(
            "Moonrise",
            timeFormat.format(
              panchanga.date.add(
                Duration(hours: panchanga.moonriseTime.floor()),
              ),
            ),
          ),
          _PanchangaRow(
            "Moonset",
            timeFormat.format(
              panchanga.date.add(
                Duration(hours: panchanga.moonsetTime.floor()),
              ),
            ),
          ),
          _PanchangaRow("Day Length", formatHours(panchanga.dayLength)),
          _PanchangaRow("Night Length", formatHours(panchanga.nightLength)),
        ],
      ),
    );
  }
}

/// -------------------- PANCHANGA ROW --------------------
class _PanchangaRow extends StatelessWidget {
  final String title;
  final String value;

  const _PanchangaRow(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: GoogleFonts.dmSans(
              color: Colors.amberAccent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
