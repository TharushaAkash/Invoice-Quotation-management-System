import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../services/firebase_service.dart';
import '../services/expense_service.dart';
import '../utils/app_theme.dart';
import '../widgets/expense_form_dialog.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late ExpenseService _expenseService;
  List<Expense> _expenses = [];
  bool _isLoading = true;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final firebase = Provider.of<FirebaseService>(context);
      _expenseService = ExpenseService(firebase);
      _loadExpenses();
      _isInit = false;
    }
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    try {
      final expenses = await _expenseService.getAll();
      // Sort by date desc
      expenses.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading expenses: $e')),
        );
      }
    }
  }

  Future<void> _showExpenseDialog(Expense? expense) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ExpenseFormDialog(expense: expense, expenseService: _expenseService),
    );
    if (result == true) {
      _loadExpenses();
    }
  }

  Future<void> _deleteExpense(Expense expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
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

    if (confirm == true && expense.id != null) {
      try {
        await _expenseService.delete(expense.id!);
        _loadExpenses();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting expense: $e')),
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
                  'Expenses',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showExpenseDialog(null),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Expense'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _expenses.isEmpty
                    ? Center(
                        child: Text(
                          'No expenses recorded.',
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
                                DataColumn(label: Text('Category')),
                                DataColumn(label: Text('Description')),
                                DataColumn(label: Text('Amount')),
                                DataColumn(label: Text('Method')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: _expenses.map((expense) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(DateFormat('MMM dd, yyyy').format(expense.date))),
                                    DataCell(Text(expense.category)),
                                    DataCell(Text(expense.description)),
                                    DataCell(Text(
                                      'Rs. ${NumberFormat('#,##0.00').format(expense.amount)}',
                                      style: const TextStyle(
                                        color: AppTheme.dangerColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                    DataCell(Text(expense.paymentMethod)),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20),
                                            onPressed: () => _showExpenseDialog(expense),
                                            color: AppTheme.infoColor,
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, size: 20),
                                            onPressed: () => _deleteExpense(expense),
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

