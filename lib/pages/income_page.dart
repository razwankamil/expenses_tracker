import 'package:flutter/material.dart';
import '../models/income.dart';
import '../db/database_helper.dart';
import '../widgets/income_form.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({Key? key}) : super(key: key);

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Income> _incomeList = [];

  @override
  void initState() {
    super.initState();
    _loadIncome();
  }

  Future<void> _loadIncome() async {
    final income = await _databaseHelper.getIncome();
    setState(() {
      _incomeList = income;
    });
  }

  void _openIncomeForm({Income? income}) {
    showDialog(
      context: context,
      builder: (context) => IncomeForm(
        income: income,
        onSave: (Income inc) async {
          if (inc.id == null) {
            await _databaseHelper.insertIncome(inc);
          } else {
            await _databaseHelper.updateIncome(inc);
          }
          _loadIncome();
        },
      ),
    );
  }

  Future<void> _deleteIncome(int id) async {
    await _databaseHelper.deleteIncome(id);
    _loadIncome();
  }

  Future<void> _confirmDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Income'),
        content: const Text('Are you sure you want to delete this income?'),
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
      _deleteIncome(id);
    }
  }

  IconData _iconForSource(String source) {
    final lowerSource = source.toLowerCase();
    if (lowerSource.contains('salary')) return Icons.attach_money;
    if (lowerSource.contains('business')) return Icons.business_center;
    if (lowerSource.contains('investment')) return Icons.show_chart;
    if (lowerSource.contains('bank')) return Icons.account_balance_outlined;
    return Icons.account_balance_wallet;
  }

  Color _colorForSource(String source, bool isDarkMode) {
    final lowerSource = source.toLowerCase();
    if (lowerSource.contains('salary')) return isDarkMode ? Colors.green[300]! : Colors.green[700]!;
    if (lowerSource.contains('business')) return isDarkMode ? Colors.blue[300]! : Colors.blue[700]!;
    if (lowerSource.contains('investment')) return isDarkMode ? Colors.orange[300]! : Colors.orange[700]!;
    if (lowerSource.contains('bank')) return isDarkMode ? Colors.purple[300]! : Colors.purple[700]!;
    return isDarkMode ? Colors.teal[300]! : Colors.teal[700]!;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final totalIncome = _incomeList.fold(0.0, (sum, e) => sum + e.amount);

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
                    'Total Income',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white70 : const Color.fromARGB(137, 8, 8, 8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${totalIncome.toStringAsFixed(2)}',
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
            _incomeList.isEmpty
                ? Expanded(
                    child: Center(
                      child: Text(
                        'No income added yet.',
                        style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  )
                : Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(4),
                      itemCount: _incomeList.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final income = _incomeList[index];
                        return GestureDetector(
                          onTap: () => _openIncomeForm(income: income),
                          onLongPress: () => _confirmDelete(income.id!),
                          child: Card(
                            elevation: 5,
                            color: isDarkMode ? Colors.grey[900] : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadowColor: Colors.black.withOpacity(0.1),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    _iconForSource(income.sourceName),
                                    size: 48,
                                    color: _colorForSource(income.sourceName, isDarkMode),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    income.sourceName,
                                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? Colors.white : Colors.black87,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$${income.amount.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                          color: isDarkMode ? Colors.green[300] : Colors.green[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    income.date.toLocal().toString().split(' ')[0],
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                    textAlign: TextAlign.center,
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
        onPressed: () => _openIncomeForm(),
        backgroundColor: isDarkMode ? Colors.deepPurpleAccent : Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
