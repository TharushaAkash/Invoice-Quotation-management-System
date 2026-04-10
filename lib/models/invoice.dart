import 'package:flutter/foundation.dart';

class Invoice {
  String? id;
  String invoiceNumber;
  DateTime date;
  String? customerId;
  String customerName;
  String? customerAddress;
  String? customerPhone;
  List<InvoiceItem> items;
  double subtotal;
  double taxRate;
  double taxAmount;
  double total;
  double advance;
  String status;
  String? notes;
  DateTime? dueDate;

  Invoice({
    this.id,
    required this.invoiceNumber,
    required this.date,
    this.customerId,
    required this.customerName,
    this.customerAddress,
    this.customerPhone,
    List<InvoiceItem>? items,
    this.subtotal = 0.0,
    this.taxRate = 0.0,
    this.taxAmount = 0.0,
    this.total = 0.0,
    this.advance = 0.0,
    this.status = 'DRAFT',
    this.notes,
    this.dueDate,
  }) : items = items ?? [];

  void calculateTotals() {
    subtotal = items.fold(0.0, (sum, item) => sum + item.total);
    taxAmount = subtotal * (taxRate / 100.0);
    total = subtotal + taxAmount - advance;
  }

  Map<String, dynamic> toJson() {
    final data = {
      'invoiceNumber': invoiceNumber,
      'date': date.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'total': total,
      'advance': advance,
      'status': status,
      'notes': notes,
      'dueDate': dueDate?.toIso8601String(),
    };
    return data;
  }

  factory Invoice.fromJson(Map<String, dynamic> json, String id) {
    return Invoice(
      id: id,
      invoiceNumber: json['invoiceNumber'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      customerId: json['customerId'],
      customerName: json['customerName'] ?? '',
      customerAddress: json['customerAddress'],
      customerPhone: json['customerPhone'],
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => InvoiceItem.fromJson(item))
          .toList() ?? [],
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      taxRate: (json['taxRate'] ?? 0.0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      advance: (json['advance'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'DRAFT',
      notes: json['notes'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    )..calculateTotals();
  }
}

class InvoiceItem {
  String? itemId;
  String itemName;
  String? description;
  int quantity;
  double unitPrice;

  InvoiceItem({
    this.itemId,
    required this.itemName,
    this.description,
    required this.quantity,
    required this.unitPrice,
  });

  // Calculated getter to ensure it's always up to date with quantity/price changes
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

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      itemId: json['itemId'],
      itemName: json['itemName'] ?? '',
      description: json['description'],
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
    );
  }
}
