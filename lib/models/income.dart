class Income {
  final int? id;
  final String sourceName;
  final double amount;
  final DateTime date;
  final String? note;

  Income({
    this.id,
    required this.sourceName,
    required this.amount,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sourceName': sourceName,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'] as int?,
      sourceName: map['sourceName'] as String,
      amount: map['amount'] as double,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }
}
