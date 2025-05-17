import 'package:flutter/material.dart';
import '../models/income.dart';

class IncomeForm extends StatefulWidget {
  final Income? income;
  final Function(Income) onSave;

  const IncomeForm({Key? key, this.income, required this.onSave}) : super(key: key);

  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  final _formKey = GlobalKey<FormState>();
  late String _sourceName;
  late double _amount;
  late DateTime _date;
  String? _note;

  final List<String> _categories = [
    'Salary',
    'Freelance',
    'Investment',
    'Bank',
    'Other',
  ];

  IconData _iconForSource(String source) {
    final lower = source.toLowerCase();
    if (lower.contains('salary')) return Icons.work;
    if (lower.contains('freelance')) return Icons.accessibility;
    if (lower.contains('investment')) return Icons.monetization_on;
    if (lower.contains('bank')) return Icons.account_balance_outlined;
    return Icons.category;
  }

  Color _colorForSource(String source, bool isDarkMode) {
    final lower = source.toLowerCase();
    if (lower.contains('salary')) return isDarkMode ? Colors.blue[300]! : Colors.blue;
    if (lower.contains('freelance')) return isDarkMode ? Colors.green[300]! : Colors.green;
    if (lower.contains('investment')) return isDarkMode ? Colors.amber[300]! : Colors.amber;
    if (lower.contains('bank')) return isDarkMode ? Colors.purple[300]! : Colors.purple;
    return isDarkMode ? Colors.grey[400]! : Colors.grey;
  }

  @override
  void initState() {
    super.initState();
    _sourceName = widget.income?.sourceName ?? '';
    _amount = widget.income?.amount ?? 0.0;
    _date = widget.income?.date ?? DateTime.now();
    _note = widget.income?.note;
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
      final income = Income(
        id: widget.income?.id,
        sourceName: _sourceName,
        amount: _amount,
        date: _date,
        note: _note,
      );
      widget.onSave(income);
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
          widget.income == null ? 'Add Income' : 'Edit Income',
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
                        _sourceName = category;
                      });
                    },
                    child: Chip(
                      label: Text(
                        category,
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      avatar: Icon(
                        _iconForSource(category),
                        size: 20,
                        color: _colorForSource(category, isDarkMode),
                      ),
                      backgroundColor: _colorForSource(category, isDarkMode).withOpacity(0.2),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _sourceName,
                decoration: InputDecoration(
                  labelText: 'Source Name',
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                ),
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a source name' : null,
                onSaved: (value) => _sourceName = value!,
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
                    'Save Income',
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
