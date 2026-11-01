import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense_category.dart';
import '../theme/app_colors.dart';
import '../providers/expense_provider.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => BudgetsScreenState();
}

class BudgetsScreenState extends State<BudgetsScreen> {
  // --- TRIGGERS ---
  void _showSetGlobalBudgetDialog() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final allocatedCapsSum = provider.categories.fold(
      0.0,
      (sum, cat) => sum + cat.budgetLimit,
    );

    showDialog(
      context: context,
      builder: (context) => SetGlobalBudgetDialog(
        currentBudget: provider.monthlyBudget,
        allocatedCapsSum: allocatedCapsSum,
        onSave: (newBudget) async {
          await provider.setGlobalBudget(newBudget);
        },
      ),
    );
  }

  void _showEditCategoryCapSheet(ExpenseCategory category) {
    // 1. Sum of all categories EXCEPT the one currently being edited

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final allocatedCapsSum = provider.categories.fold(
      0.0,
      (sum, cat) => sum + cat.budgetLimit,
    );

    double otherCategoriesSum = allocatedCapsSum - category.budgetLimit;

    // 2. Max limit you can assign to this specific category
    double maxAvailableForCategory =
        provider.monthlyBudget - otherCategoriesSum;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: EditCategoryCapSheet(
            category: category,
            maxAvailable: maxAvailableForCategory,
            onSave: (newLimit) async {
              await provider.updateCategoryLimit(category.id, newLimit);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    if (provider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    // 1. Calculate Total Overall Spent
    final totalSpent = provider.currentMonthExpenses.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );

    // 2. Calculate Category Totals mapped by Category ID
    final Map<String, double> categoryTotals = {};
    for (var expense in provider.currentMonthExpenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Budgets',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Set an overall Monthly Limit Ceiling by clicking the below box.',
                style: TextStyle(fontSize: 14, color: AppColors.primaryText),
              ),
              const SizedBox(height: 24),

              // Overall Monthly Limit Card (Interactive)
              _buildOverallBudgetCard(
                totalSpent,
                provider.monthlyBudget,
                provider.isPrivacyMode,
              ),
              const SizedBox(height: 32),

              // Category Caps Section
              const Text(
                'Set Category Budget ceilings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 16),

              // Generate an Interactive card for every category in your models
              ...provider.categories.map((category) {
                final spent = categoryTotals[category.id] ?? 0.0;
                return _buildCategoryCapCard(
                  category,
                  spent,
                  provider.isPrivacyMode,
                );
              }),

              const SizedBox(height: 100), // Padding for the floating nav bar
            ],
          ),
        ),
      ),
    );
  }

  // Widget: Dark Overall Limit Card
  Widget _buildOverallBudgetCard(
    double totalSpent,
    double monthlyBudget,
    bool isPrivacyMode,
  ) {
    List<Color> progressColors;
    double progress = (totalSpent / monthlyBudget);
    if (progress > 1.0) progress = 1.0;

    final int percentageUsed = (progress * 100).round();
    // final bool isOverBudget = percentageUsed >= 50;
    final String statusText;

    if (percentageUsed < 50) {
      statusText = 'On track $percentageUsed% used';
      progressColors = [AppColors.transportPurple, AppColors.primaryGreen];
    } else if (percentageUsed < 100) {
      statusText = 'Near limit $percentageUsed% used';
      progressColors = [Colors.amber, Colors.orange];
    } else {
      statusText = 'Exceeded limit $percentageUsed% used';
      progressColors = [Colors.redAccent, Colors.red];
    }
    return InkWell(
      onTap: _showSetGlobalBudgetDialog, // Trigger edit dialog on tap
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Monthly limit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: isPrivacyMode
                            ? 'EGP ****'
                            : 'EGP ${totalSpent.toStringAsFixed(0)} ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: isPrivacyMode
                            ? '/ EGP ****'
                            : '/ EGP ${monthlyBudget.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar
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
                  widthFactor: progress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
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

            Text(
              statusText,
              style: TextStyle(
                color: progressColors.last,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget: White Category Cap Card (Now Clickable)
  Widget _buildCategoryCapCard(
    ExpenseCategory category,
    double spent,
    bool isPrivacyMode,
  ) {
    final limit = category.budgetLimit > 0 ? category.budgetLimit : 1.0;

    double progress = (spent / limit);
    if (progress > 1.0) progress = 1.0;

    final int percentageUsed = (progress * 100).round();

    final bool isNearLimit = percentageUsed >= 50;
    final Color statusColor = isNearLimit ? Colors.red : AppColors.primaryGreen;

    String statusText = 'on track';
    if (percentageUsed >= 100) {
      statusText = 'limit exceeded';
    } else if (percentageUsed >= 50) {
      statusText = 'near limit';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () =>
              _showEditCategoryCapSheet(category), // Edit clicked category
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: category.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ],
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: isPrivacyMode
                                ? 'EGP ****'
                                : 'EGP ${spent.toStringAsFixed(0)} ',
                            style: const TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: isPrivacyMode
                                ? '/ EGP ****'
                                : '/ EGP ${category.budgetLimit.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress Bar
                Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  '$percentageUsed% used — $statusText',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- BOTTOM SHEET: EDIT CATEGORY CAP ---
class EditCategoryCapSheet extends StatefulWidget {
  final ExpenseCategory category;
  final double maxAvailable;
  final Function(double) onSave;

  const EditCategoryCapSheet({
    super.key,
    required this.category,
    required this.maxAvailable,
    required this.onSave,
  });

  @override
  State<EditCategoryCapSheet> createState() => _EditCategoryCapSheetState();
}

class _EditCategoryCapSheetState extends State<EditCategoryCapSheet> {
  final _amountController = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    // Prefill the field with the category's current limit
    _amountController.text = widget.category.budgetLimit > 0
        ? widget.category.budgetLimit.toStringAsFixed(0)
        : '';
  }

  void _validateAndSubmit() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 0) {
      setState(() => _errorText = 'Please enter a Positive number.');
      return;
    }
    if (amount > widget.maxAvailable) {
      setState(
        () => _errorText =
            'Exceeds available budget (Max: EGP ${widget.maxAvailable.toStringAsFixed(0)})',
      );
      return;
    }

    widget.onSave(amount);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Category Cap',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'Maximum available to allocate: EGP ${widget.maxAvailable.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Display the Selected Category Info explicitly
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: widget.category.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.category.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Budget Cap (EGP)',
              errorText: _errorText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _validateAndSubmit,
              child: const Text(
                'Save Cap',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- DIALOG: SET GLOBAL MONTHLY LIMIT ---
class SetGlobalBudgetDialog extends StatefulWidget {
  final double currentBudget;
  final double allocatedCapsSum;
  final Function(double) onSave;

  const SetGlobalBudgetDialog({
    super.key,
    required this.currentBudget,
    required this.allocatedCapsSum,
    required this.onSave,
  });

  @override
  State<SetGlobalBudgetDialog> createState() => _SetGlobalBudgetDialogState();
}

class _SetGlobalBudgetDialogState extends State<SetGlobalBudgetDialog> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentBudget.toStringAsFixed(0),
    );
  }

  void _submit() {
    final amount = double.tryParse(_controller.text);
    if (amount == null || amount <= 0) {
      setState(() => _errorText = 'Please enter a Positive number.');
      return;
    }
    if (amount < widget.allocatedCapsSum) {
      setState(
        () => _errorText =
            'Cannot be less than allocated caps (EGP ${widget.allocatedCapsSum.toStringAsFixed(0)})',
      );
      return;
    }
    widget.onSave(amount);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Overall Monthly Limit',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Amount (EGP)',
          errorText: _errorText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.secondaryText),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
          ),
          onPressed: _submit,
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
