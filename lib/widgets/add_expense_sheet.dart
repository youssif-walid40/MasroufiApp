import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Used to format the displayed date in the form
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../theme/app_colors.dart';

class AddExpenseSheet extends StatefulWidget {
  final List<ExpenseCategory> categories;
  final Expense? existingExpense;
  final Function(Expense) onSave;

  const AddExpenseSheet({
    super.key,
    required this.categories,
    this.existingExpense,
    required this.onSave,
  });

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _nameController = TextEditingController(); // Controller for itemName
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _nameError;
  String? _amountError;
  
  late String _selectedCategoryId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // Pre-fill data if editing, otherwise set defaults
    if (widget.existingExpense != null) {
      _nameController.text = widget.existingExpense!.itemName;
      _amountController.text = widget.existingExpense!.amount.toString();
      _noteController.text = widget.existingExpense!.note ?? '';
      _selectedCategoryId = widget.existingExpense!.categoryId;
      _selectedDate = widget.existingExpense!.date;
    } else {
      _selectedCategoryId = widget.categories.first.id;
      _selectedDate = DateTime.now(); // Defaults to today
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Triggers the built-in Flutter calendar popup
  // Triggers the calendar, followed immediately by the clock
  Future<void> _pickDateTime() async {
    // 1. Pick the Date
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primaryGreen),
          ),
          child: child!,
        );
      },
    );

    // If the user cancels the date picker, stop the flow
    if (pickedDate == null) return;

    // 2. Pick the Time
    // Wait for the UI to settle before showing the next dialog
    if (!mounted) return;
    
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primaryGreen),
          ),
          child: child!,
        );
      },
    );

    // If the user cancels the time picker, stop the flow
    if (pickedTime == null) return;

    // 3. Combine both into a single DateTime object
    setState(() {
      _selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _submitForm() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final itemName = _nameController.text.trim();

    // 2. Validate and set error messages inside setState
    setState(() {
      _nameError = itemName.isEmpty ? 'Please enter an item name' : null;
      _amountError = (amount <= 0) ? 'Please enter a Positive number for amount' : null;
    });

    // If either error exists, stop the function
    if (_nameError != null || _amountError != null) {
      return; 
    }

    final newExpense = Expense(
      id: widget.existingExpense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      itemName: itemName, // Passing your new field here
      categoryId: _selectedCategoryId,
      amount: amount,
      date: _selectedDate,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );

    widget.onSave(newExpense);
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
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.0),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existingExpense == null ? 'Add Expense' : 'Edit Expense',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryText),
            ),
            const SizedBox(height: 24),
            
            // 1. Item Name Field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Item Name (e.g., Koshari, Dushka Burger, etc.)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                errorText: _nameError,
              ),
            ),
            const SizedBox(height: 16),

            // 2. Amount Field
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (EGP)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                errorText: _amountError,
              ),
            ),
            const SizedBox(height: 16),
            
            // 3. Category & Date Row
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: widget.categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        if (value != null) _selectedCategoryId = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: _pickDateTime,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 60, // Matches the height of the dropdown
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        DateFormat('MMM d, h:mm a').format(_selectedDate),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 4. Note Field
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note (Optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            
            // 5. Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitForm,
                child: const Text('Save Expense', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
      ),
        ),
      )
      
      
    );
  }
}