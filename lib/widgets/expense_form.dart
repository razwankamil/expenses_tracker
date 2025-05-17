import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseForm extends StatefulWidget {
  final Expense? expense;
  final Function(Expense) onSave;

  const ExpenseForm({Key? key, this.expense, required this.onSave}) : super(key: key);

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _amount;
  late DateTime _date;
  String? _note;
  final TextEditingController _titleController = TextEditingController();

  final List<String> _categories = [
    'Health',
    'Medical',
    'Transport',
    'Food',
    'Shopping',
    'Leisure',
    'Fuel',
  ];

  IconData _iconForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('health')) return Icons.favorite;
    if (lower.contains('medical')) return Icons.healing;
    if (lower.contains('transport')) return Icons.directions_car;
    if (lower.contains('food')) return Icons.restaurant;
    if (lower.contains('shopping')) return Icons.shopping_cart;
    if (lower.contains('leisure')) return Icons.movie;
    if (lower.contains('fuel')) return Icons.local_gas_station;
    return Icons.category;
  }

  Color _colorForTitle(String title, bool isDarkMode) {
    final lower = title.toLowerCase();
    if (lower.contains('health')) return isDarkMode ? Colors.red[300]! : Colors.red;
    if (lower.contains('medical')) return isDarkMode ? Colors.green[300]! : Colors.green;
    if (lower.contains('transport')) return isDarkMode ? Colors.blue[300]! : Colors.blue;
    if (lower.contains('food')) return isDarkMode ? Colors.orange[300]! : Colors.orange;
    if (lower.contains('shopping')) return isDarkMode ? Colors.purple[300]! : Colors.purple;
    if (lower.contains('leisure')) return isDarkMode ? Colors.teal[300]! : Colors.teal;
    if (lower.contains('fuel')) return isDarkMode ? const Color.fromARGB(255, 214, 72, 53) : const Color.fromARGB(255, 214, 72, 53);
    return isDarkMode ? Colors.grey[400]! : Colors.grey;
  }

  @override
  void initState() {
    super.initState();
    _title = widget.expense?.title ?? '';
    _amount = widget.expense?.amount ?? 0.0;
    _date = widget.expense?.date ?? DateTime.now();
    _note = widget.expense?.note;
    _titleController.text = _title;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final expense = Expense(
        id: widget.expense?.id,
        title: _title,
        amount: _amount,
        date: _date,
        note: _note,
      );
      widget.onSave(expense);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          widget.expense == null ? 'Add Expense' : 'Edit Expense',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((category) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _title = category;
                        _titleController.text = category;
                      });
                    },
                    child: Chip(
                      label: Text(
                        category,
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      avatar: Icon(
                        _iconForTitle(category),
                        size: 20,
                        color: _colorForTitle(category, isDarkMode),
                      ),
                      backgroundColor: _colorForTitle(category, isDarkMode).withOpacity(0.2),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                ),
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _amount != 0.0 ? _amount.toString() : '',
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                ),
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter an amount';
                  final n = double.tryParse(value);
                  if (n == null || n <= 0) return 'Enter a valid positive number';
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${_date.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      'Select Date',
                      style: TextStyle(color: isDarkMode ? Colors.blue[200] : Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _note,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                ),
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                maxLines: 3,
                onSaved: (value) => _note = value,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.deepPurpleAccent : Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Save Expense',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
