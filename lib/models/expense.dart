class Expense {
  String? id;
  DateTime date;
  String category;
  String description;
  double amount;
  String paymentMethod;
  String? vendor;
  String? receiptNumber;
  String? notes;

  Expense({
    this.id,
    required this.date,
    required this.category,
    required this.description,
    required this.amount,
    required this.paymentMethod,
    this.vendor,
    this.receiptNumber,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'category': category,
      'description': description,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'vendor': vendor,
      'receiptNumber': receiptNumber,
      'notes': notes,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json, String id) {
    return Expense(
      id: id,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      vendor: json['vendor'],
      receiptNumber: json['receiptNumber'],
      notes: json['notes'],
    );
  }
}




