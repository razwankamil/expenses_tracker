import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../db/database_helper.dart';
import '../widgets/expense_form.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await _databaseHelper.getExpenses();
    setState(() {
      _expenses = expenses;
    });
  }

  void _openExpenseForm({Expense? expense}) {
    showDialog(
      context: context,
      builder: (context) => ExpenseForm(
        expense: expense,
        onSave: (Expense exp) async {
          if (exp.id == null) {
            await _databaseHelper.insertExpense(exp);
          } else {
            await _databaseHelper.updateExpense(exp);
          }
          _loadExpenses();
        },
      ),
    );
  }

  Future<void> _deleteExpense(int id) async {
    await _databaseHelper.deleteExpense(id);
    _loadExpenses();
  }

  Future<void> _confirmDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _deleteExpense(id);
    }
  }

  IconData _iconForTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('health')) return Icons.favorite;
    if (lowerTitle.contains('medical')) return Icons.healing;
    if (lowerTitle.contains('transport')) return Icons.directions_car;
    if (lowerTitle.contains('food')) return Icons.restaurant;
    if (lowerTitle.contains('shopping')) return Icons.shopping_cart;
    if (lowerTitle.contains('leisure')) return Icons.movie;
    if (lowerTitle.contains('fuel')) return Icons.local_gas_station;
    return Icons.category;
  }

  Color _colorForTitle(String title, bool isDarkMode) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('health')) return isDarkMode ? Colors.red[300]! : Colors.red;
    if (lowerTitle.contains('medical')) return isDarkMode ? Colors.green[300]! : Colors.green;
    if (lowerTitle.contains('transport')) return isDarkMode ? Colors.blue[300]! : Colors.blue;
    if (lowerTitle.contains('food')) return isDarkMode ? Colors.orange[300]! : Colors.orange;
    if (lowerTitle.contains('shopping')) return isDarkMode ? Colors.purple[300]! : Colors.purple;
    if (lowerTitle.contains('leisure')) return isDarkMode ? Colors.teal[300]! : Colors.teal;
    if (lowerTitle.contains('fuel')) return isDarkMode ? const Color.fromARGB(255, 255, 138, 128) : const Color.fromARGB(255, 233, 83, 56);
    return isDarkMode ? Colors.grey[400]! : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final totalExpense = _expenses.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.teal[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Expense',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white70 : const Color.fromARGB(137, 8, 8, 8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${totalExpense.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _expenses.isEmpty
                ? Expanded(
                    child: Center(
                      child: Text(
                        'No expenses yet.',
                        style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  )
                : Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(4),
                      itemCount: _expenses.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        final expense = _expenses[index];
                        return GestureDetector(
                          onTap: () => _openExpenseForm(expense: expense),
                          onLongPress: () => _confirmDelete(expense.id!),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: isDarkMode ? Colors.grey[900] : null,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _iconForTitle(expense.title),
                                    size: 32,
                                    color: _colorForTitle(expense.title, isDarkMode),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '\$${expense.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    expense.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openExpenseForm(),
        backgroundColor: isDarkMode ? Colors.deepPurpleAccent : Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
