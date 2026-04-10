import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../models/inventory_item.dart';
import '../models/income.dart';
import '../services/invoice_service.dart';
import '../services/inventory_service.dart';
import '../services/firebase_service.dart';
import '../services/income_service.dart';
import '../utils/app_theme.dart';

class InvoiceFormDialog extends StatefulWidget {
  final Invoice? invoice;
  final InvoiceService invoiceService;

  const InvoiceFormDialog({
    super.key,
    this.invoice,
    required this.invoiceService,
  });

  @override
  State<InvoiceFormDialog> createState() => _InvoiceFormDialogState();
}

class _InvoiceFormDialogState extends State<InvoiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _invoiceNumberController;
  late TextEditingController _customerNameController;
  late TextEditingController _customerAddressController;
  late TextEditingController _customerPhoneController;
  late TextEditingController _taxRateController;
  late TextEditingController _advanceController;
  late TextEditingController _notesController;
  
  // Inventory
  late InventoryService _inventoryService;
  late IncomeService _incomeService;
  List<InventoryItem> _inventoryItems = [];
  bool _loadingInventory = false;

  // Items list
  final List<InvoiceItem> _items = [];

  DateTime _selectedDate = DateTime.now();
  String _status = 'DRAFT';
  String _originalStatus = 'DRAFT';
  bool _isLoading = false;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    final invoice = widget.invoice;
    _invoiceNumberController = TextEditingController(text: invoice?.invoiceNumber ?? '');
    _customerNameController = TextEditingController(text: invoice?.customerName ?? '');
    _customerAddressController = TextEditingController(text: invoice?.customerAddress ?? '');
    _customerPhoneController = TextEditingController(text: invoice?.customerPhone ?? '');
    _taxRateController = TextEditingController(text: (invoice?.taxRate ?? 0.0).toString());
    _advanceController = TextEditingController(text: (invoice?.advance ?? 0.0).toString());
    _notesController = TextEditingController(text: invoice?.notes ?? '');
    _selectedDate = invoice?.date ?? DateTime.now();
    _status = invoice?.status ?? 'DRAFT';
    _originalStatus = invoice?.status ?? 'DRAFT';

    // Initialize items
    if (invoice != null && invoice.items.isNotEmpty) {
      _items.addAll(invoice.items);
    } else if (_items.isEmpty) {
      // Add one empty item by default
      _addItem();
    }

    if (invoice == null) {
      _generateInvoiceNumber();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final firebase = Provider.of<FirebaseService>(context, listen: false);
      _inventoryService = InventoryService(firebase);
      _incomeService = IncomeService(firebase);
      _loadInventory();
      _isInit = false;
    }
  }

  Future<void> _loadInventory() async {
    setState(() => _loadingInventory = true);
    try {
      final items = await _inventoryService.getAll();
      setState(() {
        _inventoryItems = items;
        _loadingInventory = false;
      });
    } catch (e) {
      setState(() => _loadingInventory = false);
      debugPrint('Error loading inventory: $e');
    }
  }

  Future<void> _generateInvoiceNumber() async {
    try {
      final number = await widget.invoiceService.generateInvoiceNumber();
      _invoiceNumberController.text = number;
    } catch (e) {
      debugPrint('Error generating invoice number: $e');
    }
  }

  void _addItem() {
    setState(() {
      _items.add(InvoiceItem(
        itemName: '',
        quantity: 1,
        unitPrice: 0.0,
      ));
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  double get _calculateSubtotal {
    return _items.fold(0.0, (sum, item) => sum + (item.quantity * item.unitPrice));
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate items
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final invoice = Invoice(
        id: widget.invoice?.id,
        invoiceNumber: _invoiceNumberController.text,
        date: _selectedDate,
        customerName: _customerNameController.text,
        customerAddress: _customerAddressController.text.isEmpty ? null : _customerAddressController.text,
        customerPhone: _customerPhoneController.text.isEmpty ? null : _customerPhoneController.text,
        taxRate: double.tryParse(_taxRateController.text) ?? 0.0,
        advance: double.tryParse(_advanceController.text) ?? 0.0,
        status: _status,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        dueDate: null,
        items: _items,
      )..calculateTotals();

      String? invoiceId;
      if (widget.invoice?.id != null) {
        await widget.invoiceService.update(invoice);
        invoiceId = invoice.id;
      } else {
        invoiceId = await widget.invoiceService.create(invoice);
        // Create returns the ID
        invoice.id = invoiceId;
      }

      // Auto-create Income if status changed to PAID
      if (_status == 'PAID' && _originalStatus != 'PAID') {
        final income = Income(
          date: DateTime.now(),
          source: 'Invoice Payment',
          description: 'Payment for Invoice #${invoice.invoiceNumber}',
          amount: invoice.total,
          paymentMethod: 'CASH', // Default
          customerName: invoice.customerName,
          invoiceId: invoiceId,
          notes: 'Auto-generated from invoice',
        );
        await _incomeService.create(income);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Income record created automatically!')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, invoice);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.invoice == null
                ? 'Invoice created successfully!'
                : 'Invoice updated successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving invoice: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _customerPhoneController.dispose();
    _taxRateController.dispose();
    _advanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 900,
        height: 800,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.invoice == null ? 'New Invoice' : 'Edit Invoice',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Section: Invoice Info
                      _buildSectionTitle(context, 'Invoice Info'),
                      Card(
                        elevation: 0,
                        color: Colors.grey[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      controller: _invoiceNumberController,
                                      decoration: const InputDecoration(
                                        labelText: 'Invoice Number',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                      ),
                                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                                    ),
                                    const SizedBox(height: 16),
                                    InkWell(
                                      onTap: () => _selectDate(context),
                                      child: InputDecorator(
                                        decoration: const InputDecoration(
                                          labelText: 'Date',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                          suffixIcon: Icon(Icons.calendar_today, size: 20),
                                        ),
                                        child: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  children: [
                                    DropdownButtonFormField<String>(
                                      value: _status,
                                      decoration: const InputDecoration(
                                        labelText: 'Status',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'DRAFT', child: Text('Draft')),
                                        DropdownMenuItem(value: 'SENT', child: Text('Sent')),
                                        DropdownMenuItem(value: 'PAID', child: Text('Paid')),
                                        DropdownMenuItem(value: 'OVERDUE', child: Text('Overdue')),
                                      ],
                                      onChanged: (value) => setState(() => _status = value ?? 'DRAFT'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Customer Details'),
                      Card(
                        elevation: 0,
                        color: Colors.grey[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _customerNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Customer Name',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.person_outline),
                                      ),
                                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _customerPhoneController,
                                      decoration: const InputDecoration(
                                        labelText: 'Phone Number',
                                        border: OutlineInputBorder(),
                                        prefixIcon: Icon(Icons.phone_outlined),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _customerAddressController,
                                decoration: const InputDecoration(
                                  labelText: 'Address',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.location_on_outlined),
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle(context, 'Items'),
                          ElevatedButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Item'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Items Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Expanded(flex: 4, child: Text('Item / Description', style: TextStyle(fontWeight: FontWeight.bold))),
                            const SizedBox(width: 12),
                            const Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                            const SizedBox(width: 12),
                            const Expanded(flex: 2, child: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                            const SizedBox(width: 12),
                            SizedBox(width: 100, child: const Text('Total', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                            const SizedBox(width: 48), // Space for delete icon
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Items List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return _InvoiceItemRow(
                            key: ObjectKey(item),
                            item: item,
                            inventoryItems: _inventoryItems,
                            onRemove: () => _removeItem(index),
                            onUpdate: () => setState(() {}),
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                      
                      // Bottom Section: Notes & Totals
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(context, 'Notes'),
                                TextFormField(
                                  controller: _notesController,
                                  decoration: const InputDecoration(
                                    hintText: 'Add payment instructions or additional notes here...',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 40),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
                              ),
                              child: Column(
                                children: [
                                  _buildTotalRow('Subtotal', _calculateSubtotal),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Tax Rate (%)'),
                                      SizedBox(
                                        width: 80,
                                        child: TextFormField(
                                          controller: _taxRateController,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            isDense: true,
                                          ),
                                          textAlign: TextAlign.right,
                                          keyboardType: TextInputType.number,
                                          onChanged: (_) => setState(() {}),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _buildTotalRow(
                                    'Tax Amount', 
                                    _calculateSubtotal * ((double.tryParse(_taxRateController.text) ?? 0) / 100)
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Advance'),
                                      SizedBox(
                                        width: 80,
                                        child: TextFormField(
                                          controller: _advanceController,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            isDense: true,
                                          ),
                                          textAlign: TextAlign.right,
                                          keyboardType: TextInputType.number,
                                          onChanged: (_) => setState(() {}),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(thickness: 2),
                                  _buildTotalRow(
                                    'Total', 
                                    _calculateSubtotal * (1 + (double.tryParse(_taxRateController.text) ?? 0) / 100) - (double.tryParse(_advanceController.text) ?? 0),
                                    isBold: true,
                                    color: AppTheme.primaryColor,
                                    fontSize: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Footer
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    icon: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                    label: const Text('Save Invoice', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double value, {bool isBold = false, Color? color, double? fontSize}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
              color: color,
            ),
          ),
          Text(
            NumberFormat.currency(symbol: 'Rs. ').format(value),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceItemRow extends StatefulWidget {
  final InvoiceItem item;
  final List<InventoryItem> inventoryItems;
  final VoidCallback onRemove;
  final VoidCallback onUpdate;

  const _InvoiceItemRow({
    required Key key,
    required this.item,
    required this.inventoryItems,
    required this.onRemove,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<_InvoiceItemRow> createState() => _InvoiceItemRowState();
}

class _InvoiceItemRowState extends State<_InvoiceItemRow> {
  late TextEditingController _qtyController;
  late TextEditingController _priceController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: widget.item.quantity.toString());
    _priceController = TextEditingController(text: widget.item.unitPrice.toString());
    _descController = TextEditingController(text: widget.item.description ?? '');
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Autocomplete<InventoryItem>(
                  initialValue: TextEditingValue(text: widget.item.itemName),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<InventoryItem>.empty();
                    }
                    return widget.inventoryItems.where((InventoryItem option) {
                      return option.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  displayStringForOption: (InventoryItem option) => option.name,
                  onSelected: (InventoryItem selection) {
                    widget.item.itemName = selection.name;
                    widget.item.unitPrice = selection.sellingPrice;
                    if (selection.description != null) {
                      widget.item.description = selection.description;
                      _descController.text = selection.description!;
                    }
                    _priceController.text = widget.item.unitPrice.toString();
                    
                    widget.onUpdate();
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Search item...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                      onChanged: (val) {
                         widget.item.itemName = val;
                      },
                    );
                  },
                ),
                const Divider(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    hintText: 'Description (Optional)',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  onChanged: (val) => widget.item.description = val,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: TextFormField(
              controller: _qtyController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (val) {
                widget.item.quantity = int.tryParse(val) ?? 0;
                widget.onUpdate();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                prefixText: 'Rs. ',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                widget.item.unitPrice = double.tryParse(val) ?? 0.0;
                widget.onUpdate();
              },
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 100,
            padding: const EdgeInsets.only(top: 10),
            alignment: Alignment.topRight,
            child: Text(
              NumberFormat('#,##0.00').format(widget.item.quantity * widget.item.unitPrice),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: widget.onRemove,
          ),
        ],
      ),
    );
  }
}
