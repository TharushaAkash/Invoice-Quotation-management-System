class Quotation {
  String? id;
  String quotationNumber;
  DateTime date;
  DateTime validUntil;
  String? customerId;
  String customerName;
  String? customerAddress;
  String? customerPhone;
  List<QuotationItem> items;
  double subtotal;
  double taxRate;
  double taxAmount;
  double total;
  String status;
  String? notes;

  Quotation({
    this.id,
    required this.quotationNumber,
    required this.date,
    required this.validUntil,
    this.customerId,
    required this.customerName,
    this.customerAddress,
    this.customerPhone,
    List<QuotationItem>? items,
    this.subtotal = 0.0,
    this.taxRate = 0.0,
    this.taxAmount = 0.0,
    this.total = 0.0,
    this.status = 'DRAFT',
    this.notes,
  }) : items = items ?? [];

  void calculateTotals() {
    subtotal = items.fold(0.0, (sum, item) => sum + item.total);
    taxAmount = subtotal * (taxRate / 100.0);
    total = subtotal + taxAmount;
  }

  Map<String, dynamic> toJson() {
    return {
      'quotationNumber': quotationNumber,
      'date': date.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'total': total,
      'status': status,
      'notes': notes,
    };
  }

  factory Quotation.fromJson(Map<String, dynamic> json, String id) {
    return Quotation(
      id: id,
      quotationNumber: json['quotationNumber'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      validUntil: DateTime.parse(json['validUntil'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String()),
      customerId: json['customerId'],
      customerName: json['customerName'] ?? '',
      customerAddress: json['customerAddress'],
      customerPhone: json['customerPhone'],
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => QuotationItem.fromJson(item))
          .toList() ?? [],
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      taxRate: (json['taxRate'] ?? 0.0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'DRAFT',
      notes: json['notes'],
    )..calculateTotals();
  }
}

class QuotationItem {
  String? itemId;
  String itemName;
  String? description;
  int quantity;
  double unitPrice;

  QuotationItem({
    this.itemId,
    required this.itemName,
    this.description,
    required this.quantity,
    required this.unitPrice,
  });

  // Calculated getter
  double get total => quantity * unitPrice;

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
    };
  }

  factory QuotationItem.fromJson(Map<String, dynamic> json) {
    return QuotationItem(
      itemId: json['itemId'],
      itemName: json['itemName'] ?? '',
      description: json['description'],
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
    );
  }
}
