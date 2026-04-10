class Income {
  String? id;
  DateTime date;
  String source;
  String description;
  double amount;
  String paymentMethod;
  String? customerId;
  String? customerName;
  String? invoiceId;
  String? notes;

  Income({
    this.id,
    required this.date,
    required this.source,
    required this.description,
    required this.amount,
    required this.paymentMethod,
    this.customerId,
    this.customerName,
    this.invoiceId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'source': source,
      'description': description,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'customerId': customerId,
      'customerName': customerName,
      'invoiceId': invoiceId,
      'notes': notes,
    };
  }

  factory Income.fromJson(Map<String, dynamic> json, String id) {
    return Income(
      id: id,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      source: json['source'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      customerId: json['customerId'],
      customerName: json['customerName'],
      invoiceId: json['invoiceId'],
      notes: json['notes'],
    );
  }
}




