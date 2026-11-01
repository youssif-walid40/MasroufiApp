import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Required to format the tooltip dates nicely
import 'dart:math';
import '../models/expense.dart';
import '../theme/app_colors.dart';

class DailyTrendChart extends StatelessWidget {
  final List<Expense> expenses;

  const DailyTrendChart({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // 1. Generate the exact dates for the last 14 days (ending today)
    final List<DateTime> last14Days = List.generate(14, (i) {
      return DateTime(now.year, now.month, now.day).subtract(Duration(days: 13 - i));
    });

    // 2. Initialize a map with 0.0 for all 14 indices (Index 0 = 13 days ago, Index 13 = Today)
    final Map<int, double> dailyTotals = {for (var i = 0; i < 14; i++) i: 0.0};

    // 3. Aggregate expenses into the correct day index
    for (var expense in expenses) {
      for (int i = 0; i < 14; i++) {
        final targetDate = last14Days[i];
        if (expense.date.year == targetDate.year &&
            expense.date.month == targetDate.month &&
            expense.date.day == targetDate.day) {
          dailyTotals[i] = dailyTotals[i]! + expense.amount;
          break; // Stop looping once the date matches
        }
      }
    }

    // Find the highest spending day to scale the Y-axis properly
    double maxY = 0;
    if (dailyTotals.isNotEmpty) {
      maxY = dailyTotals.values.reduce(max);
    }
    // Add a 20% buffer to the top of the chart so the line doesn't hit the ceiling
    maxY = maxY == 0 ? 100 : maxY * 1.2;

    // 4. Create the data points (spots) using the 0-13 index for the X-axis
    List<FlSpot> spots = [];
    for (int i = 0; i < 14; i++) {
      spots.add(FlSpot(i.toDouble(), dailyTotals[i]!));
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.only(top: 24, right: 24, left: 10, bottom: 10),
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
      child: LineChart(
        LineChartData(
          // Background grid styling
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.15),
                strokeWidth: 1,
              );
            },
          ),
          
          // Axis labels
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 3, // Shows a label every 3 days to prevent text crowding
                getTitlesWidget: (value, meta) {
                  final int index = value.toInt();
                  if (index < 0 || index >= 14) return const SizedBox.shrink();
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      last14Days[index].day.toString(), // Maps the index back to the calendar day
                      style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxY / 4,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink(); // Hide the zero label
                  return Text(
                    value >= 1000 ? '${(value / 1000).toStringAsFixed(1)}k' : value.toStringAsFixed(0),
                    style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                    textAlign: TextAlign.right,
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 13, // Fixed to 14 total points (0 through 13)
          minY: 0,
          maxY: maxY,
          
          // Line and Gradient styling
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: true,
              color: AppColors.primaryGreen,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false), 
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen.withValues(alpha: 0.3),
                    AppColors.primaryGreen.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          
          // Interactive touch tooltips
          lineTouchData: LineTouchData(
            getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                  const FlLine(color: AppColors.primaryGreen, strokeWidth: 2, dashArray: [4, 4]),
                  const FlDotData(show: true),
                );
              }).toList();
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => AppColors.darkCard,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  // Re-map the X index to format a clean date string for the tooltip
                  final date = last14Days[touchedSpot.x.toInt()];
                  final dateString = DateFormat('MMM d').format(date);
                  
                  return LineTooltipItem(
                    'EGP ${touchedSpot.y.toStringAsFixed(0)}\n',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: dateString, // Displays e.g., "Sep 22" instead of "Day 13"
                        style: const TextStyle(color: AppColors.secondaryText, fontSize: 12, fontWeight: FontWeight.normal),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }
}