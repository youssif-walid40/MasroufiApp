import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../theme/app_colors.dart';

class SummaryCard extends StatelessWidget {
  final List<Expense> expenses;
  final double monthlyBudget;
  final bool isPrivacyMode;

  const SummaryCard({
    super.key,
    required this.expenses,
    this.monthlyBudget = 2000.00, // Default budget, can be changed later
    this.isPrivacyMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Calculate Time Context
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0); // 0th day of next month is the last day of this month
    final daysLeft = lastDayOfMonth.day - now.day;

    // 2. Filter and Sum Current Month's Expenses
    // final currentMonthExpenses = expenses.where((e) {
    //   return e.date.year == now.year && e.date.month == now.month;
    // });
    
    final totalSpent = expenses.fold(0.0, (sum, item) => sum + item.amount);
    
    // 3. Calculate Progress & Remaining
    double progress = (totalSpent / monthlyBudget);
    if (progress > 1.0) progress = 1.0; // Caps the visual bar at 100%
    if (progress < 0.0) progress = 0.0;
    
    final int percentageUsed = (progress * 100).round();
    final double amountLeft = monthlyBudget - totalSpent;

    List<Color> progressColors;
    if (percentageUsed >= 100) {
      progressColors = [Colors.redAccent, Colors.red]; // Over budget
    } else if (percentageUsed >= 50) {
      progressColors = [Colors.amber, Colors.orange]; // Warning (50% - 99%)
    } else {
      progressColors = [AppColors.transportPurple, AppColors.primaryGreen]; // Safe (Under 50%)
    }

    // 4. Format numbers for the UI (splitting the integer and decimal for styling)
    final spentString = totalSpent.toStringAsFixed(2);
    final spentParts = spentString.split('.');
    final spentInteger = spentParts[0];
    final spentDecimal = spentParts[1];

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(24.0),
        gradient: const LinearGradient(
          colors: [Color(0xFF1C1C26), Color(0xFF14141B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Row: Label
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SPENT THIS MONTH',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Middle Row: Main Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                isPrivacyMode ? 'EGP ****' : 'EGP $spentInteger',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isPrivacyMode ? ' / EGP ****' : '.$spentDecimal / EGP ${monthlyBudget.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Progress Bar
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress, // Dynamically set based on calculation
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      // Turn the bar red if they exceed the budget
                      colors: progressColors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 4. Bottom Row: Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percentageUsed% used',
                style: TextStyle(
                  color: percentageUsed >= 100 ? Colors.redAccent : AppColors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                isPrivacyMode ? 'EGP **** left • $daysLeft days' : 'EGP ${amountLeft > 0 ? amountLeft.toStringAsFixed(2) : "0.00"} left • $daysLeft days',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
  // Updated Interactive Toggle
//   Widget _buildMonthWeekToggle() {
//     return Container(
//       padding: const EdgeInsets.all(4.0),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           // Month Button
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 isMonthSelected = true;
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 // Colors conditionally change based on state
//                 color: isMonthSelected ? Colors.white : Colors.transparent,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Text(
//                 'Month',
//                 style: TextStyle(
//                   color: isMonthSelected ? AppColors.primaryText : AppColors.secondaryText,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           // Week Button
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 isMonthSelected = false;
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: !isMonthSelected ? Colors.white : Colors.transparent,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Text(
//                 'Week',
//                 style: TextStyle(
//                   color: !isMonthSelected ? AppColors.primaryText : AppColors.secondaryText,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
