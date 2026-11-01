import 'package:flutter/material.dart';
import 'dart:convert';

class ExpenseCategory {
  final String id;
  final String name;
  double budgetLimit;
  final Color color; // Maps to the colors in your UI (e.g., Green for Food)

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.budgetLimit,
    required this.color,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'budget_limit': budgetLimit,
      'color': color.toARGB32(), // Stores the hex color as an integer
    };
  }

  // Create Object from SQLite Map
  factory ExpenseCategory.fromMap(Map<String, dynamic> map, String documentId) {
    return ExpenseCategory(
      id: documentId,
      name: map['name'] as String,
      budgetLimit: (map['budget_limit'] as num).toDouble(), // SQlite stores numbers like 12.0,0.0,400.0 as int so converted to double 
      color: Color(map['color'] as int), // Reconstructs the Color from integer
    );
  }

  // Conversions needed for the cache
    String toJson() {
    return jsonEncode({
      'id': id,
      'name': name,
      'budget_limit': budgetLimit,
      'color': color.toARGB32(), // stores the integer value of the color
    });
  }

  factory ExpenseCategory.fromJson(String jsonStr) {
    final map = jsonDecode(jsonStr);
    return ExpenseCategory(
      id: map['id'],
      name: map['name'],
      budgetLimit: (map['budget_limit'] as num).toDouble(),
      color: Color(map['color'] as int),
    );
  }
}