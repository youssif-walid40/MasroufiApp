import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/add_expense_sheet.dart';
import '../providers/expense_provider.dart';

import 'dashboard_screen.dart';
import 'budgets_screen.dart';
import 'alerts_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // The 4 screens are stored in a list. Dashboard is Index 0.
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(),
      BudgetsScreen(),
      AlertsScreen(),
      ProfileScreen(),
    ];
  }

  void _showExpenseForm() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddExpenseSheet(
            categories: provider.categories,
            onSave: (savedExpense) async {
              await provider.addOrUpdateExpense(savedExpense);
              // Go back to dashboard if they were on another tab
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: IndexedStack(index: _currentIndex, children: _screens),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Swaps the visible screen instantly
          });
        },
        onAddPressed: _showExpenseForm,
      ),
    );
  }
}
