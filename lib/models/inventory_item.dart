class InventoryItem {
  String? id;
  String itemCode;
  String name;
  String? description;
  String? category;
  String unit;
  int quantity;
  int minStockLevel;
  double unitCost;
  double sellingPrice;
  String? supplier;
  String? location;

  InventoryItem({
    this.id,
    required this.itemCode,
    required this.name,
    this.description,
    this.category,
    this.unit = 'pcs',
    this.quantity = 0,
    this.minStockLevel = 0,
    this.unitCost = 0.0,
    required this.sellingPrice,
    this.supplier,
    this.location,
  });

  bool get isLowStock => quantity <= minStockLevel;

  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'name': name,
      'description': description,
      'category': category,
      'unit': unit,
      'quantity': quantity,
      'minStockLevel': minStockLevel,
      'unitCost': unitCost,
      'sellingPrice': sellingPrice,
      'supplier': supplier,
      'location': location,
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json, String id) {
    return InventoryItem(
      id: id,
      itemCode: json['itemCode'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'],
      unit: json['unit'] ?? 'pcs',
      quantity: json['quantity'] ?? 0,
      minStockLevel: json['minStockLevel'] ?? 0,
      unitCost: (json['unitCost'] ?? 0.0).toDouble(),
      sellingPrice: (json['sellingPrice'] ?? 0.0).toDouble(),
      supplier: json['supplier'],
      location: json['location'],
    );
  }
}




