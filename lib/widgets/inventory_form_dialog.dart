import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../services/inventory_service.dart';
import '../utils/app_theme.dart';

class InventoryFormDialog extends StatefulWidget {
  final InventoryItem? item;
  final InventoryService inventoryService;

  const InventoryFormDialog({
    super.key,
    this.item,
    required this.inventoryService,
  });

  @override
  State<InventoryFormDialog> createState() => _InventoryFormDialogState();
}

class _InventoryFormDialogState extends State<InventoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _itemCodeController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _unitController;
  late TextEditingController _quantityController;
  late TextEditingController _minStockController;
  late TextEditingController _unitCostController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _supplierController;
  late TextEditingController _locationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _itemCodeController = TextEditingController(text: item?.itemCode ?? '');
    _nameController = TextEditingController(text: item?.name ?? '');
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _categoryController = TextEditingController(text: item?.category ?? '');
    _unitController = TextEditingController(text: item?.unit ?? 'pcs');
    _quantityController = TextEditingController(text: (item?.quantity ?? 0).toString());
    _minStockController = TextEditingController(text: (item?.minStockLevel ?? 0).toString());
    _unitCostController = TextEditingController(text: (item?.unitCost ?? 0.0).toString());
    _sellingPriceController = TextEditingController(text: (item?.sellingPrice ?? 0.0).toString());
    _supplierController = TextEditingController(text: item?.supplier ?? '');
    _locationController = TextEditingController(text: item?.location ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final item = InventoryItem(
        id: widget.item?.id,
        itemCode: _itemCodeController.text,
        name: _nameController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        category: _categoryController.text.isEmpty ? null : _categoryController.text,
        unit: _unitController.text,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        minStockLevel: int.tryParse(_minStockController.text) ?? 0,
        unitCost: double.tryParse(_unitCostController.text) ?? 0.0,
        sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0.0,
        supplier: _supplierController.text.isEmpty ? null : _supplierController.text,
        location: _locationController.text.isEmpty ? null : _locationController.text,
      );

      if (widget.item?.id != null) {
        await widget.inventoryService.update(item);
      } else {
        await widget.inventoryService.create(item);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.item == null
                ? 'Item created successfully!'
                : 'Item updated successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving item: $e')),
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
    _itemCodeController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _unitCostController.dispose();
    _sellingPriceController.dispose();
    _supplierController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
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
                    widget.item == null ? 'New Inventory Item' : 'Edit Item',
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
                      _buildSectionTitle(context, 'Item Details'),
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
                                      controller: _itemCodeController,
                                      decoration: const InputDecoration(
                                        labelText: 'Item Code',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Item Name',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
                                maxLines: 2,
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
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _unitController,
                                      decoration: const InputDecoration(
                                        labelText: 'Unit (e.g., pcs, kg)',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Stock & Pricing'),
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
                                      controller: _quantityController,
                                      decoration: const InputDecoration(
                                        labelText: 'Quantity',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _minStockController,
                                      decoration: const InputDecoration(
                                        labelText: 'Min Stock Level',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _unitCostController,
                                      decoration: const InputDecoration(
                                        labelText: 'Unit Cost (Rs.)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _sellingPriceController,
                                      decoration: const InputDecoration(
                                        labelText: 'Selling Price (Rs.)',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
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
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _supplierController,
                                  decoration: const InputDecoration(
                                    labelText: 'Supplier',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _locationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Location / Shelf',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
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
                    label: const Text('Save Item', style: TextStyle(fontSize: 16)),
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
