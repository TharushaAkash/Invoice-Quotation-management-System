import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../utils/app_theme.dart';
import 'dashboard_screen.dart';
import 'invoices_screen.dart';
import 'quotations_screen.dart';
import 'inventory_screen.dart';
import 'expenses_screen.dart';
import 'income_screen.dart';
import 'printer_settings_screen.dart';
import 'settings_screen.dart'; // Added

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const InvoicesScreen(),
    const QuotationsScreen(),
    const InventoryScreen(),
    const ExpensesScreen(),
    const IncomeScreen(),
    const PrinterSettingsScreen(),
    const SettingsScreen(), // Added
  ];

  final List<NavigationItem> _navItems = [
    NavigationItem(icon: Icons.dashboard, label: 'Dashboard'),
    NavigationItem(icon: Icons.receipt_long, label: 'Invoices'),
    NavigationItem(icon: Icons.description, label: 'Quotations'),
    NavigationItem(icon: Icons.inventory_2, label: 'Inventory'),
    NavigationItem(icon: Icons.money_off, label: 'Expenses'),
    NavigationItem(icon: Icons.attach_money, label: 'Income'),
    NavigationItem(icon: Icons.print, label: 'Printer Settings'),
    NavigationItem(icon: Icons.settings, label: 'Settings'), // Added
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            color: AppTheme.sidebarBg,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, color: Colors.amber, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'ඊ-Tech Electricals',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppTheme.sidebarHover, height: 1),
                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    itemCount: _navItems.length,
                    itemBuilder: (context, index) {
                      final item = _navItems[index];
                      final isSelected = _selectedIndex == index;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.sidebarHover : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? const Border(
                                    left: BorderSide(color: AppTheme.primaryColor, width: 3),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem({required this.icon, required this.label});
}
