import '../models/invoice.dart';
import 'firebase_service.dart';

class InvoiceService {
  final FirebaseService _firebase;
  final String _path = 'invoices';

  InvoiceService(this._firebase);

  Future<String> create(Invoice invoice) async {
    return await _firebase.save(_path, invoice.toJson());
  }

  Future<void> update(Invoice invoice) async {
    if (invoice.id == null) throw Exception('Invoice ID is required');
    await _firebase.update(_path, invoice.id!, invoice.toJson());
  }

  Future<void> delete(String id) async {
    await _firebase.delete(_path, id);
  }

  Future<Invoice?> get(String id) async {
    final data = await _firebase.get(_path, id);
    return data != null ? Invoice.fromJson(data, id) : null;
  }

  Future<List<Invoice>> getAll() async {
    final data = await _firebase.getAll(_path);
    return data.map((item) => Invoice.fromJson(item, item['id'])).toList();
  }

  Future<String> generateInvoiceNumber() async {
    final invoices = await getAll();
    int nextNumber = 1;
    
    if (invoices.isNotEmpty) {
      final numbers = invoices
          .map((inv) {
            final match = RegExp(r'\d+').firstMatch(inv.invoiceNumber);
            return match != null ? int.tryParse(match.group(0)!) : 0;
          })
          .where((n) => n != null && n > 0)
          .cast<int>() // Explicit cast to ensure type safety
          .toList();
      
      if (numbers.isNotEmpty) {
        nextNumber = numbers.reduce((a, b) => a > b ? a : b) + 1;
      }
    }
    
    return 'INV-${nextNumber.toString().padLeft(4, '0')}';
  }
}


