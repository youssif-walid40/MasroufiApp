import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../theme/app_colors.dart';

class FireStoreHelper {
  final _db = FirebaseFirestore.instance;

  Future<void> seedDefaultCategories() async {
    // Check if categories have already been initialized
    final existing = await _db.collection('categories').limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();

    final defaultCategories = [
      ExpenseCategory(
        id: 'c1',
        name: 'Food',
        budgetLimit: 0.0,
        color: AppColors.primaryGreen,
      ),
      ExpenseCategory(
        id: 'c2',
        name: 'Transport',
        budgetLimit: 0.0,
        color: AppColors.transportPurple,
      ),
      ExpenseCategory(
        id: 'c3',
        name: 'Shopping',
        budgetLimit: 0.0,
        color: AppColors.shoppingRed,
      ),
      ExpenseCategory(
        id: 'c4',
        name: 'Utilities',
        budgetLimit: 0.0,
        color: AppColors.utilitiesOrange,
      ),
    ];

    for (final category in defaultCategories) {
      final docRef = _db.collection('categories').doc(category.id);
      batch.set(docRef, category.toMap());
    }

    await batch.commit();
  }

  // --- EXPENSE CATEGORY LOGIC ---

  Future<void> insertCategory(ExpenseCategory category) async {
    // .set() mirrors ConflictAlgorithm.replace by creating or overwriting the document
    await _db.collection('categories').doc(category.id).set(category.toMap());
  }

  Future<List<ExpenseCategory>> getAllCategories() async {
    final snapshot = await _db.collection('categories').get();
    return snapshot.docs
        .map((doc) => ExpenseCategory.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateCategoryLimit(String id, double newLimit) async {
    await _db.collection('categories').doc(id).update({'budget_limit': newLimit});
  }

  Future<ExpenseCategory> getCategoryForExpense(String categoryId) async {
    final doc = await _db.collection('categories').doc(categoryId).get();
    if (doc.exists && doc.data() != null) {
      return ExpenseCategory.fromMap(doc.data()!, doc.id);
    } else {
      throw Exception('Category ID $categoryId not found');
    }
  }

  // --- EXPENSE LOGIC ---

  Future<void> insertExpense(Expense expense) async {
    // Uses the expense.id manually provided by your app as the document ID
    await _db.collection('expenses').doc(expense.id).set(expense.toMap());
  }

  Future<void> deleteExpense(String id) async {
    await _db.collection('expenses').doc(id).delete();
  }

  Future<List<Expense>> getAllExpenses() async {
    final snapshot = await _db
        .collection('expenses')
        .orderBy('date', descending: true)
        .get();
    
    return snapshot.docs
        .map((doc) => Expense.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<Expense>> getExpensesForCategory(String categoryId) async {
    final snapshot = await _db
        .collection('expenses')
        .where('category_id', isEqualTo: categoryId)
        .orderBy('date', descending: true)
        .get();
        
    return snapshot.docs
        .map((doc) => Expense.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<Expense>> getCurrentMonthExpenses() async {
    final now = DateTime.now();
    // Get the absolute start of the current month for an exact timestamp comparison
    final startOfMonth = DateTime(now.year, now.month, 1);

    final snapshot = await _db
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .orderBy('date', descending: true)
        .get();
        
    return snapshot.docs
        .map((doc) => Expense.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<Expense>> getLastTwoWeeksExpenses() async {
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    final snapshot = await _db
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(twoWeeksAgo))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy('date', descending: false) 
        .get();
        
    return snapshot.docs
        .map((doc) => Expense.fromMap(doc.data(), doc.id))
        .toList();
  }

}