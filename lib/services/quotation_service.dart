import '../models/quotation.dart';
import 'firebase_service.dart';

class QuotationService {
  final FirebaseService _firebase;
  final String _path = 'quotations';

  QuotationService(this._firebase);

  Future<String> create(Quotation quotation) async {
    return await _firebase.save(_path, quotation.toJson());
  }

  Future<void> update(Quotation quotation) async {
    if (quotation.id == null) throw Exception('Quotation ID is required');
    await _firebase.update(_path, quotation.id!, quotation.toJson());
  }

  Future<void> delete(String id) async {
    await _firebase.delete(_path, id);
  }

  Future<Quotation?> get(String id) async {
    final data = await _firebase.get(_path, id);
    return data != null ? Quotation.fromJson(data, id) : null;
  }

  Future<List<Quotation>> getAll() async {
    final data = await _firebase.getAll(_path);
    return data.map((item) => Quotation.fromJson(item, item['id'])).toList();
  }

  Future<String> generateQuotationNumber() async {
    final quotations = await getAll();
    int nextNumber = 1;
    
    if (quotations.isNotEmpty) {
      final numbers = quotations
          .map((quo) {
            final match = RegExp(r'\d+').firstMatch(quo.quotationNumber);
            return match != null ? int.tryParse(match.group(0)!) : 0;
          })
          .where((n) => n != null && n > 0)
          .cast<int>() // Explicit cast to ensure type safety
          .toList();
      
      if (numbers.isNotEmpty) {
        nextNumber = numbers.reduce((a, b) => a > b ? a : b) + 1;
      }
    }
    
    return 'QUO-${nextNumber.toString().padLeft(4, '0')}';
  }
}


