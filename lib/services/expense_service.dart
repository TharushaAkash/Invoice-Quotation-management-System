import 'dart:async';
import '../models/expense.dart';
import 'firebase_service.dart';

class ExpenseService {
  final FirebaseService _firebase;
  final String _path = 'expenses';

  ExpenseService(this._firebase);

  Future<String> create(Expense expense) async {
    return await _firebase.save(_path, expense.toJson());
  }

  Future<void> update(Expense expense) async {
    if (expense.id == null) throw Exception('Expense ID is required');
    await _firebase.update(_path, expense.id!, expense.toJson());
  }

  Future<void> delete(String id) async {
    await _firebase.delete(_path, id);
  }

  Future<Expense?> get(String id) async {
    final data = await _firebase.get(_path, id);
    return data != null ? Expense.fromJson(data, id) : null;
  }

  Future<List<Expense>> getAll() async {
    final data = await _firebase.getAll(_path);
    return data.map((item) => Expense.fromJson(item, item['id'])).toList();
  }

  Future<List<Expense>> getByDateRange(DateTime start, DateTime end) async {
    final expenses = await getAll();
    return expenses.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  Future<double> getTotal(DateTime start, DateTime end) async {
    final expenses = await getByDateRange(start, end);
    return expenses.fold<double>(0.0, (double sum, Expense expense) => sum + expense.amount);
  }
}


