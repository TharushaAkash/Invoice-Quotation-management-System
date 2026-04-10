import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../services/firebase_service.dart';
import '../services/invoice_service.dart';
import '../services/pdf_service.dart';
import '../services/printer_service.dart';
import '../utils/app_theme.dart';
import '../widgets/invoice_form_dialog.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  late InvoiceService _invoiceService;
  final PdfService _pdfService = PdfService();
  final PrinterService _printerService = PrinterService();
  List<Invoice> _invoices = [];
  bool _isLoading = true;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final firebase = Provider.of<FirebaseService>(context);
      _invoiceService = InvoiceService(firebase);
      _loadInvoices();
      _isInit = false;
    }
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);
    try {
      final invoices = await _invoiceService.getAll();
      setState(() {
        _invoices = invoices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading invoices: $e')),
        );
      }
    }
  }

  Future<void> _showInvoiceDialog(Invoice? invoice) async {
    final result = await showDialog<Invoice>(
      context: context,
      builder: (context) => InvoiceFormDialog(invoice: invoice, invoiceService: _invoiceService),
    );
    if (result != null) {
      _loadInvoices();
    }
  }

  Future<void> _deleteInvoice(Invoice invoice) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text('Are you sure you want to delete this invoice?'),
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

    if (confirm == true && invoice.id != null) {
      try {
        await _invoiceService.delete(invoice.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invoice deleted successfully')),
          );
        }
        _loadInvoices();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting invoice: $e')),
          );
        }
      }
    }
  }
  
  // PDF Printing
  Future<void> _printInvoice(Invoice invoice) async {
    try {
      await _pdfService.printInvoice(invoice);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    }
  }

  // Thermal Printing
  Future<void> _printThermal(Invoice invoice) async {
    bool isConnected = await _printerService.isConnected;
    if (!isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Printer not connected. Go to Printer Settings in the sidebar.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      await _printerService.printInvoice(invoice);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printing to thermal printer...')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error printing: $e')),
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
          // Header
          Container(
            padding: const EdgeInsets.all(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invoices',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showInvoiceDialog(null),
                  icon: const Icon(Icons.add),
                  label: const Text('New Invoice'),
                ),
              ],
            ),
          ),
          // Table
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _invoices.isEmpty
                    ? Center(
                        child: Text(
                          'No invoices found. Create your first invoice!',
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
                                DataColumn(label: Text('Invoice #')),
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Customer')),
                                DataColumn(label: Text('Total')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: _invoices.map((invoice) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(invoice.invoiceNumber)),
                                    DataCell(Text(DateFormat('MMM dd, yyyy').format(invoice.date))),
                                    DataCell(Text(invoice.customerName)),
                                    DataCell(Text('Rs. ${NumberFormat('#,##0.00').format(invoice.total)}')),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(invoice.status).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          invoice.status,
                                          style: TextStyle(
                                            color: _getStatusColor(invoice.status),
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
                                            icon: const Icon(Icons.receipt, size: 20), // Thermal print
                                            onPressed: () => _printThermal(invoice),
                                            color: Colors.blueGrey,
                                            tooltip: 'Thermal Print',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.print, size: 20), // PDF print
                                            onPressed: () => _printInvoice(invoice),
                                            color: AppTheme.primaryColor,
                                            tooltip: 'Print PDF',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20),
                                            onPressed: () => _showInvoiceDialog(invoice),
                                            color: AppTheme.infoColor,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20),
                                            onPressed: () => _deleteInvoice(invoice),
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
      case 'PAID':
        return AppTheme.successColor;
      case 'OVERDUE':
        return AppTheme.dangerColor;
      default:
        return AppTheme.textSecondary;
    }
  }
}
