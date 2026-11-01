// NO LONGER NEEDED AS FIRESTORE IS A ALREADY IMPLEMENTED.


// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// import '../models/expense.dart';
// import '../models/expense_category.dart';
// import '../theme/app_colors.dart';

// class DatabaseHelper {
//   DatabaseHelper._singleton();

//   static final _instance = DatabaseHelper._singleton();

//   factory DatabaseHelper() => _instance;

//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'masroufi.db');
//     return await openDatabase(path, 
//     version: 1,
//     onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
//     onCreate: _onCreate);
//   }

//   Future<void> _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE categories (
//         id TEXT PRIMARY KEY,
//         name TEXT NOT NULL,
//         budget_limit REAL NOT NULL,
//         color INTEGER NOT NULL
//       )
//     ''');

//     await db.execute('''
//       CREATE TABLE expenses (
//         id TEXT PRIMARY KEY,
//         category_id TEXT NOT NULL,
//         item_name TEXT NOT NULL,
//         amount REAL NOT NULL,
//         date TEXT NOT NULL,
//         note TEXT,
//         FOREIGN KEY (category_id) REFERENCES categories (id)
//       )
//     ''');

//     await db.insert(
//       'categories',
//       ExpenseCategory(
//         id: 'c1',
//         name: 'Food',
//         budgetLimit: 0.0,
//         color: AppColors.primaryGreen,
//       ).toMap(),
//     );

//     await db.insert(
//       'categories',
//       ExpenseCategory(
//         id: 'c2',
//         name: 'Transport',
//         budgetLimit: 0.0,
//         color: AppColors.transportPurple,
//       ).toMap(),
//     );

//     await db.insert(
//       'categories',
//       ExpenseCategory(
//         id: 'c3',
//         name: 'Shopping',
//         budgetLimit: 0.0,
//         color: AppColors.shoppingRed,
//       ).toMap(),
//     );

//     await db.insert(
//       'categories',
//       ExpenseCategory(
//         id: 'c4',
//         name: 'Utilities',
//         budgetLimit: 0.0,
//         color: AppColors.utilitiesOrange,
//       ).toMap(),
//     );

//   }

//   // --- EXPENSE CATEGORY LOGIC ---

//   Future<void> insertCategory(ExpenseCategory category) async {
//     final db = await _instance.database;
//     await db.insert(
//       'categories',
//       category.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<List<ExpenseCategory>> getAllCategories() async {
//     final db = await _instance.database;
//     final result = await db.query('categories');
//     return result.map((json) => ExpenseCategory.fromMap(json)).toList();
//   }

//   Future<void> updateCategoryLimit(String id, double newLimit) async {
//     final db = await _instance.database;
//     await db.update(
//       'categories',
//       {'budget_limit': newLimit},
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   // --- EXPENSE LOGIC ---

//   Future<void> insertExpense(Expense expense) async {
//     final db = await _instance.database;
//     await db.insert(
//       'expenses',
//       expense.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<void> deleteExpense(String id) async {
//     final db = await database;
//     await db.delete(
//       'expenses',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   Future<List<Expense>> getAllExpenses() async {
//     final db = await _instance.database;
//     // Orders expenses from newest to oldest
//     final result = await db.query('expenses', orderBy: 'date DESC');
//     return result.map((json) => Expense.fromMap(json)).toList();
//   }

//   // The "JOIN" operation equivalent from your mock database
//   Future<List<Expense>> getExpensesForCategory(String categoryId) async {
//     final db = await _instance.database;
//     final result = await db.query(
//       'expenses',
//       where: 'category_id = ?',
//       whereArgs: [categoryId],
//       orderBy: 'date DESC',
//     );
//     return result.map((json) => Expense.fromMap(json)).toList();
//   }

//   Future<ExpenseCategory> getCategoryForExpense(String categoryId) async {
//     final db = await _instance.database;
//     final result = await db.query(
//       'categories',
//       where: 'id = ?',
//       whereArgs: [categoryId],
//     );

//     if (result.isNotEmpty) {
//       return ExpenseCategory.fromMap(result.first);
//     } else {
//       throw Exception('Category ID $categoryId not found');
//     }
//   }

//   // Fetches only the expenses for the current real-world month
//   Future<List<Expense>> getCurrentMonthExpenses() async {
//     final db = await database;
//     final now = DateTime.now();
    
//     // Formats the month to always be two digits (e.g., '09' for September)
//     final monthStr = now.month.toString().padLeft(2, '0');
//     final yearMonthPrefix = '${now.year}-$monthStr%';

//     final result = await db.query(
//       'expenses',
//       where: 'date LIKE ?',
//       whereArgs: [yearMonthPrefix],
//       orderBy: 'date DESC',
//     );
    
//     return result.map((json) => Expense.fromMap(json)).toList();
//   }

//   // Fetches expenses from last two weeks from now for the trends
//   Future<List<Expense>> getLastTwoWeeksExpenses() async {
//     final db = await database;
    
//     final now = DateTime.now();
//     final twoWeeksAgo = now.subtract(const Duration(days: 14));

//     final result = await db.query(
//       'expenses',
//       where: 'date >= ? AND date <= ?',
//       // Passes the strict date range to SQLite
//       whereArgs: [twoWeeksAgo.toIso8601String(), now.toIso8601String()],
//       // Ascending order is usually best for drawing left-to-right charts
//       orderBy: 'date ASC', 
//     );
    
//     return result.map((json) => Expense.fromMap(json)).toList();
//   }
// }
