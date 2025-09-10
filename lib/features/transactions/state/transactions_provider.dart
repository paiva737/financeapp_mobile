import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../data/local/hive_boxes.dart';
import '../../../data/models/transaction.dart';

class TransactionsNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionsNotifier() : super([]) {
    _load();
  }

  Box<TransactionModel> get _box =>
      Hive.box<TransactionModel>(HiveBoxes.transactions);

  void _load() {
    state = _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  void add({
    required String title,
    required double amount,
    required DateTime date,
    required TransactionType type,
    required String category,
  }) {
    final item = TransactionModel(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      date: date,
      type: type,
      category: category,
    );
    _box.put(item.id, item);
    _load();
  }

  void update(TransactionModel updated) {
    _box.put(updated.id, updated);
    _load();
  }

  void remove(String id) {
    _box.delete(id);
    _load();
  }

  double get totalIncome =>
      state.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount);

  double get totalExpense =>
      state.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpense;
}

final transactionsProvider =
StateNotifierProvider<TransactionsNotifier, List<TransactionModel>>(
      (ref) => TransactionsNotifier(),
);

final totalsProvider = Provider((ref) {
  final list = ref.watch(transactionsProvider);
  final income = list.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount);
  final expense = list.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);
  final balance = income - expense;
  return (income: income, expense: expense, balance: balance);
});
