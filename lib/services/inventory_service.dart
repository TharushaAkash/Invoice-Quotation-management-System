import '../models/inventory_item.dart';
import 'firebase_service.dart';

class InventoryService {
  final FirebaseService _firebase;
  final String _path = 'inventory';

  InventoryService(this._firebase);

  Future<String> create(InventoryItem item) async {
    return await _firebase.save(_path, item.toJson());
  }

  Future<void> update(InventoryItem item) async {
    if (item.id == null) throw Exception('Item ID is required');
    await _firebase.update(_path, item.id!, item.toJson());
  }

  Future<void> delete(String id) async {
    await _firebase.delete(_path, id);
  }

  Future<InventoryItem?> get(String id) async {
    final data = await _firebase.get(_path, id);
    return data != null ? InventoryItem.fromJson(data, id) : null;
  }

  Future<List<InventoryItem>> getAll() async {
    final data = await _firebase.getAll(_path);
    return data.map((item) => InventoryItem.fromJson(item, item['id'])).toList();
  }

  Future<List<InventoryItem>> getLowStockItems() async {
    final items = await getAll();
    return items.where((item) => item.isLowStock).toList();
  }
}




