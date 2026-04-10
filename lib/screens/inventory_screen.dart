import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/inventory_item.dart';
import '../services/firebase_service.dart';
import '../services/inventory_service.dart';
import '../utils/app_theme.dart';
import '../widgets/inventory_form_dialog.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late InventoryService _inventoryService;
  List<InventoryItem> _items = [];
  bool _isLoading = true;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final firebase = Provider.of<FirebaseService>(context);
      _inventoryService = InventoryService(firebase);
      _loadItems();
      _isInit = false;
    }
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    try {
      final items = await _inventoryService.getAll();
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading inventory: $e')),
        );
      }
    }
  }

  Future<void> _showItemDialog(InventoryItem? item) async {
    final result = await showDialog(
      context: context,
      builder: (context) => InventoryFormDialog(item: item, inventoryService: _inventoryService),
    );
    if (result == true) {
      _loadItems();
    }
  }

  Future<void> _deleteItem(InventoryItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
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

    if (confirm == true && item.id != null) {
      try {
        await _inventoryService.delete(item.id!);
        _loadItems();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting item: $e')),
          );
        }
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
                  'Inventory',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showItemDialog(null),
                  icon: const Icon(Icons.add),
                  label: const Text('New Item'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? Center(
                        child: Text(
                          'Inventory is empty. Add your first item!',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : Card(
                        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                        child: SingleChildScrollView(
                          child: SizedBox(
                            width: double.infinity,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Code')),
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Category')),
                                DataColumn(label: Text('Qty')),
                                DataColumn(label: Text('Cost')),
                                DataColumn(label: Text('Price')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: _items.map((item) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(item.itemCode)),
                                    DataCell(Text(item.name)),
                                    DataCell(Text(item.category ?? '-')),
                                    DataCell(
                                      Text(
                                        '${item.quantity} ${item.unit}',
                                        style: TextStyle(
                                          color: item.isLowStock ? AppTheme.dangerColor : null,
                                          fontWeight: item.isLowStock ? FontWeight.bold : null,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text('Rs. ${NumberFormat('#,##0').format(item.unitCost)}')),
                                    DataCell(Text('Rs. ${NumberFormat('#,##0').format(item.sellingPrice)}')),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20),
                                            onPressed: () => _showItemDialog(item),
                                            color: AppTheme.infoColor,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20),
                                            onPressed: () => _deleteItem(item),
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
}

