import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../theme/app_colors.dart';

import '../widgets/summary_card.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/category_donut_chart.dart';
import '../widgets/daily_trend_chart.dart';

import '../providers/expense_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      // The floating bottom navigation bar
      //   floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      //   floatingActionButton: CustomBottomNav(
      //     currentIndex: _currentNavIndex,
      //     onTap: (index) {
      //    setState(() {
      //      _currentNavIndex = index;
      //      // In Phase 3, this is where you will add logic to switch screens
      //    });
      //  },
      //  onAddPressed: () => _showExpenseForm(),
      //   ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Placeholder
              _buildHeaderPlaceholder(),
              const SizedBox(height: 24),

              // 2. Summary Card Placeholder
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: SummaryCard(
                  expenses: provider.currentMonthExpenses,
                  monthlyBudget: provider.monthlyBudget,
                  isPrivacyMode: provider.isPrivacyMode,
                ),
              ),
              const SizedBox(height: 32),

              // 3. Category Donut Chart Placeholder
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'By category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM').format(DateTime.now()),
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CategoryDonutChart(
                expenses: provider.currentMonthExpenses,
                categories: provider.categories,
                isPrivacyMode: provider.isPrivacyMode,
              ),
              const SizedBox(height: 32),

              // 4. Daily Trend Chart Placeholder
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily trend for ${DateFormat('MMMM').format(DateTime.now())}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Text(
                    'Last 2 weeks',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DailyTrendChart(expenses: provider.twoWeeksExpenses),
              const SizedBox(height: 32),

              // 5. Recent Expenses List Placeholder
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showExpenseForm(),
                    child: const Text(
                      '+ Add',
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RecentTransactionsList(
                expenses: provider.currentMonthExpenses,
                getCategory: (expense) => provider.categories.firstWhere(
                  (cat) => cat.id == expense.categoryId,
                ),
                onDelete: (expense) async {
                  await provider.deleteExpense(expense.id);
                },
                onEdit: (expense) {
                  // Will link to edit sheet/dialog
                  _showExpenseForm(expenseToEdit: expense);
                },
                isPrivacyMode: provider.isPrivacyMode,
              ),

              // Bottom padding ensures the floating nav bar doesn't cover the last list item
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _showExpenseForm({Expense? expenseToEdit}) {
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
            existingExpense: expenseToEdit,
            onSave: (savedExpense) async {
              await provider.addOrUpdateExpense(savedExpense);
            },
          ),
        );
      },
    );
  }

  // Temporary Header setup
  Widget _buildHeaderPlaceholder() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good evening',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
            ),
            Text(
              'Youssif Walid',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.darkCard,
          child: Text(
            'Y',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Temporary Bottom Nav setup
  // Widget _buildBottomNavPlaceholder() {
  //   return Container(
  //     height: 70,
  //     margin: const EdgeInsets.symmetric(horizontal: 40),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(40),
  //       boxShadow: [
  //         BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
  //       ],
  //     ),
  //     child: const Center(child: Text('Custom Nav Bar Widget Goes Here')),
  //   );
  // }
}
