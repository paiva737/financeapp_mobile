import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../data/local/hive_boxes.dart';
import '../../../data/models/transaction.dart';


const _boxName = HiveBoxes.transactions;

class TransactionsNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionsNotifier() : super(const []) {
    _init();
  }



  Future<void> _init() async {
    await _ensureBox();
    await _load();
  }

  Future<void> _ensureBox() async {

    _registerAdaptersIfNeeded();

    if (!Hive.isBoxOpen(_boxName)) {

      await Hive.openBox<TransactionModel>(_boxName);
    }
  }

  void _registerAdaptersIfNeeded() {

    try {
      final modelAdapter = TransactionModelAdapter();
      if (!Hive.isAdapterRegistered(modelAdapter.typeId)) {
        Hive.registerAdapter(modelAdapter);
      }
    } catch (_) {

    }

    try {
      final typeAdapter = TransactionTypeAdapter();
      if (!Hive.isAdapterRegistered(typeAdapter.typeId)) {
        Hive.registerAdapter(typeAdapter);
      }
    } catch (_) {

    }
  }

  Box<TransactionModel> get _box =>
      Hive.box<TransactionModel>(_boxName);



  Future<void> _load() async {
    // Ordena do mais recente para o mais antigo
    final list = _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    state = list;
  }



  Future<void> add({
    required String title,
    required double amount,
    required DateTime date,
    required TransactionType type,
    required String category,
  }) async {
    await _ensureBox();

    final item = TransactionModel(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      date: date,
      type: type,
      category: category,
    );

    await _box.put(item.id, item);
    await _load();
  }

  Future<void> update(TransactionModel updated) async {
    await _ensureBox();
    await _box.put(updated.id, updated);
    await _load();
  }

  Future<void> remove(String id) async {
    await _ensureBox();
    await _box.delete(id);
    await _load();
  }



  double get totalIncome => state
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (s, t) => s + t.amount);

  double get totalExpense => state
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpense;
}

final transactionsProvider =
StateNotifierProvider<TransactionsNotifier, List<TransactionModel>>(
      (ref) => TransactionsNotifier(),
);


final totalsProvider = Provider((ref) {
  final list = ref.watch(transactionsProvider);
  final income = list
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (s, t) => s + t.amount);
  final expense = list
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (s, t) => s + t.amount);
  final balance = income - expense;
  return (income: income, expense: expense, balance: balance);
});
