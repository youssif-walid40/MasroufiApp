import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../theme/app_colors.dart';

import 'package:intl/intl.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Expense> expenses;
  final ExpenseCategory Function(Expense) getCategory;
  final Function(Expense) onDelete;
  final Function(Expense) onEdit;
  final bool isPrivacyMode;

  const RecentTransactionsList({
    super.key,
    required this.expenses,
    required this.getCategory,
    required this.onDelete,
    required this.onEdit,
    this.isPrivacyMode = false,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'No expenses added yet.\nTap the + button to add one.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final category = getCategory(expense);

        return _buildTransactionCard(context, expense, category);
      },
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    Expense expense,
    ExpenseCategory category,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Category Icon Box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _getCategoryIcon(category.name),
              color: category.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // 2. Title & Date / Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.itemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(expense.date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          // 3. Amount
          Text(
            isPrivacyMode ? 'EGP ****' : 'EGP ${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(width: 8),

          // 4. Options Menu (Edit / Delete)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.more_horiz,
                color: AppColors.secondaryText,
                size: 18,
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit(expense);
                } else if (value == 'delete') {
                  onDelete(expense);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_bus_filled_outlined;
      case 'utilities':
        return Icons.bolt;
      case 'shopping':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    // Handles the 12-hour format and AM/PM automatically (e.g., "2:30 PM")
    final timeString = DateFormat('h:mm a').format(date);

    // Check if it's today
    if (now.year == date.year &&
        now.month == date.month &&
        now.day == date.day) {
      return 'Today • $timeString';
    }

    // Check if it's yesterday
    final yesterday = now.subtract(const Duration(days: 1));
    if (yesterday.year == date.year &&
        yesterday.month == date.month &&
        yesterday.day == date.day) {
      return 'Yesterday • $timeString';
    }

    // Default format for older dates (e.g., "Sep 24 • 2:30 PM")
    final dateString = DateFormat('MMM d').format(date);
    return '$dateString • $timeString';
  }
}
