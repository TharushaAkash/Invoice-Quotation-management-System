import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Use standard widget PDF generation
import 'package:printing/printing.dart';
import '../utils/app_theme.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPrinter();
  }

  Future<void> _loadPrinter() async {
    setState(() => _isLoading = true);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Printer Settings (Windows)',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.print, size: 30, color: AppTheme.primaryColor),
                        SizedBox(width: 15),
                        Text(
                          'Windows System Printing',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'On Windows, this application uses the installed system printers.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'To use your Bluetooth Thermal Printer:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text('1. Go to Windows Settings -> Bluetooth & devices -> Printers & scanners.'),
                    const Text('2. Add your Bluetooth printer device.'),
                    const Text('3. When you click "Print" in the app, simply select that printer from the dialog.'),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Test print using standard PDF widgets instead of HTML
                        final doc = pw.Document();
                        doc.addPage(
                          pw.Page(
                            pageFormat: PdfPageFormat.roll80,
                            build: (pw.Context context) {
                              return pw.Center(
                                child: pw.Column(
                                  mainAxisSize: pw.MainAxisSize.min,
                                  children: [
                                    pw.Text('Test Print', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                                    pw.SizedBox(height: 10),
                                    pw.Text('If you can read this, your printer is working!', textAlign: pw.TextAlign.center),
                                  ],
                                ),
                              );
                            },
                          ),
                        );

                        await Printing.layoutPdf(
                          onLayout: (format) async => doc.save(),
                          name: 'Test Print',
                        );
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('Test Print System Dialog'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
