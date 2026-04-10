import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice.dart';

class PrinterService {
  // On Windows, we use the system printing dialog.
  
  // 5.5 inches is approx 140mm. 
  // We reduce width slightly (130mm) to ensure it fits within hardware printable area.
  static const PdfPageFormat format5_5Inch = PdfPageFormat(
    130 * PdfPageFormat.mm, 
    double.infinity, 
    marginAll: 2 * PdfPageFormat.mm // Small margin
  );

  Future<void> printInvoice(Invoice invoice) async {
    try {
      // Load fonts to ensure Unicode characters (like currency symbols) render correctly.
      // Using Roboto (standard Sans) which has good coverage.
      // Fallback to default if loading fails.
      pw.Font font;
      pw.Font fontBold;
      
      try {
        font = await PdfGoogleFonts.robotoRegular();
        fontBold = await PdfGoogleFonts.robotoBold();
      } catch (e) {
        // If offline or error, fallback to standard (might have unicode issues)
        font = pw.Font.helvetica();
        fontBold = pw.Font.helveticaBold();
        debugPrint("Error loading Google Fonts: $e");
      }

      final doc = pw.Document();

      doc.addPage(
        pw.Page(
          pageFormat: format5_5Inch,
          theme: pw.ThemeData.withFont(
            base: font,
            bold: fontBold,
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text("ඊ-Tech Electricals", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text("112, P.S.Perera Mawatha, Mampe, Piliyandala", textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 10)),
                      pw.Text("Tel: 071 234 5678", style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                pw.Divider(),
                
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Text("Invoice: ${invoice.invoiceNumber}", style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(DateFormat('yyyy/MM/dd').format(invoice.date), style: const pw.TextStyle(fontSize: 10)),
                ]),
                pw.Text("Customer: ${invoice.customerName}", style: const pw.TextStyle(fontSize: 10)),
                
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                
                // Items Table
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(4), // Item
                    1: const pw.FlexColumnWidth(2), // Price
                    2: const pw.FlexColumnWidth(1), // Qty
                    3: const pw.FlexColumnWidth(2), // Total
                  },
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Text("Item", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text("Price", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                        pw.Text("Qty", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                        pw.Text("Total", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ]
                    ),
                    ...invoice.items.map((item) => pw.TableRow(
                      children: [
                        pw.Text(item.itemName, style: const pw.TextStyle(fontSize: 10)),
                        pw.Text(NumberFormat('#,##0').format(item.unitPrice), style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
                        pw.Text(item.quantity.toString(), style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center),
                        pw.Text(NumberFormat('#,##0').format(item.unitPrice * item.quantity), style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
                      ]
                    )),
                  ]
                ),
                
                pw.Divider(borderStyle: pw.BorderStyle.dashed),
                
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Text("Subtotal:", style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(NumberFormat('#,##0.00').format(invoice.subtotal), style: const pw.TextStyle(fontSize: 10)),
                ]),
                
                if (invoice.taxRate > 0)
                  pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                    pw.Text("Tax (${invoice.taxRate}%):", style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(NumberFormat('#,##0.00').format(invoice.subtotal * invoice.taxRate / 100), style: const pw.TextStyle(fontSize: 10)),
                  ]),

                pw.Divider(),
                
                pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                  pw.Text("TOTAL", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Rs. ${NumberFormat('#,##0.00').format(invoice.total)}", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ]),
                
                pw.SizedBox(height: 20),
                pw.Center(child: pw.Text("Thank You!", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
              ],
            );
          },
        ),
      );

      // Use Printing.layoutPdf which opens the native print dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: 'Invoice-${invoice.invoiceNumber}',
        usePrinterSettings: true, // Important for Windows to use system settings
      );
    } catch (e) {
      debugPrint('Print Error: $e');
    }
  }

  Future<bool> get isConnected async => true; // Always "connected" on Windows as we use system dialog
}
