import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/firestore_helper.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';

class ExpenseProvider extends ChangeNotifier {
  final FireStoreHelper _db = FireStoreHelper();

  // State Variables
  List<ExpenseCategory> _categories = [];
  List<Expense> _currentMonthExpenses = [];
  List<Expense> _twoWeeksExpenses = [];

  double _monthlyBudget = 2000.0;
  bool _isPrivacyMode = false;
  bool _isLoading = true;

  // Getters for the UI to read
  List<ExpenseCategory> get categories => _categories;
  List<Expense> get currentMonthExpenses => _currentMonthExpenses;
  List<Expense> get twoWeeksExpenses => _twoWeeksExpenses;
  double get monthlyBudget => _monthlyBudget;
  bool get isPrivacyMode => _isPrivacyMode;
  bool get isLoading => _isLoading;

  ExpenseProvider() {
    loadAllData(); // Fetches data immediately when the app starts
  }

  Future<void> _cacheDataLocally() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      'cached_month_expenses',
      _currentMonthExpenses.map((e) => e.toJson()).toList(),
    );
    await prefs.setStringList(
      'cached_two_weeks',
      _twoWeeksExpenses.map((e) => e.toJson()).toList(),
    );
    await prefs.setStringList(
      'cached_categories',
      _categories.map((c) => c.toJson()).toList(),
    );
  }

  // --- CORE DATA FETCHING ---
  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners(); // Tells UI to show loading spinners

    final prefs = await SharedPreferences.getInstance();

    _monthlyBudget = prefs.getDouble('monthlyBudget') ?? 2000.0;
    _isPrivacyMode = prefs.getBool('isPrivacyMode') ?? false;

    // Restore Categories
    final cachedCategories = prefs.getStringList('cached_categories');
    if (cachedCategories != null) {
      _categories = cachedCategories
          .map((str) => ExpenseCategory.fromJson(str))
          .toList();
    }

    // Restore Current Month
    final cachedMonth = prefs.getStringList('cached_month_expenses');
    if (cachedMonth != null) {
      _currentMonthExpenses = cachedMonth
          .map((str) => Expense.fromJson(str))
          .toList();
    }

    // Restore Two Weeks
    final cachedTwoWeeks = prefs.getStringList('cached_two_weeks');
    if (cachedTwoWeeks != null) {
      _twoWeeksExpenses = cachedTwoWeeks
          .map((str) => Expense.fromJson(str))
          .toList();
    }

    if (cachedCategories != null && cachedMonth != null && cachedTwoWeeks != null) {
      debugPrint('Loaded from SharedPreferences cache!');
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        _db.getAllCategories(),
        _db.getCurrentMonthExpenses(),
        _db.getLastTwoWeeksExpenses(),
      ]);

      _categories = results[0] as List<ExpenseCategory>;
      _currentMonthExpenses = results[1] as List<Expense>;
      _twoWeeksExpenses = results[2] as List<Expense>;

      await _cacheDataLocally();

    } catch (error) {
      debugPrint('error fetching data: $error');
    } finally {
      _isLoading = false;
      notifyListeners(); // Tells UI to rebuild with the fetched data
    }
  }

  // --- ACTIONS ---

  Future<void> addOrUpdateExpense(Expense expense) async {
    try {
      await _db.insertExpense(expense);

      // Update local state directly instead of re-fetching the entire collection
      final monthIndex = _currentMonthExpenses.indexWhere(
        (e) => e.id == expense.id,
      );
      if (monthIndex != -1) {
        _currentMonthExpenses[monthIndex] = expense;
      } else {
        _currentMonthExpenses.insert(0, expense);
      }
      _currentMonthExpenses.sort((a, b) => b.date.compareTo(a.date));

      final twoWeeksIndex = _twoWeeksExpenses.indexWhere(
        (e) => e.id == expense.id,
      );
      if (twoWeeksIndex != -1) {
        _twoWeeksExpenses[twoWeeksIndex] = expense;
      } else {
        _twoWeeksExpenses.add(expense);
      }
      _twoWeeksExpenses.sort((a, b) => b.date.compareTo(a.date));
      await _cacheDataLocally();

      notifyListeners();
    } catch (e) {
      debugPrint('Error saving expense: $e');
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _db.deleteExpense(id);

      // Remove from local memory without triggering full database reads
      _currentMonthExpenses.removeWhere((e) => e.id == id);
      _twoWeeksExpenses.removeWhere((e) => e.id == id);

      await _cacheDataLocally();

      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      rethrow;
    }
  }

  Future<void> updateCategoryLimit(String id, double limit) async {
    try {
      await _db.updateCategoryLimit(id, limit);

      final index = _categories.indexWhere((cat) => cat.id == id);
      if (index != -1) {
        _categories[index].budgetLimit = limit;
        await _cacheDataLocally();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating category limit: $e');
      rethrow;
    }
  }

  Future<void> setGlobalBudget(double budget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthlyBudget', budget);

    _monthlyBudget = budget;
    notifyListeners();
  }

  Future<void> togglePrivacyMode(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPrivacyMode', isEnabled);

    _isPrivacyMode = isEnabled;
    notifyListeners();
  }
}
