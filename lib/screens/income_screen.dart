import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/income.dart';
import '../services/firebase_service.dart';
import '../services/income_service.dart';
import '../utils/app_theme.dart';
import '../widgets/income_form_dialog.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  late IncomeService _incomeService;
  List<Income> _incomes = [];
  bool _isLoading = true;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final firebase = Provider.of<FirebaseService>(context);
      _incomeService = IncomeService(firebase);
      _loadIncomes();
      _isInit = false;
    }
  }

  Future<void> _loadIncomes() async {
    setState(() => _isLoading = true);
    try {
      final incomes = await _incomeService.getAll();
      // Sort by date desc
      incomes.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        _incomes = incomes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading income: $e')),
        );
      }
    }
  }

  Future<void> _showIncomeDialog(Income? income) async {
    final result = await showDialog(
      context: context,
      builder: (context) => IncomeFormDialog(income: income, incomeService: _incomeService),
    );
    if (result == true) {
      _loadIncomes();
    }
  }

  Future<void> _deleteIncome(Income income) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this income entry?'),
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

    if (confirm == true && income.id != null) {
      try {
        await _incomeService.delete(income.id!);
        _loadIncomes();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting income: $e')),
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
                  'Income',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showIncomeDialog(null),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Income'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _incomes.isEmpty
                    ? Center(
                        child: Text(
                          'No income records found.',
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
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Source')),
                                DataColumn(label: Text('Description')),
                                DataColumn(label: Text('Amount')),
                                DataColumn(label: Text('Method')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: _incomes.map((income) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(DateFormat('MMM dd, yyyy').format(income.date))),
                                    DataCell(Text(income.source)),
                                    DataCell(Text(income.description)),
                                    DataCell(Text(
                                      'Rs. ${NumberFormat('#,##0.00').format(income.amount)}',
                                      style: const TextStyle(
                                        color: AppTheme.successColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                    DataCell(Text(income.paymentMethod)),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20),
                                            onPressed: () => _showIncomeDialog(income),
                                            color: AppTheme.infoColor,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20),
                                            onPressed: () => _deleteIncome(income),
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

