import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../theme/app_colors.dart';

class CategoryDonutChart extends StatefulWidget {
  final List<Expense> expenses;
  final List<ExpenseCategory> categories;
  final bool isPrivacyMode;

  const CategoryDonutChart({
    super.key,
    required this.expenses,
    required this.categories,
    this.isPrivacyMode = false,
  });

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  // Tracks which section is tapped to animate it
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // 1. Filter for the current month
    final now = DateTime.now();
    final currentMonthExpenses = widget.expenses.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).toList();

    // 2. Aggregate totals per category
    final Map<String, double> categoryTotals = {};
    double totalSpent = 0;

    for (var expense in currentMonthExpenses) {
      categoryTotals[expense.categoryId] = (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
      totalSpent += expense.amount;
    }

    // 3. Handle Empty State
    if (totalSpent == 0) {
      return _buildEmptyState();
    }

    // 4. Generate the Chart Sections mapping the data
    List<PieChartSectionData> sections = [];
    int index = 0;
    
    for (var category in widget.categories) {
      final amount = categoryTotals[category.id] ?? 0;
      
      // Only draw a section if the category has expenses
      if (amount > 0) {
        final isTouched = index == touchedIndex;
        final percentage = (amount / totalSpent * 100).toStringAsFixed(0);
        
        sections.add(
          PieChartSectionData(
            color: category.color,
            value: amount,
            // Show percentage only when tapped
            title: isTouched ? '$percentage%' : '',
            radius: isTouched ? 40.0 : 30.0, // Enlarges when tapped
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        index++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Side: The Interactive Donut Chart
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      sections: sections,
                    ),
                  ),
                  // Center Text Label
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.isPrivacyMode 
                        ? 'EGP ****'
                        : totalSpent >= 1000 ? 'EGP ${(totalSpent / 1000).toStringAsFixed(1)}k' : 'EGP ${totalSpent.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText),
                      ),
                      const Text('Total', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Right Side: Auto-generated Legend
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              // Only map categories that actually have spending this month
              children: widget.categories.where((c) => (categoryTotals[c.id] ?? 0) > 0).map((category) {
                final amount = categoryTotals[category.id] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, left: 16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: category.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(fontSize: 14, color: AppColors.primaryText, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        widget.isPrivacyMode ? 'EGP ****' : 'EGP ${amount.toStringAsFixed(0)}', // Used 0 decimals to match the clean look of $412 in your image
                        style: const TextStyle(
                          fontSize: 14, 
                          color: AppColors.primaryText, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: Text('No expenses this month', style: TextStyle(color: AppColors.secondaryText)),
      ),
    );
  }
}