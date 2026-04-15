import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class TarotPdf extends StatefulWidget {
  const TarotPdf({super.key});

  @override
  State<TarotPdf> createState() => _TarotPdfState();
}

class _TarotPdfState extends State<TarotPdf> {
  Future<void> _generatePdf() async {
    try {
      // 1️⃣ Create PDF document
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();
      final Size size = page.getClientSize();

      // 2️⃣ Fonts
      final PdfFont titleFont = PdfStandardFont(
        PdfFontFamily.timesRoman,
        26,
        style: PdfFontStyle.bold,
      );

      final PdfFont subTitleFont = PdfStandardFont(
        PdfFontFamily.helvetica,
        16,
        style: PdfFontStyle.italic,
      );

      final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 13);

      // 3️⃣ Title
      page.graphics.drawString(
        'Tarot Reading Report',
        titleFont,
        bounds: Rect.fromLTWH(0, 30, size.width, 40),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );

      // 4️⃣ Subtitle
      page.graphics.drawString(
        'Your Spiritual Guidance ✨',
        subTitleFont,
        bounds: Rect.fromLTWH(0, 80, size.width, 30),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );

      // 5️⃣ Divider
      page.graphics.drawLine(
        PdfPen(PdfColor(180, 180, 180)),
        Offset(40, 120),
        Offset(size.width - 40, 120),
      );

      // 6️⃣ Body Content
      page.graphics.drawString(
        '''
🃏 Card Drawn: The Lovers

Meaning:
The Lovers card symbolizes harmony, emotional balance, and deep relationships.
It represents meaningful choices guided by love and values.

Guidance:
Follow your heart while staying aligned with your principles.
Trust the energy of unity and connection in your journey.
''',
        bodyFont,
        bounds: Rect.fromLTWH(40, 140, size.width - 80, size.height - 200),
      );

      // 7️⃣ Save PDF
      final List<int> bytes = document.saveSync();
      document.dispose();

      // 8️⃣ Store PDF
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/tarot_reading.pdf';

      final File file = File(path);
      await file.writeAsBytes(bytes, flush: true);

      // 9️⃣ Open PDF automatically
      await OpenFilex.open(path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F0E0E),
      appBar: AppBar(
        title: const Text("Tarot PDF"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: _generatePdf,
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("Generate Tarot PDF"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffDBC33F),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
