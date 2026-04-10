import 'dart:async';
import '../models/income.dart';
import 'firebase_service.dart';

class IncomeService {
  final FirebaseService _firebase;
  final String _path = 'income';

  IncomeService(this._firebase);

  Future<String> create(Income income) async {
    return await _firebase.save(_path, income.toJson());
  }

  Future<void> update(Income income) async {
    if (income.id == null) throw Exception('Income ID is required');
    await _firebase.update(_path, income.id!, income.toJson());
  }

  Future<void> delete(String id) async {
    await _firebase.delete(_path, id);
  }

  Future<Income?> get(String id) async {
    final data = await _firebase.get(_path, id);
    return data != null ? Income.fromJson(data, id) : null;
  }

  Future<List<Income>> getAll() async {
    final data = await _firebase.getAll(_path);
    return data.map((item) => Income.fromJson(item, item['id'])).toList();
  }

  Future<List<Income>> getByDateRange(DateTime start, DateTime end) async {
    final incomes = await getAll();
    return incomes.where((income) {
      return income.date.isAfter(start.subtract(const Duration(days: 1))) &&
          income.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  Future<double> getTotal(DateTime start, DateTime end) async {
    final incomes = await getByDateRange(start, end);
    return incomes.fold<double>(0.0, (double sum, Income income) => sum + income.amount);
  }
}


