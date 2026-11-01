import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../theme/app_colors.dart';

class MockDatabase {
  // 1. Your "Tables"
  List<ExpenseCategory> categories = [
    ExpenseCategory(
      id: 'c1',
      name: 'Food',
      budgetLimit: 450.0,
      color: AppColors.primaryGreen,
    ),
    ExpenseCategory(
      id: 'c2',
      name: 'Transport',
      budgetLimit: 400.0,
      color: AppColors.transportPurple,
    ),
    ExpenseCategory(
      id: 'c3',
      name: 'Shopping',
      budgetLimit: 400.0,
      color: AppColors.shoppingRed,
    ),
  ];

  List<Expense> expenses = [
    Expense(
      id: 'e1',
      categoryId: 'c1',
      amount: 24.90,
      date: DateTime(2026, 9, 20, 14, 30),
      note: 'Koshari with Nour',
      itemName: 'Koshari',
    ),
    Expense(
      id: 'e2',
      categoryId: 'c2',
      amount: 12.00,
      date: DateTime(2026, 9, 18, 15, 0),
      itemName: 'Bus Ticket',
    ),
  ];

  // 2. The "JOIN" operation
  // 3. Get all items for a specific category
  List<Expense> getExpensesForCategory(String categoryId) { // You may use in Phase 3 when displaying all monthly expenses
    // Returns an iterable of all matching expenses, then converts it back to a List
    return expenses
        .where((expense) => expense.categoryId == categoryId)
        .toList();
  }

  ExpenseCategory getCategoryForExpense(Expense expense) {
    return categories.firstWhere(
      (cat) => cat.id == expense.categoryId,
      orElse: () => ExpenseCategory(id: 'default', name: 'Unknown', budgetLimit: 0, color: Colors.grey),
    );
  }
}
