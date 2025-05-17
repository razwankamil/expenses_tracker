class Expense {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final String? note;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: map['amount'] as double,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }
}
