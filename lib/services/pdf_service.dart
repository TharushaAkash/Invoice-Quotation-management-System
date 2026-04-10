import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/invoice.dart';
import '../models/quotation.dart';

class PdfService {
  // Modern Professional Colors
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF2563EB); // Modern Blue
  static const PdfColor secondaryColor = PdfColor.fromInt(0xFF1E293B); // Slate 800
  static const PdfColor accentColor = PdfColor.fromInt(0xFFF1F5F9); // Slate 100
  static const PdfColor textColor = PdfColor.fromInt(0xFF334155); // Slate 700
  static const PdfColor lightGrey = PdfColor.fromInt(0xFF94A3B8); // Slate 400

  Future<Uint8List?> _getLogo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString('business_logo_path');
      if (path != null && File(path).existsSync()) {
        return File(path).readAsBytesSync();
      }
    } catch (e) {
      // Ignore error, return null
    }
    return null;
  }

  Future<Uint8List> generateInvoicePdf(Invoice invoice) async {
    final pdf = pw.Document();
    final fontRegular = await PdfGoogleFonts.notoSansSinhalaRegular();
    final fontBold = await PdfGoogleFonts.notoSansSinhalaBold();
    
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('business_phone');
    final email = prefs.getString('business_email');
    
    final logoBytes = await _getLogo();
    final logoImage = logoBytes != null ? pw.MemoryImage(logoBytes) : null;
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return pw.FittedBox(
            child: pw.Container(
              width: PdfPageFormat.a4.width,
              padding: const pw.EdgeInsets.all(30),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInvoiceHeader(invoice, logoImage, phone, email),
                  pw.SizedBox(height: 20),
                  ..._buildInvoiceBody(invoice),
                  _buildInvoiceFooter(),
                ],
              ),
            ),
          );
        },
      ),
    );
    return pdf.save();
  }

  Future<Uint8List> generateQuotationPdf(Quotation quotation) async {
    final pdf = pw.Document();
    final fontRegular = await PdfGoogleFonts.notoSansSinhalaRegular();
    final fontBold = await PdfGoogleFonts.notoSansSinhalaBold();
    
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('business_phone');
    final email = prefs.getString('business_email');
    
    final logoBytes = await _getLogo();
    final logoImage = logoBytes != null ? pw.MemoryImage(logoBytes) : null;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return pw.FittedBox(
            child: pw.Container(
              width: PdfPageFormat.a4.width,
              padding: const pw.EdgeInsets.all(30),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildQuotationHeader(quotation, logoImage, phone, email),
                  pw.SizedBox(height: 20),
                  ..._buildQuotationBody(quotation),
                  _buildQuotationFooter(quotation),
                ],
              ),
            ),
          );
        },
      ),
    );
    return pdf.save();
  }

  pw.Widget _buildInvoiceHeader(Invoice invoice, pw.MemoryImage? logoImage, String? phone, String? email) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 80,
              height: 80,
              child: logoImage != null
                  ? pw.Image(logoImage, fit: pw.BoxFit.contain)
                  : pw.Container(
                      decoration: const pw.BoxDecoration(
                        color: primaryColor,
                        borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
                      ),
                      child: pw.Center(
                        child: pw.Text('E', style: pw.TextStyle(color: PdfColors.white, fontSize: 30, fontWeight: pw.FontWeight.bold)),
                      ),
                    ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('ඊ-Tech Electricals', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: secondaryColor)),
            pw.Text('112, P.S.Perera Mawatha, Mampe, Piliyandala.', style: const pw.TextStyle(fontSize: 10, color: textColor)),
            if (phone != null && phone.isNotEmpty)
              pw.Text('Tel: $phone', style: const pw.TextStyle(fontSize: 10, color: textColor)),
            if (email != null && email.isNotEmpty)
              pw.Text('Email: $email', style: const pw.TextStyle(fontSize: 10, color: textColor)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('INVOICE', style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold, color: lightGrey)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('Invoice No:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: secondaryColor)),
                pw.SizedBox(width: 10),
                pw.Text(invoice.invoiceNumber, style: const pw.TextStyle(color: textColor)),
              ],
            ),
            pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('Date:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: secondaryColor)),
                pw.SizedBox(width: 10),
                pw.Text(DateFormat('MMM dd, yyyy').format(invoice.date), style: const pw.TextStyle(color: textColor)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  List<pw.Widget> _buildInvoiceBody(Invoice invoice) {
    return [
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(20),
        decoration: const pw.BoxDecoration(
          color: accentColor,
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Bill To:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: lightGrey)),
            pw.SizedBox(height: 5),
            pw.Text(invoice.customerName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: secondaryColor)),
            if (invoice.customerAddress != null)
              pw.Text(invoice.customerAddress!, style: const pw.TextStyle(color: textColor)),
            if (invoice.customerPhone != null)
              pw.Text(invoice.customerPhone!, style: const pw.TextStyle(color: textColor)),
          ],
        ),
      ),
      pw.SizedBox(height: 30),
      pw.Table(
        columnWidths: {
          0: const pw.FlexColumnWidth(4),
          1: const pw.FlexColumnWidth(1),
          2: const pw.FlexColumnWidth(2),
          3: const pw.FlexColumnWidth(2),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: primaryColor, width: 2)),
            ),
            children: [
              pw.Padding(padding: const pw.EdgeInsets.only(bottom: 10), child: pw.Text('Item Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor))),
              pw.Padding(padding: const pw.EdgeInsets.only(bottom: 10), child: pw.Text('Qty', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor))),
              pw.Padding(padding: const pw.EdgeInsets.only(bottom: 10), child: pw.Text('Unit Price', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor))),
              pw.Padding(padding: const pw.EdgeInsets.only(bottom: 10), child: pw.Text('Total', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor))),
            ],
          ),
          pw.TableRow(children: [pw.SizedBox(height: 10), pw.SizedBox(height: 10), pw.SizedBox(height: 10), pw.SizedBox(height: 10)]),
          ...invoice.items.map((item) => pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(item.itemName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: secondaryColor)),
                    if (item.description != null && item.description!.isNotEmpty)
                      pw.Text(item.description!, style: const pw.TextStyle(fontSize: 9, color: lightGrey)),
                  ],
                )
              ),
              pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8), child: pw.Text(item.quantity.toString(), textAlign: pw.TextAlign.center, style: const pw.TextStyle(color: textColor))),
              pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8), child: pw.Text(NumberFormat('#,##0.00').format(item.unitPrice), textAlign: pw.TextAlign.right, style: const pw.TextStyle(color: textColor))),
              pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8), child: pw.Text(NumberFormat('#,##0.00').format(item.total), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: secondaryColor))),
            ],
          )),
        ],
      ),
      pw.Divider(color: lightGrey, thickness: 0.5),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Container(
            width: 250,
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Subtotal:', style: const pw.TextStyle(color: textColor)),
                    pw.Text(NumberFormat('#,##0.00').format(invoice.subtotal), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: secondaryColor)),
                  ],
                ),
                if (invoice.taxRate > 0) ...[
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Tax (${invoice.taxRate}%):', style: const pw.TextStyle(color: textColor)),
                      pw.Text(NumberFormat('#,##0.00').format(invoice.taxAmount), style: const pw.TextStyle(color: textColor)),
                    ],
                  ),
                ],
                if (invoice.advance > 0) ...[
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Advance:', style: const pw.TextStyle(color: textColor)),
                      pw.Text(NumberFormat('#,##0.00').format(invoice.advance), style: const pw.TextStyle(color: textColor)),
                    ],
                  ),
                ],
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: const pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                      pw.Text('Rs. ${NumberFormat('#,##0.00').format(invoice.total)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  pw.Widget _buildInvoiceFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Payment Info:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: secondaryColor)),
            pw.SizedBox(height: 5),
            pw.Text('Bank: HNB Bank', style: const pw.TextStyle(fontSize: 10, color: textColor)),
            pw.Text('Account: 038020008423', style: const pw.TextStyle(fontSize: 10, color: textColor)),
            pw.Text('Name: N.A. Withanage', style: const pw.TextStyle(fontSize: 10, color: textColor)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Thank you for your business!', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic, color: primaryColor)),
            pw.SizedBox(height: 20),
            pw.Container(height: 1, width: 150, color: lightGrey),
            pw.SizedBox(height: 5),
            pw.Text('Authorized Signature', style: const pw.TextStyle(fontSize: 8, color: lightGrey)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildQuotationHeader(Quotation quotation, pw.MemoryImage? logoImage, String? phone, String? email) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 80,
              height: 80,
              child: logoImage != null
                  ? pw.Image(logoImage, fit: pw.BoxFit.contain)
                  : pw.Container(
                      decoration: const pw.BoxDecoration(
                        color: primaryColor,
                        borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
                      ),
                      child: pw.Center(
                        child: pw.Text('E', style: pw.TextStyle(color: PdfColors.white, fontSize: 30, fontWeight: pw.FontWeight.bold)),
                      ),
                    ),
            ),
            pw.SizedBox(height: 10),
            pw.Text('ඊ-Tech Electricals', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: secondaryColor)),
            pw.Text('112, P.S.Perera Mawatha, Mampe, Piliyandala.', style: const pw.TextStyle(fontSize: 10, color: textColor)),
            if (phone != null && phone.isNotEmpty)
              pw.Text('Tel: $phone', style: const pw.TextStyle(fontSize: 10, color: textColor)),
            if (email != null && email.isNotEmpty)
              pw.Text('Email: $email', style: const pw.TextStyle(fontSize: 10, color: textColor)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('QUOTATION', style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold, color: lightGrey)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('Quotation No:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: secondaryColor)),
                pw.SizedBox(width: 10),
                pw.Text(quotation.quotationNumber, style: const pw.TextStyle(color: textColor)),
              ],
            ),
            pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('Date:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: secondaryColor)),
                pw.SizedBox(width: 10),
                pw.Text(DateFormat('MMM dd, yyyy').format(quotation.date), style: const pw.TextStyle(color: textColor)),
              ],
            ),
            pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('Valid Until:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: secondaryColor)),
                pw.SizedBox(width: 10),
                pw.Text(DateFormat('MMM dd, yyyy').format(quotation.validUntil), style: const pw.TextStyle(color: textColor)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  List<pw.Widget> _buildQuotationBody(Quotation quotation) {
    return [
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.all(20),
        decoration: const pw.BoxDecoration(
          color: accentColor,
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Quotation For:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: lightGrey)),
            pw.SizedBox(height: 5),
            pw.Text(quotation.customerName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: secondaryColor)),
            if (quotation.customerAddress != null)
              pw.Text(quotation.customerAddress!, style: const pw.TextStyle(color: textColor)),
            if (quotation.customerPhone != null)
              pw.Text(quotation.customerPhone!, style: const pw.TextStyle(color: textColor)),
          ],
        ),
      ),
      pw.SizedBox(height: 30),
      pw.Table(
        columnWidths: {
          0: const pw.FlexColumnWidth(4),
          1: const pw.FlexColumnWidth(1),
          2: const pw.FlexColumnWidth(2),
          3: const pw.FlexColumnWidth(2),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: primaryColor, width: 2)),
            ),
            children: [
              pw.Padding(padding: const pw.EdgeInsets.only(bottom: 10), child: pw.Text('Item Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor))),
              pw.Padding(padding: const pw.EdgeInsets.only(bottom: 10), child: pw.Text('Qty', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor))),
              pw.Padding(padding: const pw.EdgeInsets.only(bottom: 10), child: pw.Text('Unit Price', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor))),
              pw.Padding(padding: const pw.EdgeInsets.only(bottom: 10), child: pw.Text('Total', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor))),
            ],
          ),
          pw.TableRow(children: [pw.SizedBox(height: 10), pw.SizedBox(height: 10), pw.SizedBox(height: 10), pw.SizedBox(height: 10)]),
          ...quotation.items.map((item) => pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(item.itemName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: secondaryColor)),
                    if (item.description != null && item.description!.isNotEmpty)
                      pw.Text(item.description!, style: const pw.TextStyle(fontSize: 9, color: lightGrey)),
                  ],
                )
              ),
              pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8), child: pw.Text(item.quantity.toString(), textAlign: pw.TextAlign.center, style: const pw.TextStyle(color: textColor))),
              pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8), child: pw.Text(NumberFormat('#,##0.00').format(item.unitPrice), textAlign: pw.TextAlign.right, style: const pw.TextStyle(color: textColor))),
              pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 8), child: pw.Text(NumberFormat('#,##0.00').format(item.total), textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: secondaryColor))),
            ],
          )),
        ],
      ),
      pw.Divider(color: lightGrey, thickness: 0.5),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Container(
            width: 250,
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Subtotal:', style: const pw.TextStyle(color: textColor)),
                    pw.Text(NumberFormat('#,##0.00').format(quotation.subtotal), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: secondaryColor)),
                  ],
                ),
                if (quotation.taxRate > 0) ...[
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Tax (${quotation.taxRate}%):', style: const pw.TextStyle(color: textColor)),
                      pw.Text(NumberFormat('#,##0.00').format(quotation.taxAmount), style: const pw.TextStyle(color: textColor)),
                    ],
                  ),
                ],
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: const pw.BoxDecoration(
                    color: primaryColor,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                      pw.Text('Rs. ${NumberFormat('#,##0.00').format(quotation.total)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  pw.Widget _buildQuotationFooter(Quotation quotation) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (quotation.notes != null && quotation.notes!.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 20),
            child: pw.Text(quotation.notes!, style: const pw.TextStyle(fontSize: 10, color: textColor, fontStyle: pw.FontStyle.italic)),
          ),
        pw.Text('Thank you for your inquiry!', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primaryColor)),
        pw.SizedBox(height: 10),
        pw.Text('This quotation is valid until ${DateFormat('yyyy-MM-dd').format(quotation.validUntil)}', style: const pw.TextStyle(fontSize: 8, color: lightGrey)),
      ],
    );
  }

  Future<void> printInvoice(Invoice invoice) async {
    final pdfBytes = await generateInvoicePdf(invoice);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Invoice-${invoice.invoiceNumber}',
    );
  }

  Future<void> printQuotation(Quotation quotation) async {
    final pdfBytes = await generateQuotationPdf(quotation);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Quotation-${quotation.quotationNumber}',
    );
  }
}
