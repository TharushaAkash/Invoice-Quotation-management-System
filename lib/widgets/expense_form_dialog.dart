import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../utils/app_theme.dart';

class ExpenseFormDialog extends StatefulWidget {
  final Expense? expense;
  final ExpenseService expenseService;

  const ExpenseFormDialog({
    super.key,
    this.expense,
    required this.expenseService,
  });

  @override
  State<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _categoryController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _vendorController;
  late TextEditingController _receiptNumberController;
  late TextEditingController _notesController;
  
  DateTime _selectedDate = DateTime.now();
  String _paymentMethod = 'CASH';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _categoryController = TextEditingController(text: expense?.category ?? '');
    _descriptionController = TextEditingController(text: expense?.description ?? '');
    _amountController = TextEditingController(text: (expense?.amount ?? 0.0).toString());
    _vendorController = TextEditingController(text: expense?.vendor ?? '');
    _receiptNumberController = TextEditingController(text: expense?.receiptNumber ?? '');
    _notesController = TextEditingController(text: expense?.notes ?? '');
    _selectedDate = expense?.date ?? DateTime.now();
    _paymentMethod = expense?.paymentMethod ?? 'CASH';
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

    setState(() => _isLoading = true);

    try {
      final expense = Expense(
        id: widget.expense?.id,
        date: _selectedDate,
        category: _categoryController.text,
        description: _descriptionController.text,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        paymentMethod: _paymentMethod,
        vendor: _vendorController.text.isEmpty ? null : _vendorController.text,
        receiptNumber: _receiptNumberController.text.isEmpty ? null : _receiptNumberController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (widget.expense?.id != null) {
        await widget.expenseService.update(expense);
      } else {
        await widget.expenseService.create(expense);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.expense == null
                ? 'Expense created successfully!'
                : 'Expense updated successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving expense: $e')),
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
    _categoryController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _vendorController.dispose();
    _receiptNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.expense == null ? 'New Expense' : 'Edit Expense',
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
                      _buildSectionTitle(context, 'Transaction Details'),
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
                                    child: InkWell(
                                      onTap: () => _selectDate(context),
                                      child: InputDecorator(
                                        decoration: const InputDecoration(
                                          labelText: 'Date',
                                          border: OutlineInputBorder(),
                                          suffixIcon: Icon(Icons.calendar_today),
                                        ),
                                        child: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _amountController,
                                      decoration: const InputDecoration(
                                        labelText: 'Amount (Rs.)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _categoryController,
                                      decoration: const InputDecoration(
                                        labelText: 'Category',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _paymentMethod,
                                      decoration: const InputDecoration(
                                        labelText: 'Payment Method',
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                                        DropdownMenuItem(value: 'BANK_TRANSFER', child: Text('Bank Transfer')),
                                        DropdownMenuItem(value: 'CARD', child: Text('Card')),
                                      ],
                                      onChanged: (v) => setState(() => _paymentMethod = v ?? 'CASH'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Additional Info'),
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
                                      controller: _vendorController,
                                      decoration: const InputDecoration(
                                        labelText: 'Vendor',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _receiptNumberController,
                                      decoration: const InputDecoration(
                                        labelText: 'Receipt #',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _notesController,
                                decoration: const InputDecoration(
                                  labelText: 'Notes',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
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
                    label: const Text('Save Expense', style: TextStyle(fontSize: 16)),
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
}
