import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../db/database_helper.dart';
import '../models/expense.dart';
import '../models/income.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateSummary();
  }

  Future<void> _calculateSummary() async {
    final List<Income> incomes = await _dbHelper.getIncome();
    final List<Expense> expenses = await _dbHelper.getExpenses();

    double incomeSum = 0.0;
    for (var inc in incomes) {
      incomeSum += inc.amount;
    }

    double expenseSum = 0.0;
    for (var exp in expenses) {
      expenseSum += exp.amount;
    }

    setState(() {
      _totalIncome = incomeSum;
      _totalExpenses = expenseSum;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double balance = _totalIncome - _totalExpenses;
    final double percentage =
        _totalIncome == 0 ? 0 : (_totalExpenses / _totalIncome).clamp(0.0, 1.0);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Hi, User 👋",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : const Color(0xFF1F2C48),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current Balance",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "\$ ${balance.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              CircularPercentIndicator(
                radius: 100.0,
                lineWidth: 13.0,
                animation: true,
                percent: percentage,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "\$ ${_totalExpenses.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      "Spent",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : const Color.fromARGB(255, 54, 53, 53),
                      ),
                    ),
                  ],
                ),
                footer: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    "Expense Overview",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.orangeAccent,
                backgroundColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              ),
              const SizedBox(height: 30),
              _buildCategoryRow("Income", _totalIncome, Colors.green, isDarkMode),
              const SizedBox(height: 10),
              _buildCategoryRow("Expenses", _totalExpenses, Colors.red, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(String label, double amount, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black54 : Colors.grey.shade300,
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 10, backgroundColor: color),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          Text(
            "\$ ${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
