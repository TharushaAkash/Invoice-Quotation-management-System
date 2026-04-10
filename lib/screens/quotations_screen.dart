import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart'; // Added for PdfPageFormat
import 'package:printing/printing.dart'; // Added for Printing
import '../models/quotation.dart';
import '../services/firebase_service.dart';
import '../services/quotation_service.dart';
import '../services/pdf_service.dart';
import '../utils/app_theme.dart';
import '../widgets/quotation_form_dialog.dart';

class QuotationsScreen extends StatefulWidget {
  const QuotationsScreen({super.key});

  @override
  State<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends State<QuotationsScreen> {
  late QuotationService _quotationService;
  final PdfService _pdfService = PdfService();
  List<Quotation> _quotations = [];
  bool _isLoading = true;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final firebase = Provider.of<FirebaseService>(context);
      _quotationService = QuotationService(firebase);
      _loadQuotations();
      _isInit = false;
    }
  }

  Future<void> _loadQuotations() async {
    setState(() => _isLoading = true);
    try {
      final quotations = await _quotationService.getAll();
      setState(() {
        _quotations = quotations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quotations: $e')),
        );
      }
    }
  }

  Future<void> _showQuotationDialog(Quotation? quotation) async {
    final result = await showDialog<Quotation>(
      context: context,
      builder: (context) => QuotationFormDialog(quotation: quotation, quotationService: _quotationService),
    );
    if (result != null) {
      _loadQuotations();
    }
  }

  Future<void> _deleteQuotation(Quotation quotation) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quotation'),
        content: const Text('Are you sure you want to delete this quotation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.dangerColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && quotation.id != null) {
      try {
        await _quotationService.delete(quotation.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quotation deleted successfully')),
          );
        }
        _loadQuotations();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting quotation: $e')),
          );
        }
      }
    }
  }

  Future<void> _printQuotation(Quotation quotation) async {
    try {
      await _pdfService.printQuotation(quotation);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    }
  }

  Future<void> _previewQuotation(Quotation quotation) async {
    try {
      final pdfBytes = await _pdfService.generateQuotationPdf(quotation);
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => Dialog(
            insetPadding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Preview: ${quotation.quotationNumber}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PdfPreview(
                    build: (format) => _pdfService.generateQuotationPdf(quotation),
                    initialPageFormat: PdfPageFormat.a4,
                    canDebug: false,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error previewing PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quotations',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showQuotationDialog(null),
                  icon: const Icon(Icons.add),
                  label: const Text('New Quotation'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _quotations.isEmpty
                    ? Center(
                        child: Text(
                          'No quotations found. Create your first quotation!',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      )
                    : Card(
                        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                        child: SingleChildScrollView(
                          child: SizedBox(
                            width: double.infinity,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Quotation #')),
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Valid Until')),
                                DataColumn(label: Text('Customer')),
                                DataColumn(label: Text('Total')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: _quotations.map((quotation) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(quotation.quotationNumber)),
                                    DataCell(Text(DateFormat('MMM dd, yyyy').format(quotation.date))),
                                    DataCell(Text(DateFormat('MMM dd, yyyy').format(quotation.validUntil))),
                                    DataCell(Text(quotation.customerName)),
                                    DataCell(Text('Rs. ${NumberFormat('#,##0.00').format(quotation.total)}')),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(quotation.status).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          quotation.status,
                                          style: TextStyle(
                                            color: _getStatusColor(quotation.status),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility, size: 20), // Preview Button
                                            onPressed: () => _previewQuotation(quotation),
                                            color: Colors.blueGrey,
                                            tooltip: 'Preview',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.print, size: 20),
                                            onPressed: () => _printQuotation(quotation),
                                            color: AppTheme.primaryColor,
                                            tooltip: 'Print Quotation',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20),
                                            onPressed: () => _showQuotationDialog(quotation),
                                            color: AppTheme.infoColor,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20),
                                            onPressed: () => _deleteQuotation(quotation),
                                            color: AppTheme.dangerColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT':
        return AppTheme.warningColor;
      case 'SENT':
        return AppTheme.infoColor;
      case 'ACCEPTED':
        return AppTheme.successColor;
      case 'REJECTED':
        return AppTheme.dangerColor;
      default:
        return AppTheme.textSecondary;
    }
  }
}
