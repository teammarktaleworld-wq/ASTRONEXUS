import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:open_filex/open_filex.dart';
import 'package:astro_tale/App/Model/order_model.dart';
import 'package:astro_tale/App/controller/Auth_Controller.dart';
import 'package:http/http.dart' as http;

class InvoicePdfService {
  static Future<void> generateInvoice({required OrderModel order}) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    // Load logo
    Uint8List? logoBytes;
    try {
      logoBytes = (await rootBundle.load(
        'assets/images/astrologo.png',
      )).buffer.asUint8List();
    } catch (_) {
      logoBytes = null;
    }
    final logo = logoBytes != null ? pw.MemoryImage(logoBytes) : null;

    // Generate product rows with images
    final productRows = await Future.wait(
      order.items.map((item) async {
        final total = item.price * item.quantity;

        // Load product image
        Uint8List? imageBytes;
        try {
          if ((item.product?.images.isNotEmpty ?? false)) {
            final response = await http.get(
              Uri.parse(item.product!.images.first),
            );
            if (response.statusCode == 200) imageBytes = response.bodyBytes;
          }
        } catch (_) {}

        final pwImage = imageBytes != null ? pw.MemoryImage(imageBytes) : null;

        return pw.TableRow(
          verticalAlignment: pw.TableCellVerticalAlignment.middle,
          children: [
            // Product Image
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pwImage != null
                  ? pw.Container(
                      height: 50,
                      width: 50,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                      ),
                      child: pw.Image(pwImage, fit: pw.BoxFit.cover),
                    )
                  : pw.Text("-", style: const pw.TextStyle(fontSize: 11)),
            ),
            _cell(item.product?.name ?? "Product", bold: true),
            _cell(item.quantity.toString(), alignRight: true),
            _cell("₹${item.price.toStringAsFixed(0)}", alignRight: true),
            _cell("₹${total.toStringAsFixed(0)}", alignRight: true),
          ],
        );
      }).toList(),
    );

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Logo & Store Info
          if (logo != null) pw.Center(child: pw.Image(logo, height: 60)),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              "ASTRONEXUS",
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Center(
            child: pw.Text(
              "Cosmic Guidance & Spiritual Store",
              style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
            ),
          ),
          pw.Divider(thickness: 2, height: 30),

          // Invoice Title
          pw.Text(
            "INVOICE",
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),

          // Order Info
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "Order ID: ${order.id}",
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    "Customer ID: ${AuthController.userId}",
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    "Date: ${dateFormat.format(order.createdAt)}",
                    style: pw.TextStyle(fontSize: 12),
                  ),
                  pw.Text(
                    "Status: ${order.status.toUpperCase()}",
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Divider(thickness: 1),

          // Items Table with Images
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FixedColumnWidth(60),
              1: const pw.FlexColumnWidth(4),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FlexColumnWidth(2),
            },
            children: [
              // Header row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell("Image", bold: true),
                  _cell("Item Description", bold: true),
                  _cell("Qty", bold: true),
                  _cell("Price", bold: true),
                  _cell("Total", bold: true),
                ],
              ),
              ...productRows,
            ],
          ),

          pw.SizedBox(height: 20),

          // Totals
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Container(
              width: 220,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                children: [
                  _totalRow("Subtotal", order.totalAmount),
                  _totalRow("Shipping", 0),
                  pw.Divider(),
                  _totalRow("Grand Total", order.totalAmount, bold: true),
                ],
              ),
            ),
          ),

          pw.SizedBox(height: 30),
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              "Thank you for shopping with AstroNexus!",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              "We hope to see you again soon.",
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
          ),
        ],
      ),
    );

    // Save PDF
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/invoice_${order.id}.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
  }

  // Helper: Table cell
  static pw.Widget _cell(
    String text, {
    bool alignRight = false,
    bool bold = false,
  }) => pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Align(
      alignment: alignRight
          ? pw.Alignment.centerRight
          : pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: 11,
        ),
      ),
    ),
  );

  // Helper: Totals row
  static pw.Widget _totalRow(String title, double value, {bool bold = false}) =>
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: 12,
            ),
          ),
          pw.Text(
            "₹${value.toStringAsFixed(0)}",
            style: pw.TextStyle(
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      );
}
