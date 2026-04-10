import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../services/invoice_service.dart';
import '../services/quotation_service.dart';
import '../services/inventory_service.dart';
import '../services/expense_service.dart';
import '../services/income_service.dart';
import '../utils/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final InvoiceService _invoiceService;
  late final QuotationService _quotationService;
  late final InventoryService _inventoryService;
  late final ExpenseService _expenseService;
  late final IncomeService _incomeService;

  late Future<Map<String, dynamic>> _statsFuture;

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final firebase = Provider.of<FirebaseService>(context, listen: false);
      _invoiceService = InvoiceService(firebase);
      _quotationService = QuotationService(firebase);
      _inventoryService = InventoryService(firebase);
      _expenseService = ExpenseService(firebase);
      _incomeService = IncomeService(firebase);
      
      _refreshStats();
      _isInit = false;
    }
  }

  void _refreshStats() {
    setState(() {
      _statsFuture = _loadStatistics();
    });
  }

  Future<Map<String, dynamic>> _loadStatistics() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59); // End of day

      // Run in parallel
      final results = await Future.wait([
        _invoiceService.getAll(),          
        _quotationService.getAll(),        
        _inventoryService.getAll(),        
        _inventoryService.getLowStockItems(), 
        _incomeService.getTotal(startOfMonth, endOfMonth), 
        _expenseService.getTotal(startOfMonth, endOfMonth), 
      ]);

      return {
        'invoiceCount': (results[0] as List).length,
        'quotationCount': (results[1] as List).length,
        'inventoryCount': (results[2] as List).length,
        'lowStockCount': (results[3] as List).length,
        'monthlyIncome': results[4] as double,
        'monthlyExpenses': results[5] as double,
      };
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      return {
        'invoiceCount': 0,
        'quotationCount': 0,
        'inventoryCount': 0,
        'lowStockCount': 0,
        'monthlyIncome': 0.0,
        'monthlyExpenses': 0.0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Today: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _refreshStats,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh Data',
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            FutureBuilder<Map<String, dynamic>>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final data = snapshot.data ?? {
                  'invoiceCount': 0,
                  'quotationCount': 0,
                  'inventoryCount': 0,
                  'lowStockCount': 0,
                  'monthlyIncome': 0.0,
                  'monthlyExpenses': 0.0,
                };

                return GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      'Total Invoices',
                      data['invoiceCount'].toString(),
                      Icons.receipt_long,
                      const Color(0xFF667eea),
                    ),
                    _buildStatCard(
                      'Total Quotations',
                      data['quotationCount'].toString(),
                      Icons.description,
                      const Color(0xFFf093fb),
                    ),
                    _buildStatCard(
                      'Inventory Items',
                      data['inventoryCount'].toString(),
                      Icons.inventory_2,
                      const Color(0xFF4facfe),
                    ),
                    _buildStatCard(
                      'Low Stock Items',
                      data['lowStockCount'].toString(),
                      Icons.warning,
                      const Color(0xFFfa709a),
                    ),
                    _buildStatCard(
                      'Monthly Income',
                      'Rs. ${NumberFormat('#,##0.00').format(data['monthlyIncome'])}',
                      Icons.trending_up,
                      const Color(0xFF30cfd0),
                    ),
                    _buildStatCard(
                      'Monthly Expenses',
                      'Rs. ${NumberFormat('#,##0.00').format(data['monthlyExpenses'])}',
                      Icons.trending_down,
                      const Color(0xFFa8edea),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

