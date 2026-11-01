import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class Expense {
  final String id;
  final String categoryId; // The "Foreign Key" linking to ExpenseCategory
  final String itemName;
  final double amount;
  final DateTime date;
  final String? note; // Nullable string for optional details

  Expense({
    required this.id,
    required this.categoryId,
    required this.itemName,
    required this.amount,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'item_name': itemName,
      'amount': amount,
      'date': Timestamp.fromDate(date), // Stores as Firestore Timestamp
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, String documentId) {
    return Expense(
      id: documentId,
      categoryId: map['category_id'] as String,
      itemName: map['item_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(), // Parses Firestore Timestamp back to DateTime
      note: map['note'] as String?,
    );
  }

  // Conversions needed for the cache
  String toJson() {
    return jsonEncode({
      'id': id,
      'category_id': categoryId,
      'item_name': itemName,
      'amount': amount,
      'date': date.toIso8601String(), // Converts DateTime to a JSON-friendly string
      'note': note,
    });
  }

  factory Expense.fromJson(String jsonStr) {
    final map = jsonDecode(jsonStr);
    return Expense(
      id: map['id'],
      categoryId: map['category_id'],
      itemName: map['item_name'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }
}
